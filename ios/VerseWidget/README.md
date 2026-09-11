# VerseWidget (iOS WidgetKit extension)

This folder holds the **source** for the iOS home-screen widget — the same
content shown by the Android widgets in
`android/app/src/main/kotlin/com/pepla/john316/widget/`, matching the
design's "Large (4 × 2)" / "Small (2 × 2)" Widget screen. It is **not yet a
buildable Xcode target**: adding one means editing `Runner.xcodeproj`'s
`project.pbxproj`, which isn't safe to hand-write outside Xcode (and wasn't
possible to verify at all here — this repo was built on Windows, with no
Mac/Xcode available to create the target or compile a single line of this
Swift code). Here's what exists and what's left.

## What's here

- `VerseWidgetBundle.swift` — the extension's `@main` entry point.
- `VerseWidget.swift` — the `TimelineProvider` (reads the App Group data
  Dart writes, decides the next 6am refresh) and the two SwiftUI views
  (`.systemSmall`, `.systemMedium`).
- `Info.plist` — the extension's plist (`NSExtensionPointIdentifier:
  com.apple.widgetkit-extension`).
- `VerseWidget.entitlements` — the App Group entitlement the extension
  needs to read what the app wrote.

`ios/Runner/Runner.entitlements` (same App Group, for the host app) and the
`john316` URL scheme in `ios/Runner/Info.plist` (so tapping the widget can
open the app at all) already exist alongside the rest of the app.

## Setting it up in Xcode (on a Mac)

1. Open `ios/Runner.xcworkspace` (not the `.xcodeproj`) in Xcode.
2. **File → New → Target… → Widget Extension.** Name it `VerseWidget`,
   uncheck "Include Configuration Intent" (this widget isn't user-configurable).
   Xcode creates its own placeholder Swift files and Info.plist — delete
   those and add the four files in this folder to the new target instead
   (drag them in, checking "VerseWidget" as the target membership).
3. **Both** targets (`Runner` and `VerseWidget`) → Signing & Capabilities →
   **+ Capability → App Groups** → add `group.com.pepla.john316.widget`
   (must match `HomeWidgetService._iosAppGroupId` in
   `lib/services/home_widget_service.dart` exactly). Xcode will offer to
   generate entitlements files — point them at (or merge with)
   `Runner.entitlements` / `VerseWidget.entitlements` already in this repo
   rather than letting it create new ones.
4. Set `VerseWidget`'s deployment target to iOS 14.0+ (WidgetKit's minimum).
5. Build. `flutter build ios` builds the widget extension automatically
   once it's a real target in the project — no separate Flutter-side step.

## What's still a placeholder

- **Fonts**: the views use `Font.system(..., design: .serif).italic()`
  rather than the actual Lora/Inter faces the rest of the app bundles
  (`assets/fonts/`), since bundling them means adding the `.ttf` files to
  the widget extension's target membership and its Info.plist's
  `UIAppFonts`, which — like the target itself — needs Xcode. The serif
  system font is a reasonable stand-in, not the final look.
- **App icon / preview thumbnails**: none set (same "still outstanding" item
  as the rest of the app — see the top-level README).
- Everything else (data flow, tap-to-deep-link, the 6am timeline policy,
  dark/light palettes) is real, working code, reviewed line-by-line against
  `home_widget` 0.9.4's own Swift plugin source since it can't be run here.
  Sanity-check it once the target exists — this is genuinely unverified.
