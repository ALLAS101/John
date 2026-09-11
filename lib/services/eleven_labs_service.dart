import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

import 'eleven_labs_core.dart';

export 'eleven_labs_core.dart' show ElevenLabsException;

/// Text-to-speech via the ElevenLabs API — the "better voice" option for
/// Listen, ahead of the on-device engine `AppState` otherwise uses (see its
/// "Verse playback" section). Generated audio is cached to disk (keyed by
/// voice + exact text), so the same verse is only ever synthesized once per
/// device — important both because ElevenLabs' free tier is metered by
/// character count, and so repeat plays are instant rather than re-hitting
/// the network.
///
/// This is the *app's* entry point — it adds an on-disk cache and app
/// configuration (the API key/voice ID, read from build-time environment
/// variables) on top of [ElevenLabsCore]'s bare HTTP call. It is deliberately
/// **not** what `tool/generate_daily_audio.dart` uses (that calls
/// [ElevenLabsCore.synthesizeBytes] directly) — see this app's other, larger
/// win: most of the time, Listen doesn't call ElevenLabs at all, because
/// `DailyAudioService` already has today's verse pre-generated *once* and
/// shared by every user (see that class, and the top-level README's "Shared
/// daily audio" section) — this per-device cache only matters for the
/// less-common paths (no shared audio yet for today, or a custom
/// `ELEVENLABS_VOICE_ID` different from the shared one).
///
/// **Setup**: needs an ElevenLabs API key, which is never hardcoded or
/// committed here — it's read from a build-time environment variable, e.g.:
/// ```
/// flutter run --dart-define=ELEVENLABS_API_KEY=your_key_here
/// ```
/// See the top-level README's "Verse audio" section for the full setup
/// (getting a free key, optionally picking a different voice). With no key
/// configured, [isConfigured] is false and `AppState` falls back to the
/// on-device voice — the app works either way.
class ElevenLabsService {
  ElevenLabsService._();

  static const _apiKey = String.fromEnvironment('ELEVENLABS_API_KEY');

  /// Override with `--dart-define=ELEVENLABS_VOICE_ID=...` to use a
  /// different voice from your ElevenLabs account than the shared daily
  /// audio was generated with.
  static const _voiceId = String.fromEnvironment(
    'ELEVENLABS_VOICE_ID',
    defaultValue: ElevenLabsCore.defaultVoiceId,
  );

  /// Test-only override of the API key — lets a test exercise the
  /// "configured" path without a real key or `--dart-define`. `null` (the
  /// default) means "use the real build-time `ELEVENLABS_API_KEY`".
  @visibleForTesting
  static String? debugApiKeyOverride;

  /// Test-only override of the cache directory, so tests don't need a
  /// working `path_provider` platform channel (unavailable in a plain
  /// `test()`) to exercise caching.
  @visibleForTesting
  static Directory? debugCacheDirectoryOverride;

  static String get _resolvedApiKey => debugApiKeyOverride ?? _apiKey;

  static bool get isConfigured => _resolvedApiKey.isNotEmpty;

  /// Returns a local file containing the spoken audio for [text], from the
  /// on-disk cache when available, else fetched from the API and cached
  /// for next time.
  ///
  /// Throws [ElevenLabsException] if [isConfigured] is false, the API call
  /// fails, or caching the result fails.
  static Future<File> synthesizeCached(
    String text, {
    http.Client? client,
  }) async {
    if (!isConfigured) {
      throw ElevenLabsException(
        'ElevenLabs is not configured (no ELEVENLABS_API_KEY).',
      );
    }

    final baseDir =
        debugCacheDirectoryOverride ?? await getApplicationSupportDirectory();
    final cacheDir = Directory('${baseDir.path}/eleven_labs_cache');
    final key = sha256.convert(utf8.encode('$_voiceId::$text')).toString();
    final file = File('${cacheDir.path}/$key.mp3');

    if (await file.exists() && await file.length() > 0) {
      return file;
    }

    final bytes = await ElevenLabsCore.synthesizeBytes(
      text,
      apiKey: _resolvedApiKey,
      voiceId: _voiceId,
      client: client,
    );
    await cacheDir.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
