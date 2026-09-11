// Verifies AppState's three-tier Listen orchestration: try the shared
// pre-generated daily audio first, then ElevenLabs-direct, then the
// on-device voice — silently falling through on any failure, and only
// surfacing an error once *every* tier has failed.
//
// Mocks three platform channels: 'flutter_tts' (the on-device fallback),
// 'xyz.luan/audioplayers' (playback of a fetched/generated audio file — see
// audioplayers_platform_interface's MethodChannelAudioplayersPlatform for
// the channel name), and both DailyAudioService's and ElevenLabsService's
// own http.Client/cache-dir/config test hooks (no real network or
// path_provider platform channel needed).

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:john316/services/daily_audio_service.dart';
import 'package:john316/services/eleven_labs_core.dart';
import 'package:john316/services/eleven_labs_service.dart';
import 'package:john316/state/app_state.dart';

const _ttsChannel = MethodChannel('flutter_tts');
const _audioplayersChannel = MethodChannel('xyz.luan/audioplayers');
const _audioplayersGlobalChannel = MethodChannel('xyz.luan/audioplayers.global');
const _codec = StandardMethodCodec();

/// Fixed so tests can address this specific player's event channel —
/// `AudioPlayer`'s default `playerId` is a random UUID a test has no way to
/// know in advance.
const _testPlayerId = 'test-player';
const _playerEventsChannelName = 'xyz.luan/audioplayers/events/$_testPlayerId';

Future<void> _simulateTtsCall(String method, [Object? arguments]) async {
  final data = _codec.encodeMethodCall(MethodCall(method, arguments));
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(_ttsChannel.name, data, (_) {});
}

/// Simulates the native side emitting an audioplayers event (e.g.
/// `audio.onPrepared`) on the fixed test player's event channel — see
/// audioplayers_platform_interface's `EventChannelAudioplayersPlatform` for
/// the event shape.
Future<void> _simulateAudioEvent(Map<String, dynamic> event) async {
  final data = _codec.encodeSuccessEnvelope(event);
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(_playerEventsChannelName, data, (_) {});
}

Future<void> _pump() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempCacheDir;
  late Directory tempDailyAudioCacheDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempCacheDir = await Directory.systemTemp.createTemp('eleven_labs_test');
    ElevenLabsService.debugCacheDirectoryOverride = tempCacheDir;
    tempDailyAudioCacheDir =
        await Directory.systemTemp.createTemp('daily_audio_test');
    DailyAudioService.debugCacheDirectoryOverride = tempDailyAudioCacheDir;
    AppState.debugAudioPlayerIdOverride = _testPlayerId;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_ttsChannel, (call) async => 1);
    // audioplayers' outgoing calls (create/setSourceDeviceFile/resume/...)
    // are all void or accept a null response. Two channels: the per-player
    // one, and a separate one-time global-setup channel `AudioPlayer.play`
    // calls into before anything else.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_audioplayersChannel, (call) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_audioplayersGlobalChannel, (call) async => null);
  });

  tearDown(() async {
    AppState.debugAudioPlayerIdOverride = null;
    ElevenLabsService.debugApiKeyOverride = null;
    ElevenLabsCore.debugHttpClientOverride = null;
    ElevenLabsService.debugCacheDirectoryOverride = null;
    DailyAudioService.debugBaseUrlOverride = null;
    DailyAudioService.debugHttpClientOverride = null;
    DailyAudioService.debugCacheDirectoryOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_ttsChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_audioplayersChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_audioplayersGlobalChannel, null);
    if (await tempCacheDir.exists()) {
      await tempCacheDir.delete(recursive: true);
    }
    if (await tempDailyAudioCacheDir.exists()) {
      await tempDailyAudioCacheDir.delete(recursive: true);
    }
  });

  test(
      'with no ElevenLabs key configured, Listen goes straight to the '
      'on-device voice', () async {
    ElevenLabsService.debugApiKeyOverride = '';
    final state = await AppState.create()..interSegmentPause = Duration.zero;

    unawaited(state.toggleVersePlayback());
    await _pump();
    expect(state.isPreparingVerseAudio, isFalse);

    await _simulateTtsCall('speak.onStart');
    expect(state.isPlayingVerse, isTrue);
  });

  test(
      'when ElevenLabs is configured and succeeds, it plays without ever '
      'touching the on-device engine', () async {
    ElevenLabsService.debugApiKeyOverride = 'test-key';
    ElevenLabsCore.debugHttpClientOverride = MockHttpClient(
      (request) async => http.Response.bytes([1, 2, 3], 200),
    );
    final ttsCalls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_ttsChannel, (call) async {
      ttsCalls.add(call.method);
      return 1;
    });

    final state = await AppState.create();
    final playback = state.toggleVersePlayback();
    // AudioPlayer.play() waits for a native "prepared" event before it
    // resolves (with its own 30s timeout otherwise). Getting there first
    // goes through ElevenLabsService's disk cache check, then AudioPlayer's
    // own async construction (global init, per-player create) before it's
    // even listening for this event — generous margin here costs nothing
    // but test wall-clock time, and this is run once.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await _simulateAudioEvent({'event': 'audio.onPrepared', 'value': true});
    await playback;

    expect(state.isPlayingVerse, isTrue);
    expect(state.isPreparingVerseAudio, isFalse);
    expect(ttsCalls, isEmpty); // fallback engine was never touched
  });

  test('a failed ElevenLabs request falls back to the on-device voice',
      () async {
    ElevenLabsService.debugApiKeyOverride = 'test-key';
    ElevenLabsCore.debugHttpClientOverride = MockHttpClient(
      (request) async => http.Response('server error', 500),
    );
    final state = await AppState.create()..interSegmentPause = Duration.zero;

    unawaited(state.toggleVersePlayback());
    // Lets the failed ElevenLabs attempt resolve before the fallback's own
    // speak() call goes out — real (if tiny) disk I/O is involved
    // (ElevenLabsService checks the cache directory), so this needs an
    // actual elapsed delay, not just a microtask-queue pump.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(state.isPreparingVerseAudio, isFalse);
    expect(state.ttsError, isNull); // one tier failing is not user-visible

    await _simulateTtsCall('speak.onStart');
    expect(state.isPlayingVerse, isTrue);
  });

  test('stopping while ElevenLabs is preparing cancels cleanly, with no '
      'fallback and no error', () async {
    ElevenLabsService.debugApiKeyOverride = 'test-key';
    final gate = Completer<http.Response>();
    ElevenLabsCore.debugHttpClientOverride = MockHttpClient(
      (request) => gate.future,
    );
    final ttsCalls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_ttsChannel, (call) async {
      ttsCalls.add(call.method);
      return 1;
    });

    final state = await AppState.create();
    final playback = state.toggleVersePlayback();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(state.isPreparingVerseAudio, isTrue);

    await state.stopVersePlayback();
    expect(state.isPlayingVerse, isFalse);
    expect(state.isPreparingVerseAudio, isFalse);

    // The network call finally resolves after the user already stopped —
    // must not resurrect playback or fall back to the on-device engine.
    gate.complete(http.Response.bytes([1, 2, 3], 200));
    await playback;
    await _pump();
    expect(state.isPlayingVerse, isFalse);
    // stopVersePlayback() defensively calls tts.stop() regardless of which
    // tier was active (harmless no-op on the inactive one) — what actually
    // matters is that it never *started* speaking via the fallback engine.
    expect(ttsCalls.contains('speak'), isFalse);
  });

  test('an error surfaces only once both tiers have failed', () async {
    ElevenLabsService.debugApiKeyOverride = 'test-key';
    ElevenLabsCore.debugHttpClientOverride = MockHttpClient(
      (request) async => http.Response('server error', 500),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_ttsChannel, (call) async {
      if (call.method == 'speak') {
        throw PlatformException(code: 'no_engine');
      }
      return 1;
    });

    final state = await AppState.create()..interSegmentPause = Duration.zero;
    await state.toggleVersePlayback();

    expect(state.isPlayingVerse, isFalse);
    expect(state.ttsError, isNotNull);
  });

  test(
      'when shared daily audio is configured and succeeds, it plays without '
      'ever touching ElevenLabs or the on-device engine', () async {
    DailyAudioService.debugBaseUrlOverride = 'https://example.github.io/app/audio';
    var elevenLabsCalls = 0;
    ElevenLabsCore.debugHttpClientOverride = MockHttpClient((request) async {
      elevenLabsCalls++;
      return http.Response.bytes([1, 2, 3], 200);
    });
    DailyAudioService.debugHttpClientOverride = MockHttpClient(
      (request) async => http.Response.bytes([1, 2, 3], 200),
    );
    final ttsCalls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_ttsChannel, (call) async {
      ttsCalls.add(call.method);
      return 1;
    });

    final state = await AppState.create();
    final playback = state.toggleVersePlayback();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await _simulateAudioEvent({'event': 'audio.onPrepared', 'value': true});
    await playback;

    expect(state.isPlayingVerse, isTrue);
    expect(elevenLabsCalls, 0); // never even attempted
    expect(ttsCalls, isEmpty);
  });

  test(
      'when shared daily audio fails, it falls back to ElevenLabs before '
      'the on-device engine', () async {
    DailyAudioService.debugBaseUrlOverride = 'https://example.github.io/app/audio';
    DailyAudioService.debugHttpClientOverride = MockHttpClient(
      (request) async => http.Response('not found', 404),
    );
    ElevenLabsService.debugApiKeyOverride = 'test-key';
    ElevenLabsCore.debugHttpClientOverride = MockHttpClient(
      (request) async => http.Response.bytes([1, 2, 3], 200),
    );
    final ttsCalls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_ttsChannel, (call) async {
      ttsCalls.add(call.method);
      return 1;
    });

    final state = await AppState.create();
    final playback = state.toggleVersePlayback();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await _simulateAudioEvent({'event': 'audio.onPrepared', 'value': true});
    await playback;

    expect(state.isPlayingVerse, isTrue);
    expect(ttsCalls, isEmpty); // still never reached the third tier
  });

  test(
      'when both shared daily audio and ElevenLabs fail, it falls back to '
      'the on-device engine', () async {
    DailyAudioService.debugBaseUrlOverride = 'https://example.github.io/app/audio';
    DailyAudioService.debugHttpClientOverride = MockHttpClient(
      (request) async => http.Response('not found', 404),
    );
    ElevenLabsService.debugApiKeyOverride = 'test-key';
    ElevenLabsCore.debugHttpClientOverride = MockHttpClient(
      (request) async => http.Response('server error', 500),
    );

    final state = await AppState.create()..interSegmentPause = Duration.zero;
    unawaited(state.toggleVersePlayback());
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(state.isPreparingVerseAudio, isFalse);
    expect(state.ttsError, isNull); // two tiers failing is still not an error

    await _simulateTtsCall('speak.onStart');
    expect(state.isPlayingVerse, isTrue);
  });
}

/// Minimal stand-in for `package:http/testing.dart`'s `MockClient` (used
/// instead of that class to avoid depending on a request's body being
/// read exactly once, which matters less here than being explicit about
/// what's mocked).
class MockHttpClient extends http.BaseClient {
  MockHttpClient(this._handler);

  final Future<http.Response> Function(http.Request request) _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _handler(request as http.Request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}
