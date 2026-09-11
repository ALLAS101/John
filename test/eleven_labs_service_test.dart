// Verifies ElevenLabsService's HTTP request shape, error parsing, and disk
// caching — by mocking `http.Client` (package:http/testing.dart) and using
// a real temp directory for the cache, not by reading the source and
// trusting it.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:john316/services/eleven_labs_core.dart';
import 'package:john316/services/eleven_labs_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('eleven_labs_test');
    ElevenLabsService.debugCacheDirectoryOverride = tempDir;
  });

  tearDown(() async {
    ElevenLabsService.debugApiKeyOverride = null;
    ElevenLabsCore.debugHttpClientOverride = null;
    ElevenLabsService.debugCacheDirectoryOverride = null;
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('isConfigured reflects the (overridable) API key', () {
    ElevenLabsService.debugApiKeyOverride = '';
    expect(ElevenLabsService.isConfigured, isFalse);

    ElevenLabsService.debugApiKeyOverride = 'a-real-looking-key';
    expect(ElevenLabsService.isConfigured, isTrue);
  });

  test('synthesizeCached throws without an API key configured', () async {
    ElevenLabsService.debugApiKeyOverride = '';
    expect(
      () => ElevenLabsService.synthesizeCached('For God so loved the world'),
      throwsA(isA<ElevenLabsException>()),
    );
  });

  test('sends the expected request and writes the response to the cache',
      () async {
    ElevenLabsService.debugApiKeyOverride = 'test-key-123';
    final audioBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    http.Request? sentRequest;

    ElevenLabsCore.debugHttpClientOverride = MockClient((request) async {
      sentRequest = request;
      return http.Response.bytes(
        audioBytes,
        200,
        headers: {'content-type': 'audio/mpeg'},
      );
    });

    final file = await ElevenLabsService.synthesizeCached('Test verse text');

    expect(sentRequest, isNotNull);
    expect(sentRequest!.method, 'POST');
    expect(
      sentRequest!.url.toString(),
      startsWith('https://api.elevenlabs.io/v1/text-to-speech/'),
    );
    expect(sentRequest!.headers['xi-api-key'], 'test-key-123');
    final body = jsonDecode(sentRequest!.body) as Map;
    expect(body['text'], 'Test verse text');
    expect(body['model_id'], isNotEmpty);

    expect(await file.exists(), isTrue);
    expect(await file.readAsBytes(), audioBytes);
  });

  test('a second call for the same text is served from the cache, not the network',
      () async {
    ElevenLabsService.debugApiKeyOverride = 'test-key-123';
    var callCount = 0;
    ElevenLabsCore.debugHttpClientOverride = MockClient((request) async {
      callCount++;
      return http.Response.bytes([9, 9, 9], 200);
    });

    final first = await ElevenLabsService.synthesizeCached('Repeatable verse');
    final second = await ElevenLabsService.synthesizeCached('Repeatable verse');

    expect(callCount, 1);
    expect(second.path, first.path);
  });

  test('different text produces a different cache entry (and a new call)',
      () async {
    ElevenLabsService.debugApiKeyOverride = 'test-key-123';
    var callCount = 0;
    ElevenLabsCore.debugHttpClientOverride = MockClient((request) async {
      callCount++;
      return http.Response.bytes([callCount], 200);
    });

    final a = await ElevenLabsService.synthesizeCached('Verse A');
    final b = await ElevenLabsService.synthesizeCached('Verse B');

    expect(callCount, 2);
    expect(a.path, isNot(b.path));
  });

  test('a non-200 response throws with the API\'s own error message',
      () async {
    ElevenLabsService.debugApiKeyOverride = 'bad-key';
    ElevenLabsCore.debugHttpClientOverride = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'detail': {'status': 'invalid_api_key', 'message': 'Invalid API key'},
        }),
        401,
      );
    });

    await expectLater(
      () => ElevenLabsService.synthesizeCached('Any text'),
      throwsA(
        isA<ElevenLabsException>()
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.message, 'message', contains('Invalid API key')),
      ),
    );
  });

  test('a network-level failure (no response at all) is wrapped, not rethrown raw',
      () async {
    ElevenLabsService.debugApiKeyOverride = 'test-key-123';
    ElevenLabsCore.debugHttpClientOverride = MockClient((request) async {
      throw const SocketException('no route to host');
    });

    await expectLater(
      () => ElevenLabsService.synthesizeCached('Any text'),
      throwsA(isA<ElevenLabsException>()),
    );
  });
}
