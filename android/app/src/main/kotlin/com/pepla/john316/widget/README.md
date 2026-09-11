# Android home-screen widgets

Two `AppWidgetProvider`s (`VerseWidgetLargeProvider` / `VerseWidgetSmallProvider`)
matching the design's Widget screen — "Large (4 × 2)" and "Small (2 × 2)".
Built on the `home_widget` package (`es.antonborri.home_widget`), which
bridges the SharedPreferences it writes to from Dart
(`lib/services/home_widget_service.dart`) and provides the exact-alarm
scheduling for the daily 6am refresh.

## Why RemoteViews instead of Glance

The design's own README suggests Glance (Jetpack Compose for widgets) for
Android. This uses classic `RemoteViews` + XML layouts instead — a
deliberate, lower-risk substitution, not an oversight:

- Glance needs the Compose compiler Gradle plugin and a new
  `androidx.glance:glance-appwidget` dependency on top of everything else
  already changed in this pass.
- **Nothing in this repo has been able to actually run Gradle** — every
  attempt (`flutter build apk`, `gradlew assembleDebug`, with a different
  JDK, with `--no-daemon`, with an explicit `SelectorProvider` override) hit
  the same `java.io.IOException: Unable to establish loopback connection`
  from `sun.nio.ch.UnixDomainSockets`, which looks like this sandbox
  disallows the loopback/AF_UNIX sockets Gradle's daemon needs to start at
  all — not something fixable from inside the project.
- With zero ability to compile-check anything here, adding a whole new
  build-tool dependency (Compose compiler + Glance, with their own version
  compatibility matrix against this project's Kotlin 2.3.20 / AGP 9.0.1)
  is meaningfully riskier than plain Views, which only needs what
  `home_widget` already brings in as a transitive Flutter plugin dependency
  — no `build.gradle.kts` changes at all.

Every file here was still checked as carefully as it could be without a
compiler: cross-referenced resource IDs (`@font`, `@color`, `@string`,
`@drawable`, `@layout`, `@xml`, `@+id`) between every file that defines and
every file that uses one, and the Kotlin against `home_widget` 0.9.4's own
source for its provider base class, launch-intent helper, and scheduler
API. If you have a working Gradle setup, `flutter build apk` (or opening
`android/` in Android Studio) is the first real test this code has had.

## Files

| File | What it is |
|---|---|
| `VerseWidgetLargeProvider.kt` / `VerseWidgetSmallProvider.kt` | Read the data Dart wrote and draw it into the matching layout |
| `res/layout/verse_widget_{large,small}.xml` | The two widgets' RemoteViews layouts |
| `res/drawable(-night)/verse_widget_bg_{large,small}.xml` | Gradient backgrounds — light in `drawable/`, dark in `drawable-night/`, mirroring the design's two themes |
| `res/drawable/widget_chip_dot.xml` | The small gold chip beside "JOHN 3:16" on the large widget |
| `res/values(-night)/colors.xml` | Widget-only text/accent colors, light + dark |
| `res/xml/verse_widget_{large,small}_info.xml` | `<appwidget-provider>` metadata (size, description, `updatePeriodMillis="0"` since refresh timing comes from the scheduler, not the OS's own periodic update) |
| `res/font/lora_italic.ttf`, `res/font/inter_regular.ttf` | The same variable fonts bundled under `assets/fonts/`, copied here since widget resources are a separate resource namespace from Flutter assets |

The `<receiver>` entries for both providers, `HomeWidgetScheduledUpdateReceiver`
(daily-refresh alarms + reboot handling), the `RECEIVE_BOOT_COMPLETED`
permission, and MainActivity's `es.antonborri.home_widget.action.LAUNCH`
intent-filter (needed for tap-to-open) are all in
`android/app/src/main/AndroidManifest.xml`.

## Known gaps

- **No preview image**: `android:previewImage` isn't set on either
  `appwidget-provider` XML (no asset exists to point it at — same
  "app icon" gap noted in the top-level README). The widget picker falls
  back to a generic icon instead of a snapshot of the real layout.
- **Gradient angle**: Android shape-drawable gradients only support 45°
  steps; the design's 150°/160° diagonals are approximated as 315°
  (top-left → bottom-right), the closest available direction.
- **Not visually verified**: no emulator was booted to see either widget
  actually pinned to a home screen (Gradle couldn't run at all — see
  above), so treat the layout/gradient/font choices as a careful first pass,
  not a pixel-checked match.
