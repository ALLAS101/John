# John 3:16

A daily verse and prayer journal. Four screens — **Today**, **Journal**,
**Plan**, **Widget** — under one bottom tab bar, in dark and light themes
that follow the system setting.

Built to match the high-fidelity design handoff in
`../design_handoff_john_3_16/` (see that folder's `README.md` for the full
design spec this implementation follows — colors, type, spacing, copy,
interactions).

## Structure

```
lib/
  main.dart                 App entry point, theme + Provider wiring
  models/                   Verse, JournalEntry, PlanDay, AppTab — plain data
  state/app_state.dart       App-wide state (ChangeNotifier): streak, saved
                             verse, journal entries + draft, plan progress
  theme/
    app_palette.dart         Dark/light design tokens as a ThemeExtension
    app_text_styles.dart     Lora/Inter text styles (exact weights via
                             FontVariation, incl. the spec's 450)
    app_theme.dart           ThemeData builder
  widgets/
    app_icons.dart           Hand-drawn line icons matching the design's SVGs
    app_tab_bar.dart         Bottom tab bar
    controls.dart            StreakPill, ListenButton, SaveButton, MicButton,
                             TagChip, InlineErrorBanner
    dawn_glow.dart           The Today screen's radial "dawn" glow
  screens/
    root_shell.dart          IndexedStack + tab bar (preserves per-tab scroll)
    today_screen.dart
    journal_screen.dart
    plan_screen.dart
    widget_screen.dart        In-app preview/picker for the two widget sizes
  services/
    home_widget_service.dart  Bridges AppState to the native home-screen
                              widgets (see "Home-screen widgets" below)
    eleven_labs_core.dart     Pure-Dart ElevenLabs HTTP call — no Flutter
                              import, so tool/generate_daily_audio.dart can
                              import it via plain `dart run`
    eleven_labs_service.dart  The app's ElevenLabs client: adds the
                              on-disk cache on top of eleven_labs_core.dart
    daily_audio_service.dart  Fetches the shared pre-generated daily audio
                              (see "Shared daily audio" below)
  utils/date_format.dart      Hand-rolled date/greeting formatting (no intl
                              dependency for one format)
tool/
  generate_daily_audio.dart  Pre-generates the shared daily audio (run by
                             .github/workflows/generate-daily-audio.yml)
assets/fonts/                 Bundled Lora + Inter (variable, OFL-licensed)
android/app/src/main/kotlin/.../widget/   Android home-screen widgets (own README)
ios/VerseWidget/                          iOS WidgetKit extension source (own README)
env.example.json                          Template for --dart-define-from-file
                                           (ElevenLabs key, daily-audio base URL)
```

## Running

```
flutter pub get
flutter run
```

## What's implemented vs. stubbed

Matches the design pixel-for-pixel for layout, color, type, spacing, and
the specified interactions (optimistic save toggle, tag-chip selection,
mic-hold halo pulse, day-checkbox toggle + animated progress bar, instant
tab switching with preserved scroll position).

**Persistence**: `AppState` loads from and saves to on-device storage
(`shared_preferences`, one JSON blob) — streak, saved-verse toggle, journal
entries, plan progress, draft, and active tab all survive an app restart.
Rapid-fire writes (typing in the composer) are debounced 400ms; everything
else saves immediately. Not yet done: encryption-at-rest for journal
entries, and syncing plan progress to a user account — both called out in
the original design as intentional product/backend decisions, not UI ones.
See `test/app_state_persistence_test.dart` for the round-trip tests.

**Speech-to-text**: the mic button drives real dictation (`speech_to_text`),
not just the UI state. Press-and-hold calls `AppState.startDictation()`,
which requests mic + speech-recognition permission on first use, then
streams partial transcript into the composer as it's recognized (anything
already typed is kept as a fixed prefix, since each recognition result is
the whole utterance-so-far, not a diff). Release calls `stopDictation()`.
Permission denial, no recognizer on the device, or a recognition error all
surface as a dismissible plain-language banner under the mic row rather
than failing silently — see `AppState.micError` and the shared
`InlineErrorBanner` widget in `widgets/controls.dart`. Platform permission
strings/entitlements are wired
in `android/.../AndroidManifest.xml`, `ios/Runner/Info.plist`, and
`macos/Runner/Info.plist` + `*.entitlements`. Not yet done: on-device
(offline) recognition and non-English locales — both default to whatever
the platform's recognizer does out of the box.

**Verse audio**: the Listen button plays the verse aloud — there's no
recorded narration bundled with the app (the design's `Verse` model has an
`audioUrl` field, but nothing populates it), so speech synthesis is what
makes Listen do something real rather than a no-op. Three tiers, tried in
order by `AppState.toggleVersePlayback()`:

1. **Shared daily audio** (`lib/services/daily_audio_service.dart`) — the
   verse read aloud by ElevenLabs *once*, shared by every user, rather than
   each device separately calling ElevenLabs for identical content. See
   "Shared daily audio" below for the full pipeline and its one-time setup.
2. **ElevenLabs direct** (`lib/services/eleven_labs_service.dart`) — the
   same real human-sounding cloud voice, called from *this* device, for
   whenever tier 1 isn't configured or doesn't have today's verse yet.
   Needs a free ElevenLabs API key (elevenlabs.io; the free tier is ~10k
   characters/month) passed at build/run time — **never hardcoded or
   committed**:
   ```
   flutter run --dart-define=ELEVENLABS_API_KEY=your_key_here
   ```
   or, more conveniently for repeated runs, copy `env.example.json` to
   `env.json` (already gitignored — never commit this file with a real key
   in it) and fill in the key, then:
   ```
   flutter run --dart-define-from-file=env.json
   ```
   Generated audio is cached to disk (keyed by voice + exact text), so the
   same verse is only ever synthesized once *per device* — both to stay
   well within the free tier and so repeat plays are instant instead of
   another network round trip. Optionally override the voice with
   `ELEVENLABS_VOICE_ID` (same env mechanism) — defaults to "Rachel", one of
   ElevenLabs' standard premade voices (must match whatever
   `tool/generate_daily_audio.dart` used for tier 1's voice to sound
   consistent, if you change it).
3. **On-device TTS** (`flutter_tts`) — the fallback, and the *only* tier on
   a build with neither of the above configured (the app works either
   way). Tuned for quality rather than just wired up:
   - **Best available voice**: `AppState._selectBestVoice()` asks the
     engine for every installed English voice and switches to the
     highest-quality one — still fully on-device (a voice that needs a
     network connection only wins if no offline English voice exists at
     all), so this tier keeps working with no internet.
   - **Natural pacing**: the verse and its "John 3:16, King James Version"
     attribution are two separate utterances with a short pause between
     them, not one run-on sentence.

Tiers 1 and 2 share a "get a File, play it, track real playback position"
path in `AppState._playAudioFile` — they only differ in *how* they get that
file. Any failure in a tier (not configured, no network, a bad response,
even a playback error) falls through to the next one silently — an error
only ever reaches `AppState.ttsError` (surfaced as a dismissible banner,
same shape as the mic's) once *every* tier has failed. The Listen button
shows a brief "Preparing…" spinner state (`AppState.isPreparingVerseAudio`)
while tier 1 or 2 is in flight (a cache hit is instant; a fresh
fetch/synthesis is a network round trip). No tier reliably resumes from a
paused position, so a tap while playing stops it outright rather than
faking a resume — tapping Listen again starts over from the beginning.

Tested at every layer without a real network call or device:
- `test/daily_audio_service_test.dart` and `test/eleven_labs_service_test.dart`
  each mock `http.Client` and use a real temp directory to verify the
  request shape, error handling, and that repeat calls are served from the
  cache instead of the network.
- `test/app_state_tts_test.dart` mocks the `flutter_tts` platform channel
  and simulates the engine's native callbacks
  (start/progress/complete/error, plus a realistic `getVoices` response) to
  verify the on-device playback state machine and voice-picking logic.
- `test/app_state_playback_backend_test.dart` mocks all three platform
  channels involved (`flutter_tts`, `xyz.luan/audioplayers` + `.global`,
  plus both services' own test hooks) to verify the three-tier
  orchestration itself, tier by tier: each one succeeding without touching
  the next, each one failing and falling through, stopping mid-request
  cancelling cleanly, and an error surfacing only once every tier fails.

Not yet done: a user-facing voice/rate picker (all tiers auto-pick
silently) and non-English locales (ElevenLabs' voice and the on-device
`setLanguage` both default to English).

## Shared daily audio

*Why this exists*: `Verse.dailyVerses` cycles through a small list by
day-of-year (`Verse.forDate`/`Verse.indexForDate`) — the same verse for
every user on a given day. Without this, every single user's device would
separately call ElevenLabs to synthesize *identical* audio — wasteful, and
if you're using one ElevenLabs account/key for the whole app (rather than
each user bringing their own), it burns through your character quota once
per user instead of once per day. `tool/generate_daily_audio.dart`
generates each rotation entry's audio **once**, a GitHub Action publishes
it, and `DailyAudioService` (tier 1 above) is what every app downloads it
from.

**How it fits together:**
- `Verse.dailyVerses` — the rotation list (currently one entry; see its doc
  comment — adding verses here is genuinely the *only* step needed to grow
  the rotation end-to-end, since the generation script and the app both key
  off this same list).
- `tool/generate_daily_audio.dart` — a plain Dart script (`dart run
  tool/generate_daily_audio.dart`, with `ELEVENLABS_API_KEY` set in the
  environment) that synthesizes each entry ElevenLabs hasn't already
  generated (tracked by a `.sha256` sidecar per entry, so editing one
  verse's text doesn't re-synthesize all the others) into `docs/audio/`.
- `.github/workflows/generate-daily-audio.yml` — runs that script
  automatically whenever `lib/models/verse.dart` changes (plus a manual
  "Run workflow" button in the Actions tab), then commits `docs/audio/` back
  to the repo if anything changed.
- GitHub Pages, configured to serve `docs/` on `main` — turns the committed
  files into a public URL every app can fetch from.
- `lib/services/daily_audio_service.dart` — the app-side client:
  downloads `<base URL>/verse-<index>.mp3` (the same index
  `Verse.indexForDate` computes) and caches it on-device, same shape as
  `ElevenLabsService`.

**Status for this repo** (github.com/ALLAS101/John): pushed ✅, Pages
enabled ✅ (serving at `https://allas101.github.io/John/`) — done as part of
setting this up. Two steps are still yours to do, since they need your own
credentials:
1. Add your ElevenLabs API key as a repo secret: **Settings → Secrets and
   variables → Actions → New repository secret**, name `ELEVENLABS_API_KEY`
   (github.com/ALLAS101/John/settings/secrets/actions).
2. Generate the first files: either push any change to
   `lib/models/verse.dart` (even whitespace), or go to the **Actions** tab →
   "Generate shared daily verse audio" → **Run workflow**
   (github.com/ALLAS101/John/actions). Check the run succeeded and
   `docs/audio/verse-0.mp3` exists in the repo afterward.

Then point the app at it — add to `env.json` (see above) or pass directly:
```
flutter run --dart-define=DAILY_AUDIO_BASE_URL=https://allas101.github.io/John/audio
```

With no `DAILY_AUDIO_BASE_URL` configured, tier 1 is skipped entirely and
the app behaves exactly as before (tier 2 or tier 3) — nothing breaks
before you do the two steps above, either.

*(For a different repo/owner, the general steps are: push to GitHub, add
the secret, enable Pages under Settings → Pages → Deploy from a branch →
your default branch, folder `/docs`, then use
`https://<owner>.github.io/<repo>/audio` as the base URL.)*

**Home-screen widgets**: real native widgets, not just the in-app
Widget-tab preview, via the `home_widget` package.
`lib/services/home_widget_service.dart` is the single Dart entry point:
`syncVerse` pushes the verse excerpts/footer/streak (kept exactly in sync
with what's on Today via a listener in `main.dart`), `scheduleDailyRefresh`
arms the widgets' 6am local refresh, and `handleInitialLaunch`/
`listenForClicks` route a widget tap to the Today tab.
- **Android**: two `AppWidgetProvider`s ("Large 4×2" / "Small 2×2",
  matching the design exactly) under
  `android/app/src/main/kotlin/.../widget/` — read that folder's own
  README first, especially **why RemoteViews instead of the design's
  suggested Glance**, and the honest limits of how much this was verified:
  every Gradle build attempt in this environment failed at the daemon
  loopback-socket level (a sandbox constraint, not a code problem), so this
  was checked as thoroughly as possible by hand (cross-referenced against
  `home_widget`'s own source, every resource ID checked both ends) but
  never actually compiled or run.
- **iOS**: authored, not built — `ios/VerseWidget/` has the full WidgetKit
  extension source (SwiftUI views for both size families, a
  `TimelineProvider` with the same 6am-refresh intent), but adding it as a
  real Xcode target needs `project.pbxproj` edits only Xcode itself should
  make, and there's no Mac available to have done that or compiled a
  single line of the Swift. See that folder's README for the exact Xcode
  steps.
- Both platforms' Dart-facing plumbing (`syncVerse`, `scheduleDailyRefresh`,
  the widget-tap → Today routing) is real code with real tests —
  `test/home_widget_service_test.dart` mocks the `home_widget` platform
  channel and checks the exact strings/keys/timestamps crossing it, the
  same way `app_state_tts_test.dart` does for text-to-speech.

Still stubbed, by design — a backend task, not UI:
- **Verse-of-the-day source**: currently a single bundled verse
  (`Verse.ofTheDay`); real content would fetch daily and cache for offline.
