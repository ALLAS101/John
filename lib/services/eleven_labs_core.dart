// Pure-Dart core of the ElevenLabs client — no `path_provider`, no Flutter
// import at all, so `tool/generate_daily_audio.dart` (a plain script run
// via `dart run`, outside the Flutter engine) can import this file without
// dragging in `dart:ui` transitively and failing to compile. The on-device
// disk cache (`ElevenLabsService.synthesizeCached`, which needs
// `path_provider` and is what the app itself calls) lives in
// `eleven_labs_service.dart`, which builds on top of this file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

/// Thrown when the ElevenLabs API rejects a request or is unreachable.
/// [statusCode] is null for a network-level failure (no response at all).
class ElevenLabsException implements Exception {
  ElevenLabsException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ElevenLabsException($statusCode): $message';
}

/// The ElevenLabs text-to-speech HTTP call, with no caching or app-specific
/// configuration — just "given a key, a voice, and some text, return audio
/// bytes or throw". Both the app (via `ElevenLabsService`) and
/// `tool/generate_daily_audio.dart` call [synthesizeBytes] directly.
class ElevenLabsCore {
  ElevenLabsCore._();

  /// "Rachel", one of ElevenLabs' standard premade voices — the default
  /// voice when a call site doesn't specify one.
  static const defaultVoiceId = '21m00Tcm4TlvDq8ikWAM';

  static const _modelId = 'eleven_multilingual_v2';

  /// Test-only override of the `http.Client` used when a call site doesn't
  /// pass one explicitly (production call sites never do — this exists
  /// purely so tests can inject a `MockClient` without threading a client
  /// through `AppState`'s public API).
  @visibleForTesting
  static http.Client? debugHttpClientOverride;

  /// Synthesizes [text] with ElevenLabs and returns the raw audio bytes.
  /// Throws [ElevenLabsException] on any failure — a non-200 response
  /// (parsed for the API's own error message), an empty body, or a
  /// network-level error.
  static Future<Uint8List> synthesizeBytes(
    String text, {
    required String apiKey,
    String voiceId = defaultVoiceId,
    http.Client? client,
  }) async {
    final httpClient = client ?? debugHttpClientOverride ?? http.Client();
    final shouldClose = client == null && debugHttpClientOverride == null;
    try {
      final response = await httpClient
          .post(
            Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId'),
            headers: {
              'xi-api-key': apiKey,
              'Content-Type': 'application/json',
              'Accept': 'audio/mpeg',
            },
            body: jsonEncode({
              'text': text,
              'model_id': _modelId,
              'voice_settings': {'stability': 0.5, 'similarity_boost': 0.75},
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw ElevenLabsException(
          _describeError(response.bodyBytes),
          statusCode: response.statusCode,
        );
      }
      if (response.bodyBytes.isEmpty) {
        throw ElevenLabsException(
          'ElevenLabs returned an empty response.',
          statusCode: response.statusCode,
        );
      }
      return response.bodyBytes;
    } on ElevenLabsException {
      rethrow;
    } catch (e) {
      throw ElevenLabsException('Network error reaching ElevenLabs: $e');
    } finally {
      if (shouldClose) httpClient.close();
    }
  }

  /// ElevenLabs error responses are JSON (`{"detail": {"message": "..."}}`
  /// or `{"detail": "..."}`); falls back to the raw body if it isn't.
  static String _describeError(Uint8List bodyBytes) {
    try {
      final decoded = jsonDecode(utf8.decode(bodyBytes));
      if (decoded is Map) {
        final detail = decoded['detail'];
        if (detail is Map && detail['message'] is String) {
          return detail['message'] as String;
        }
        if (detail is String) return detail;
      }
    } catch (_) {
      // Not JSON — fall through to the raw-body message below.
    }
    return utf8.decode(bodyBytes, allowMalformed: true);
  }
}
