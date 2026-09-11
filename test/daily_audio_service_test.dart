// Verifies DailyAudioService's request shape, error handling, and disk
// caching — by mocking `http.Client` and using a real temp directory,
// mirroring test/eleven_labs_service_test.dart.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:john316/services/daily_audio_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('daily_audio_test');
    DailyAudioService.debugCacheDirectoryOverride = tempDir;
  });

  tearDown(() async {
    DailyAudioService.debugBaseUrlOverride = null;
    DailyAudioService.debugHttpClientOverride = null;
    DailyAudioService.debugCacheDirectoryOverride = null;
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('isConfigured reflects the (overridable) base URL', () {
    DailyAudioService.debugBaseUrlOverride = '';
    expect(DailyAudioService.isConfigured, isFalse);

    DailyAudioService.debugBaseUrlOverride = 'https://example.github.io/app/audio';
    expect(DailyAudioService.isConfigured, isTrue);
  });

  test('fetchCached throws without a base URL configured', () async {
    DailyAudioService.debugBaseUrlOverride = '';
    expect(
      () => DailyAudioService.fetchCached(0),
      throwsA(isA<DailyAudioException>()),
    );
  });

  test('fetches the expected per-index URL and caches the response',
      () async {
    DailyAudioService.debugBaseUrlOverride = 'https://example.github.io/app/audio';
    final audioBytes = [1, 2, 3, 4, 5];
    http.Request? sentRequest;

    DailyAudioService.debugHttpClientOverride = MockClient((request) async {
      sentRequest = request;
      return http.Response.bytes(audioBytes, 200);
    });

    final file = await DailyAudioService.fetchCached(3);

    expect(sentRequest, isNotNull);
    expect(sentRequest!.method, 'GET');
    expect(
      sentRequest!.url.toString(),
      'https://example.github.io/app/audio/verse-3.mp3',
    );
    expect(await file.exists(), isTrue);
    expect(await file.readAsBytes(), audioBytes);
  });

  test('a second call for the same index is served from the cache, not the '
      'network', () async {
    DailyAudioService.debugBaseUrlOverride = 'https://example.github.io/app/audio';
    var callCount = 0;
    DailyAudioService.debugHttpClientOverride = MockClient((request) async {
      callCount++;
      return http.Response.bytes([9, 9, 9], 200);
    });

    final first = await DailyAudioService.fetchCached(1);
    final second = await DailyAudioService.fetchCached(1);

    expect(callCount, 1);
    expect(second.path, first.path);
  });

  test('different indices are cached separately', () async {
    DailyAudioService.debugBaseUrlOverride = 'https://example.github.io/app/audio';
    DailyAudioService.debugHttpClientOverride = MockClient((request) async {
      return http.Response.bytes([1], 200);
    });

    final a = await DailyAudioService.fetchCached(0);
    final b = await DailyAudioService.fetchCached(1);

    expect(a.path, isNot(b.path));
  });

  test('a 404 (not yet published for this index) throws, not published',
      () async {
    DailyAudioService.debugBaseUrlOverride = 'https://example.github.io/app/audio';
    DailyAudioService.debugHttpClientOverride = MockClient((request) async {
      return http.Response('not found', 404);
    });

    await expectLater(
      () => DailyAudioService.fetchCached(99),
      throwsA(
        isA<DailyAudioException>().having(
          (e) => e.statusCode,
          'statusCode',
          404,
        ),
      ),
    );
  });

  test('a network-level failure is wrapped, not rethrown raw', () async {
    DailyAudioService.debugBaseUrlOverride = 'https://example.github.io/app/audio';
    DailyAudioService.debugHttpClientOverride = MockClient((request) async {
      throw const SocketException('no route to host');
    });

    await expectLater(
      () => DailyAudioService.fetchCached(0),
      throwsA(isA<DailyAudioException>()),
    );
  });
}
