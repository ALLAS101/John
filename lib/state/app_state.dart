import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/app_tab.dart';
import '../models/journal_entry.dart';
import '../models/plan_day.dart';
import '../models/verse.dart';
import '../services/daily_audio_service.dart';
import '../services/eleven_labs_service.dart';

/// The key everything is stored under in `shared_preferences` — one JSON
/// blob, since this is small, single-user, device-local state rather than
/// something that needs querying.
const _storageKey = 'john316_state_v1';

/// App-wide state (see the design README's "State Management" table):
/// streak, saved-verse toggle, journal entries + draft, and plan progress.
///
/// Persisted locally via `shared_preferences` (a JSON blob under
/// [_storageKey]) so the app survives a restart. This is still a stand-in
/// for the design's real intent — journal entries encrypted if synced, plan
/// progress synced to the user's account, verse of the day fetched and
/// cached from a server — but it's no longer lost the moment the app
/// closes.
///
/// Construct with [AppState.create], not the default constructor directly,
/// so persisted state has a chance to load before the first frame.
class AppState extends ChangeNotifier {
  AppState._();

  /// Creates an [AppState] and loads any persisted data before returning it.
  static Future<AppState> create() async {
    final state = AppState._();
    await state._load();
    return state;
  }

  SharedPreferences? _prefs;
  Timer? _saveDebounce;

  // -- Navigation -----------------------------------------------------------

  AppTab activeTab = AppTab.today;

  void setActiveTab(AppTab tab) {
    activeTab = tab;
    _save();
    notifyListeners();
  }

  // -- Identity / greeting -------------------------------------------------

  String userName = 'Thabo';

  // -- Today ---------------------------------------------------------------

  /// Cycles through [Verse.dailyVerses] by day-of-year — see that field's
  /// doc comment. A getter (not cached at construction) so it stays correct
  /// across a real calendar-day rollover in a long-lived app session.
  Verse get verseOfDay => Verse.forDate(DateTime.now());

  int streak = 12;
  bool isSaved = true;

  void toggleSaved() {
    isSaved = !isSaved;
    _save();
    notifyListeners();
  }

  /// Bumps the streak once per calendar day the user engages with Today
  /// (reads the verse or writes an entry). Called from the screens; guarded
  /// here so repeated calls in one day are no-ops.
  DateTime? _lastStreakDay;
  void registerEngagementToday() {
    final today = DateTime.now();
    final key = DateTime(today.year, today.month, today.day);
    if (_lastStreakDay == key) return;
    _lastStreakDay = key;
    streak += 1;
    _save();
    notifyListeners();
  }

  // -- Verse playback ---------------------------------------------------------
  //
  // The design calls for an "audio track" of the verse; no recorded
  // narration ships with the app (there is no `audioUrl` for `Verse.ofTheDay`
  // to point at), so Listen has to synthesize something instead of being a
  // no-op. Three tiers, tried in order:
  //
  // 1. **Shared daily audio** (`_playViaDailyAudio`), when configured —
  //    today's verse, read aloud by ElevenLabs *once* by
  //    `tool/generate_daily_audio.dart` (via a scheduled GitHub Action) and
  //    published for every user's app to download and cache, rather than
  //    each device separately paying for (and waiting on) its own
  //    ElevenLabs call for identical content. Needs `DAILY_AUDIO_BASE_URL`
  //    set at build time (see DailyAudioService's doc comment and the
  //    top-level README's "Shared daily audio" section); with no URL
  //    configured, this tier is skipped entirely, silently.
  // 2. **ElevenLabs direct** (`_playViaElevenLabs`), when configured — the
  //    same real human-sounding cloud voice, called from *this* device,
  //    for whenever tier 1 isn't configured or doesn't have today's verse
  //    yet. Needs `ELEVENLABS_API_KEY` set at build time (see
  //    ElevenLabsService's doc comment); generated audio is cached to disk
  //    (keyed by voice + exact text) so the same verse is only ever
  //    synthesized once *by this device*.
  // 3. **On-device TTS** (`_playViaOnDeviceTts`) — the fallback, and the
  //    only tier at all on a build with neither of the above configured.
  //    Two things push this past "just call speak()":
  //    - **Voice**: most platforms ship several TTS voices of varying
  //      quality for the same language (Android in particular — a phone
  //      can have a "very high" quality neural voice installed alongside
  //      the older "normal"/"low" ones, but a bare `speak()` call uses
  //      whatever the system default happens to be, often not the best
  //      one). `_selectBestVoice` asks the engine for all of them and
  //      switches to the highest-quality English voice, still fully
  //      on-device/offline.
  //    - **Pacing**: reading "...everlasting life. John 3:16, King James
  //      Version." as one run-on utterance sounds rushed. The verse and its
  //      attribution are spoken as two separate utterances with a short
  //      pause between them, which reads far more like a calm, deliberate
  //      narration.
  //
  // Any failure in tier 1 or 2 — not configured, no network, a bad
  // response, playback erroring — falls through to the next tier rather
  // than surfacing an error; only once *every* tier has failed does the
  // user see one. Tiers 1 and 2 share `_playAudioSource` (obtain a playable
  // `Source` — a cached file, or on web a URL/raw bytes — play it, track
  // progress) since they only differ in *how* they get that source; tier 3
  // is different enough (utterance-based, not source-based) to stay its own
  // thing.
  //
  // No tier reliably resumes from a paused position (true of on-device
  // engines especially), so "Pause" stops playback outright rather than
  // faking a resume — tapping Listen again starts the verse over from the
  // beginning.

  // `late`: both FlutterTts's and AudioPlayer's constructors touch the
  // platform-channel binary messenger immediately, which doesn't exist yet
  // in a plain `test()` that never spins up the Flutter binding (unlike
  // `testWidgets()`, which does). Deferring construction to first real use
  // means AppState.create() stays safe to call from tests that never touch
  // playback.
  late final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;
  /// Test-only fixed player ID — `AudioPlayer`'s default is a random UUID,
  /// which a test can't know in advance in order to simulate that specific
  /// player's native events (the "prepared" event in particular; without
  /// it, `AudioPlayer.play()` doesn't resolve until its own 30s timeout).
  @visibleForTesting
  static String? debugAudioPlayerIdOverride;

  late final AudioPlayer _audioPlayer = AudioPlayer(
    playerId: debugAudioPlayerIdOverride,
  );
  bool _audioPlayerReady = false;
  Duration? _audioDuration;

  bool isPlayingVerse = false;

  /// True only while an ElevenLabs request is in flight — a brief loading
  /// state (cache hits are instant; a fresh synthesis is a network round
  /// trip) distinct from [isPlayingVerse] so the Listen button can show it
  /// rather than looking unresponsive for a second or two.
  bool isPreparingVerseAudio = false;

  /// 0-1 fraction through the spoken audio — word-boundary callbacks from
  /// the on-device engine, or playback position/duration for ElevenLabs
  /// audio. Never a fixed-duration animation guess.
  double versePlaybackProgress = 0;

  /// Set when playback fails to start or is interrupted by an engine error
  /// — only once *both* tiers above have failed.
  String? ttsError;

  /// Invalidates an in-flight ElevenLabs request/continuation when the user
  /// stops playback before it resolves — incremented by [stopVersePlayback];
  /// a stale continuation checks it hasn't changed before touching state.
  int _playbackGeneration = 0;

  /// Beat of silence between the verse and its attribution, on the
  /// on-device tier. A mutable instance field (not a `const`) purely so
  /// tests can zero it out instead of a test waiting on a real 450ms timer.
  @visibleForTesting
  Duration interSegmentPause = const Duration(milliseconds: 450);

  /// Utterances still to be spoken for the current Listen press — normally
  /// `[verseText, attributionText]`, shrinking by one as each finishes. Used
  /// as the "are we still playing, and what's left" source of truth:
  /// emptied by [stopVersePlayback] so a completion callback that arrives
  /// after a stop is a no-op instead of restarting playback.
  final List<String> _pendingSegments = [];
  int _completedChars = 0;
  int _totalChars = 0;
  Timer? _segmentPauseTimer;

  /// Ranks flutter_tts's own quality vocabulary — Android's ("very
  /// high".."very low") and iOS/macOS's ("premium"/"enhanced"/"default") —
  /// onto one scale, so [_selectBestVoice] can compare voices the same way
  /// regardless of which platform reported them.
  static const _qualityRank = <String, int>{
    'premium': 5,
    'very high': 5,
    'enhanced': 4,
    'high': 4,
    'default': 2,
    'normal': 2,
    'low': 1,
    'very low': 0,
    'unknown': 1,
  };

  Future<void> _ensureTtsReady() async {
    if (_ttsReady) return;
    _ttsReady = true;
    _tts.setStartHandler(() {
      isPlayingVerse = true;
      ttsError = null;
      notifyListeners();
    });
    _tts.setCompletionHandler(_advanceToNextSegment);
    _tts.setCancelHandler(_resetPlayback);
    _tts.setErrorHandler((message) {
      _resetPlayback();
      ttsError = "Couldn't play the verse — please try again.";
      notifyListeners();
    });
    _tts.setProgressHandler((text, start, end, word) {
      if (_totalChars == 0) return;
      versePlaybackProgress = ((_completedChars + end) / _totalChars).clamp(
        0.0,
        1.0,
      );
      notifyListeners();
    });
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.44);
    } catch (_) {
      // Non-fatal — speak() still works with the engine's own defaults.
    }
    await _selectBestVoice();
  }

  /// Picks the highest-quality installed English voice and switches the
  /// engine to it. Best-effort: any failure (platform doesn't support voice
  /// listing, no English voice reported, ...) just leaves the engine on
  /// whatever its own default voice is.
  Future<void> _selectBestVoice() async {
    try {
      final raw = await _tts.getVoices;
      if (raw is! List) return;

      Map<String, String>? best;
      var bestScore = -1;
      for (final item in raw) {
        if (item is! Map) continue;
        final voice = item.map(
          (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
        );
        final locale = voice['locale'] ?? '';
        if (!locale.toLowerCase().startsWith('en')) continue;

        final qualityScore = _qualityRank[(voice['quality'] ?? '').toLowerCase()] ?? 1;
        // Staying on-device outranks a higher quality tier — the point of
        // this pass was a *free, offline* improvement, so a voice that
        // needs a network connection never wins over one that doesn't,
        // regardless of quality; quality only breaks ties within the same
        // connectivity class.
        final requiresNetwork = voice['network_required'] == '1';
        final score = (requiresNetwork ? 0 : 1000) + qualityScore;

        if (score > bestScore) {
          bestScore = score;
          best = voice;
        }
      }

      final name = best?['name'];
      if (name == null || name.isEmpty) return;
      await _tts.setVoice({
        'name': name,
        'locale': best?['locale'] ?? '',
        if ((best?['identifier'] ?? '').isNotEmpty)
          'identifier': best!['identifier']!,
      });
    } catch (_) {
      // Fine — the engine's own default voice is used instead.
    }
  }

  void _resetPlayback() {
    isPlayingVerse = false;
    isPreparingVerseAudio = false;
    versePlaybackProgress = 0;
    _pendingSegments.clear();
    _segmentPauseTimer?.cancel();
    _segmentPauseTimer = null;
    _audioDuration = null;
    notifyListeners();
  }

  Future<void> toggleVersePlayback() async {
    if (isPlayingVerse || isPreparingVerseAudio) {
      await stopVersePlayback();
      return;
    }
    ttsError = null;
    registerEngagementToday();

    final v = verseOfDay;
    final verseIndex = Verse.indexForDate(DateTime.now());
    final fullText = '${v.text} ${v.reference}, ${v.translation}.';

    // Falls through tiers silently on failure — see the "Verse playback"
    // doc comment for why. On web there's no `path_provider` disk cache to
    // write into (`getApplicationSupportDirectory` has no web
    // implementation), so each tier is played straight from memory/URL
    // instead of through a cached `File` — see `_playAudioSource`.
    if (DailyAudioService.isConfigured) {
      final played = kIsWeb
          ? await _playAudioSource(
              () async => UrlSource(DailyAudioService.urlFor(verseIndex)))
          : await _playAudioSource(() async => DeviceFileSource(
              (await DailyAudioService.fetchCached(verseIndex)).path));
      if (played) return;
    }
    if (ElevenLabsService.isConfigured) {
      final played = kIsWeb
          ? await _playAudioSource(() async =>
              BytesSource(await ElevenLabsService.synthesizeBytesOnly(fullText)))
          : await _playAudioSource(() async => DeviceFileSource(
              (await ElevenLabsService.synthesizeCached(fullText)).path));
      if (played) return;
    }

    await _playViaOnDeviceTts(v);
  }

  /// Obtains a playable [Source] via [obtainSource] and plays it through
  /// [_audioPlayer] — shared by the shared-daily-audio and ElevenLabs-direct
  /// tiers, which only differ in where the audio comes from (a cached file
  /// on non-web platforms; a URL or raw bytes on web, where there's no disk
  /// cache — see `toggleVersePlayback`). Returns true if playback actually
  /// started *or* the user stopped before it could (both mean "don't also
  /// try the next tier"); false means "this tier failed, try the next one".
  Future<bool> _playAudioSource(Future<Source> Function() obtainSource) async {
    final generation = ++_playbackGeneration;
    isPreparingVerseAudio = true;
    notifyListeners();

    Source? source;
    try {
      source = await obtainSource();
    } catch (e) {
      debugPrint('Audio tier unavailable, trying the next one: $e');
    }

    if (generation != _playbackGeneration) {
      // stopVersePlayback() ran while the request was in flight.
      return true; // not an error — don't also try the next tier
    }
    if (source == null) {
      isPreparingVerseAudio = false;
      notifyListeners();
      return false;
    }

    _ensureAudioPlayerReady();
    try {
      await _audioPlayer.play(source);
    } catch (e) {
      debugPrint('Playback failed, trying the next tier: $e');
      isPreparingVerseAudio = false;
      notifyListeners();
      return false;
    }
    if (generation != _playbackGeneration) {
      // Stopped between the play() call going out and it settling.
      try {
        await _audioPlayer.stop();
      } catch (_) {
        // Already stopped is fine.
      }
      return true;
    }

    isPreparingVerseAudio = false;
    isPlayingVerse = true;
    notifyListeners();
    return true;
  }

  void _ensureAudioPlayerReady() {
    if (_audioPlayerReady) return;
    _audioPlayerReady = true;
    // `onError: (_, _) {}` on all three: a transient hiccup on the
    // platform's position/duration/completion stream should never crash
    // playback — worst case, progress just stops updating.
    _audioPlayer.onDurationChanged.listen((duration) {
      _audioDuration = duration;
    }, onError: (_, _) {});
    _audioPlayer.onPositionChanged.listen((position) {
      final duration = _audioDuration;
      if (duration == null || duration.inMilliseconds <= 0) return;
      versePlaybackProgress = (position.inMilliseconds / duration.inMilliseconds)
          .clamp(0.0, 1.0);
      notifyListeners();
    }, onError: (_, _) {});
    _audioPlayer.onPlayerComplete.listen(
      (_) => _resetPlayback(),
      onError: (_, _) {},
    );
  }

  Future<void> _playViaOnDeviceTts(Verse v) async {
    await _ensureTtsReady();

    final verseSegment = v.text;
    final attributionSegment = '${v.reference}, ${v.translation}.';
    _pendingSegments
      ..clear()
      ..addAll([verseSegment, attributionSegment]);
    _completedChars = 0;
    _totalChars = verseSegment.length + attributionSegment.length;

    await _speakNextSegment();
  }

  Future<void> _speakNextSegment() async {
    if (_pendingSegments.isEmpty) return;
    try {
      await _tts.speak(_pendingSegments.first);
    } catch (_) {
      _resetPlayback();
      ttsError = "Couldn't play the verse — please try again.";
      notifyListeners();
    }
  }

  /// Called by the engine's completion handler after *every* utterance —
  /// i.e. once per segment, not once per Listen press.
  void _advanceToNextSegment() {
    if (_pendingSegments.isEmpty) return; // stopped already — ignore
    _completedChars += _pendingSegments.first.length;
    _pendingSegments.removeAt(0);
    if (_pendingSegments.isEmpty) {
      _resetPlayback();
      return;
    }
    _segmentPauseTimer?.cancel();
    _segmentPauseTimer = Timer(interSegmentPause, () {
      if (_pendingSegments.isEmpty) return; // stopped during the pause
      unawaited(_speakNextSegment());
    });
  }

  Future<void> stopVersePlayback() async {
    // Invalidates any in-flight ElevenLabs request/continuation — see
    // _playViaElevenLabs.
    _playbackGeneration++;
    _pendingSegments.clear();
    _segmentPauseTimer?.cancel();
    _segmentPauseTimer = null;
    // Both tiers' stop calls are harmless no-ops on whichever tier isn't
    // actually active — simpler than tracking which one is.
    try {
      await _tts.stop();
    } catch (_) {
      // Already stopped is fine.
    }
    if (_audioPlayerReady) {
      try {
        await _audioPlayer.stop();
      } catch (_) {
        // Already stopped is fine.
      }
    }
    _resetPlayback();
  }

  void dismissTtsError() {
    ttsError = null;
    notifyListeners();
  }

  // -- Journal ---------------------------------------------------------------

  final List<JournalEntry> _entries = [];
  List<JournalEntry> get entries => List.unmodifiable(
        [..._entries]..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );

  JournalTag draftTag = JournalTag.gratitude;
  String draftBody = '';

  /// The Today "Sit with it" reflection prompt, when the composer was opened
  /// from that link — shown above the composer as context, cleared once the
  /// entry is submitted or dismissed.
  String? journalPromptContext;

  void openJournalWithPrompt(String prompt) {
    journalPromptContext = prompt;
    activeTab = AppTab.journal;
    _save();
    notifyListeners();
  }

  void clearJournalPromptContext() {
    journalPromptContext = null;
    _save();
    notifyListeners();
  }

  void setDraftTag(JournalTag tag) {
    draftTag = tag;
    _save();
    notifyListeners();
  }

  void setDraftBody(String body) {
    draftBody = body;
    _save(debounce: true);
    notifyListeners();
  }

  void submitDraft() {
    final body = draftBody.trim();
    if (body.isEmpty) return;
    if (isListening) unawaited(stopDictation());
    _entries.add(
      JournalEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        body: body,
        tag: draftTag,
        createdAt: DateTime.now(),
      ),
    );
    draftBody = '';
    journalPromptContext = null;
    registerEngagementToday();
    _save();
    notifyListeners();
  }

  // -- Dictation (speech-to-text) --------------------------------------------
  //
  // "Hold mic to speak": press-and-hold starts dictation, streaming partial
  // transcript into the composer as it's recognized; release stops it. See
  // the Interactions section of the design README.

  final SpeechToText _speech = SpeechToText();
  bool _speechInitialized = false;
  bool isListening = false;
  String? _dictationPrefix;

  /// Set when dictation can't proceed (permission denied, no recognizer on
  /// this device, a recognition error) — a plain-language message for the
  /// Journal screen to surface near the mic button, per the design's "needs
  /// mic + speech-recognition permission with a plain-language prompt".
  String? micError;

  void dismissMicError() {
    micError = null;
    notifyListeners();
  }

  Future<void> startDictation() async {
    if (isListening) return;
    micError = null;

    try {
      if (!_speechInitialized) {
        _speechInitialized = await _speech.initialize(
          onStatus: _handleSpeechStatus,
          onError: _handleSpeechError,
        );
      }
      if (!_speechInitialized) {
        micError = "Couldn't reach speech recognition. Allow microphone and "
            "speech-recognition access in your device's Settings, then hold "
            "the mic again.";
        notifyListeners();
        return;
      }

      // Recognized speech replaces everything spoken so far in *this*
      // hold — it isn't a running diff — so anything already in the
      // composer before the hold started needs to be kept as a fixed
      // prefix we re-attach to each result.
      _dictationPrefix = draftBody.trim();
      isListening = true;
      notifyListeners();

      await _speech.listen(
        onResult: _handleSpeechResult,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
        ),
      );
    } catch (e, st) {
      // Covers both initialize() and listen() failing outright (as opposed
      // to reporting an error via onError) — e.g. no recognizer on this
      // device/browser, or a plugin-level platform exception.
      debugPrint('startDictation failed: $e\n$st');
      isListening = false;
      micError = "Dictation couldn't start — please try again.";
      notifyListeners();
    }
  }

  Future<void> stopDictation() async {
    _dictationPrefix = null;
    if (!isListening) return;
    isListening = false;
    notifyListeners();
    try {
      await _speech.stop();
    } catch (_) {
      // Already stopping/stopped is fine — nothing to surface to the user.
    }
    _save();
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    final prefix = _dictationPrefix ?? '';
    final heard = result.recognizedWords;
    draftBody = prefix.isEmpty ? heard : (heard.isEmpty ? prefix : '$prefix $heard');
    _save(debounce: true);
    notifyListeners();
  }

  void _handleSpeechStatus(String status) {
    // The platform can end a listen session on its own (e.g. silence
    // timeout) without a stopDictation() call — reflect that in the UI.
    if ((status == 'notListening' || status == 'done') && isListening) {
      isListening = false;
      _dictationPrefix = null;
      _save();
      notifyListeners();
    }
  }

  void _handleSpeechError(SpeechRecognitionError error) {
    isListening = false;
    _dictationPrefix = null;
    micError = _plainLanguageSpeechError(error);
    notifyListeners();
  }

  String _plainLanguageSpeechError(SpeechRecognitionError error) {
    final msg = error.errorMsg;
    if (msg.contains('permission')) {
      return 'John 3:16 needs microphone and speech-recognition access. '
          "Allow both in your device's Settings, then try again.";
    }
    if (msg.contains('network')) {
      return 'Speech recognition needs a network connection on this device.';
    }
    if (msg.contains('no_match') || msg.contains('speech_timeout')) {
      return "Didn't catch that — hold the mic and try again.";
    }
    return 'Something interrupted dictation — try again.';
  }

  // -- Plan ---------------------------------------------------------------

  /// Days 1-12 start completed, matching the reference mock's default
  /// progress (streak 12 / plan day 12) — only used on first launch, before
  /// anything has been persisted.
  final Set<int> completedDays = {for (var i = 1; i <= 12; i++) i};

  int get planDoneCount => completedDays.length;
  double get planProgress => planDoneCount / planDays.length;

  void togglePlanDay(int day) {
    if (!completedDays.add(day)) {
      completedDays.remove(day);
    }
    _save();
    notifyListeners();
  }

  // -- Persistence ----------------------------------------------------------

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      // First launch: seed a few sample entries so the Journal / Plan /
      // Today screens aren't empty on first open.
      _seedSampleData();
      return;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _applyJson(json);
    } catch (_) {
      // Corrupt or from an incompatible future version — start fresh rather
      // than crash on launch.
      _seedSampleData();
    }
  }

  void _seedSampleData() {
    _entries.addAll([
      JournalEntry(
        id: 'seed-1',
        body:
            'Thank You for the quiet before the house woke up. I needed it '
            'more than I knew.',
        tag: JournalTag.gratitude,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      JournalEntry(
        id: 'seed-2',
        body:
            'Be near my mother while she waits for her results. Steady her '
            'hands, and mine.',
        tag: JournalTag.request,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      JournalEntry(
        id: 'seed-3',
        body: 'The rain came. Everything smells like it has been forgiven.',
        tag: JournalTag.praise,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);
  }

  void _applyJson(Map<String, dynamic> json) {
    activeTab = appTabFromName(json['activeTab'] as String?);
    streak = json['streak'] as int? ?? streak;
    isSaved = json['isSaved'] as bool? ?? isSaved;
    final lastStreakDayRaw = json['lastStreakDay'] as String?;
    if (lastStreakDayRaw != null) {
      _lastStreakDay = DateTime.tryParse(lastStreakDayRaw);
    }
    draftTag = journalTagFromName(json['draftTag'] as String?);
    draftBody = json['draftBody'] as String? ?? '';
    journalPromptContext = json['journalPromptContext'] as String?;

    final entriesJson = json['entries'] as List<dynamic>?;
    if (entriesJson != null) {
      _entries
        ..clear()
        ..addAll(
          entriesJson
              .cast<Map<String, dynamic>>()
              .map(JournalEntry.fromJson),
        );
    }

    final completedJson = json['completedDays'] as List<dynamic>?;
    if (completedJson != null) {
      completedDays
        ..clear()
        ..addAll(completedJson.cast<int>());
    }
  }

  Map<String, dynamic> _toJson() => {
        'activeTab': activeTab.name,
        'streak': streak,
        'isSaved': isSaved,
        'lastStreakDay': _lastStreakDay?.toIso8601String(),
        'draftTag': draftTag.name,
        'draftBody': draftBody,
        'journalPromptContext': journalPromptContext,
        'entries': _entries.map((e) => e.toJson()).toList(),
        'completedDays': completedDays.toList(),
      };

  /// Writes the current state to disk. Rapid-fire callers (e.g. every
  /// keystroke in the composer) should pass [debounce] so writes coalesce
  /// into one after 400ms of quiet, rather than hitting the platform storage
  /// API on every character.
  void _save({bool debounce = false}) {
    final prefs = _prefs;
    if (prefs == null) return; // Not loaded yet — nothing to persist to.
    if (!debounce) {
      _saveDebounce?.cancel();
      unawaited(prefs.setString(_storageKey, jsonEncode(_toJson())));
      return;
    }
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(prefs.setString(_storageKey, jsonEncode(_toJson())));
    });
  }

  /// Cancels any pending debounced write and persists the current state
  /// immediately, awaiting completion. Mainly for tests (so a mutation is
  /// guaranteed to have hit storage before asserting on a fresh instance);
  /// production code doesn't need to await persistence to stay responsive.
  @visibleForTesting
  Future<void> flush() async {
    _saveDebounce?.cancel();
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_storageKey, jsonEncode(_toJson()));
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _segmentPauseTimer?.cancel();
    if (isListening) unawaited(_speech.stop());
    if (isPlayingVerse) unawaited(_tts.stop());
    if (_audioPlayerReady) unawaited(_audioPlayer.dispose());
    super.dispose();
  }
}
