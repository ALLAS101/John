// Verifies the Listen button's text-to-speech wiring end-to-end at the
// AppState level: since there's no real TTS engine in the test environment,
// this mocks the `flutter_tts` platform channel's *outgoing* calls (speak,
// stop, setLanguage, getVoices, ...) and then simulates the *incoming*
// native callbacks (speak.onStart / speak.onProgress / speak.onComplete /
// speak.onError) that a real engine would send back — the same technique
// flutter_tts's own plugin tests use — so the assertions exercise AppState's
// actual handler logic rather than trusting it by inspection.
//
// The verse is read as two utterances (the verse text, then the reference +
// translation) with a short pause between them — see AppState's "Verse
// playback" section for why. Every test here sets `interSegmentPause` to
// zero so it doesn't wait on a real timer, then explicitly pumps the event
// queue (`_pump()`) after each segment completes to let that (now instant)
// timer fire before simulating the next segment's callbacks.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:john316/state/app_state.dart';

const _channel = MethodChannel('flutter_tts');
const _codec = StandardMethodCodec();

/// Simulates the native side invoking one of flutter_tts's callback methods
/// (as if speech had actually started/progressed/finished on-device).
Future<void> _simulateNativeCall(String method, [Object? arguments]) async {
  final data = _codec.encodeMethodCall(MethodCall(method, arguments));
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(_channel.name, data, (_) {});
}

/// Lets a zero-duration `Timer` (the inter-segment pause, with
/// [AppState.interSegmentPause] set to [Duration.zero] in these tests) fire
/// before the test moves on to simulating the next segment.
Future<void> _pump() => Future<void>.delayed(Duration.zero);

/// Advances past the verse segment: simulates its start, then its
/// completion, then pumps so AppState's zero-duration pause timer fires and
/// the attribution segment's `speak()` call actually goes out.
Future<void> _finishVerseSegment() async {
  await _simulateNativeCall('speak.onStart');
  await _simulateNativeCall('speak.onComplete');
  await _pump();
}

/// Advances past the attribution segment, which is the last one — after
/// this, AppState considers playback fully done.
Future<void> _finishAttributionSegment() async {
  await _simulateNativeCall('speak.onStart');
  await _simulateNativeCall('speak.onComplete');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Accept every outgoing flutter_tts call (speak, stop, setLanguage,
    // getVoices, ...) with a benign success value, so AppState's calls into
    // the plugin don't throw MissingPluginException. `getVoices` returning
    // `1` (not a List) makes `_selectBestVoice` a harmless no-op for tests
    // that don't care about voice selection — see the dedicated test below
    // for that.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async => 1);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  test('starting playback flips isPlayingVerse once the engine reports start',
      () async {
    final state = await AppState.create()..interSegmentPause = Duration.zero;
    expect(state.isPlayingVerse, isFalse);

    final playFuture = state.toggleVersePlayback();
    // Real engines start asynchronously — AppState shouldn't claim it's
    // playing until the "speak.onStart" callback actually arrives.
    expect(state.isPlayingVerse, isFalse);

    await _simulateNativeCall('speak.onStart');
    expect(state.isPlayingVerse, isTrue);
    expect(state.ttsError, isNull);
    await playFuture;

    // One segment down, one to go — still playing.
    await _finishVerseSegment();
    expect(state.isPlayingVerse, isTrue);

    await _finishAttributionSegment();
    expect(state.isPlayingVerse, isFalse);
    expect(state.versePlaybackProgress, 0);
  });

  test('progress is a 0-1 fraction spanning both segments, in order',
      () async {
    final state = await AppState.create()..interSegmentPause = Duration.zero;
    final verseText = state.verseOfDay.text;
    final attributionText =
        '${state.verseOfDay.reference}, ${state.verseOfDay.translation}.';
    final totalChars = verseText.length + attributionText.length;

    unawaited(state.toggleVersePlayback());
    // Lets toggleVersePlayback's own setup (_ensureTtsReady, then computing
    // the segment lengths) finish before a simulated callback arrives — a
    // real engine could never call back this fast, since it can't call
    // onStart before AppState has even called speak().
    await _pump();
    await _simulateNativeCall('speak.onStart');

    // Midway through the verse segment: progress is relative to the
    // *combined* length, not just this segment's.
    await _simulateNativeCall('speak.onProgress', {
      'text': verseText,
      'start': 0,
      'end': verseText.length ~/ 2,
      'word': 'God',
    });
    expect(
      state.versePlaybackProgress,
      closeTo((verseText.length / 2) / totalChars, 0.01),
    );

    // End of the verse segment: progress reflects exactly that boundary.
    await _simulateNativeCall('speak.onProgress', {
      'text': verseText,
      'start': 0,
      'end': verseText.length,
      'word': 'life.',
    });
    expect(state.versePlaybackProgress, closeTo(verseText.length / totalChars, 0.001));

    await _simulateNativeCall('speak.onComplete');
    await _pump();
    await _simulateNativeCall('speak.onStart');

    // Partway through the attribution segment: the verse's length carries
    // forward as a base offset.
    await _simulateNativeCall('speak.onProgress', {
      'text': attributionText,
      'start': 0,
      'end': attributionText.length,
      'word': 'Version.',
    });
    expect(state.versePlaybackProgress, closeTo(1.0, 0.001));

    await _simulateNativeCall('speak.onComplete');
    expect(state.isPlayingVerse, isFalse);
    expect(state.versePlaybackProgress, 0);
  });

  test('stopVersePlayback calls stop() and resets state immediately',
      () async {
    final state = await AppState.create()..interSegmentPause = Duration.zero;
    unawaited(state.toggleVersePlayback());
    // Lets toggleVersePlayback's own setup (_ensureTtsReady, then computing
    // the segment lengths) finish before a simulated callback arrives — a
    // real engine could never call back this fast, since it can't call
    // onStart before AppState has even called speak().
    await _pump();
    await _simulateNativeCall('speak.onStart');
    expect(state.isPlayingVerse, isTrue);

    await state.stopVersePlayback();
    expect(state.isPlayingVerse, isFalse);
    expect(state.versePlaybackProgress, 0);
  });

  test('stopping during the pause between segments does not resume speaking',
      () async {
    final state = await AppState.create()
      ..interSegmentPause = const Duration(milliseconds: 50);
    unawaited(state.toggleVersePlayback());
    // Lets toggleVersePlayback's own setup (_ensureTtsReady, then computing
    // the segment lengths) finish before a simulated callback arrives — a
    // real engine could never call back this fast, since it can't call
    // onStart before AppState has even called speak().
    await _pump();
    await _simulateNativeCall('speak.onStart');
    await _simulateNativeCall('speak.onComplete'); // now mid-pause
    expect(state.isPlayingVerse, isTrue); // one segment still pending

    await state.stopVersePlayback();
    expect(state.isPlayingVerse, isFalse);

    // Let the (already-scheduled) pause timer's deadline pass — it must not
    // resurrect playback now that the segment queue was cleared by stop().
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(state.isPlayingVerse, isFalse);
  });

  test('tapping Listen again while playing stops instead of restarting',
      () async {
    final state = await AppState.create()..interSegmentPause = Duration.zero;
    unawaited(state.toggleVersePlayback());
    // Lets toggleVersePlayback's own setup (_ensureTtsReady, then computing
    // the segment lengths) finish before a simulated callback arrives — a
    // real engine could never call back this fast, since it can't call
    // onStart before AppState has even called speak().
    await _pump();
    await _simulateNativeCall('speak.onStart');
    expect(state.isPlayingVerse, isTrue);

    // Second call is the same "toggle" the UI sends on a second tap.
    await state.toggleVersePlayback();
    expect(state.isPlayingVerse, isFalse);
  });

  test('an engine error surfaces a plain-language ttsError and resets state',
      () async {
    final state = await AppState.create()..interSegmentPause = Duration.zero;
    unawaited(state.toggleVersePlayback());
    // Lets toggleVersePlayback's own setup (_ensureTtsReady, then computing
    // the segment lengths) finish before a simulated callback arrives — a
    // real engine could never call back this fast, since it can't call
    // onStart before AppState has even called speak().
    await _pump();
    await _simulateNativeCall('speak.onStart');
    expect(state.isPlayingVerse, isTrue);

    await _simulateNativeCall('speak.onError', 'synthesis failed');
    expect(state.isPlayingVerse, isFalse);
    expect(state.versePlaybackProgress, 0);
    expect(state.ttsError, isNotNull);

    state.dismissTtsError();
    expect(state.ttsError, isNull);
  });

  test('listening to the verse registers the daily streak engagement',
      () async {
    final state = await AppState.create()..interSegmentPause = Duration.zero;
    final before = state.streak;

    // Awaited (unlike the other tests): registerEngagementToday() runs
    // after the setup awaits inside toggleVersePlayback, so proving it ran
    // means letting the whole call settle rather than only reacting to the
    // onStart callback.
    final playback = state.toggleVersePlayback();
    await _simulateNativeCall('speak.onStart');
    await playback;

    expect(state.streak, before + 1);
  });

  test('picks the highest-quality offline English voice available',
      () async {
    final setVoiceCalls = <Map>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      if (call.method == 'getVoices') {
        return [
          {'name': 'fr-basic', 'locale': 'fr-FR', 'quality': 'high'},
          {'name': 'en-low', 'locale': 'en-US', 'quality': 'low'},
          {
            'name': 'en-cloud-premium',
            'locale': 'en-US',
            'quality': 'very high',
            'network_required': '1',
          },
          {
            'name': 'en-ondevice-high',
            'locale': 'en-GB',
            'quality': 'high',
            'network_required': '0',
          },
        ];
      }
      if (call.method == 'setVoice') {
        setVoiceCalls.add((call.arguments as Map).cast<String, dynamic>());
      }
      return 1;
    });

    final state = await AppState.create()..interSegmentPause = Duration.zero;
    unawaited(state.toggleVersePlayback());
    await _pump();

    // Between the two English candidates, "en-ondevice-high" wins: its raw
    // quality is lower than the cloud voice's "very high", but staying
    // on-device (Listen keeps working offline) outweighs that gap; the
    // French voice is never a candidate regardless of quality.
    expect(setVoiceCalls, hasLength(1));
    expect(setVoiceCalls.single['name'], 'en-ondevice-high');
  });
}
