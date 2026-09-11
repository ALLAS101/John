import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../models/app_tab.dart';
import '../state/app_state.dart';

/// Bridges [AppState] to the native home-screen widgets (WidgetKit on iOS,
/// a classic `AppWidgetProvider` + `RemoteViews` on Android — see the
/// widget's own README for why RemoteViews rather than the design's
/// suggested Glance) via the `home_widget` package.
///
/// This class only ever *writes* through the package's platform channel and
/// reads the widget-tap deep link back; it renders nothing itself — the
/// actual widget UI lives in native code:
/// - Android: `android/app/src/main/kotlin/.../widget/`
/// - iOS: `ios/VerseWidget/` (authored, not buildable without a Mac — see
///   that folder's README)
class HomeWidgetService {
  HomeWidgetService._();

  /// Must match the App Group configured in the iOS widget extension's and
  /// the host app's entitlements — see `ios/VerseWidget/README.md`. Inert on
  /// Android.
  static const _iosAppGroupId = 'group.com.pepla.john316.widget';

  static const _androidLargeProvider =
      'com.pepla.john316.widget.VerseWidgetLargeProvider';
  static const _androidSmallProvider =
      'com.pepla.john316.widget.VerseWidgetSmallProvider';
  static const _iosKind = 'VerseWidget';

  /// One-time setup — call before the first [syncVerse].
  static Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId(_iosAppGroupId);
    } catch (_) {
      // Not fatal on any platform — Android ignores the app group entirely,
      // and a widget that fails to configure shouldn't block app startup.
    }
  }

  /// Pushes the current verse + streak into the widgets' storage and asks
  /// both platforms to redraw. Cheap and idempotent — safe to call on every
  /// relevant [AppState] change (see `main.dart`'s listener, which only
  /// calls this when the fields that actually appear on a widget change).
  static Future<void> syncVerse(AppState state) async {
    final verse = state.verseOfDay;
    try {
      await Future.wait([
        HomeWidget.saveWidgetData('widget_verse_large', verse.widgetExcerptLarge),
        HomeWidget.saveWidgetData('widget_verse_small', verse.widgetExcerptSmall),
        HomeWidget.saveWidgetData(
          'widget_footer_left',
          '${verse.reference} · ${_abbreviateTranslation(verse.translation)}',
        ),
        HomeWidget.saveWidgetData(
          'widget_streak_label',
          '${state.streak}-day streak',
        ),
      ]);
      await Future.wait([
        HomeWidget.updateWidget(qualifiedAndroidName: _androidLargeProvider),
        HomeWidget.updateWidget(qualifiedAndroidName: _androidSmallProvider),
        HomeWidget.updateWidget(iOSName: _iosKind),
      ]);
    } catch (e) {
      // Widget sync is best-effort background plumbing — a failure here
      // (e.g. no widget of that kind is actually pinned yet) must never
      // surface to the user or interrupt anything in the foreground app.
      debugPrint('HomeWidgetService.syncVerse failed: $e');
    }
  }

  /// "King James Version" → "KJV" for the widget's tight footer line;
  /// anything already short (or not a recognizable full name) passes
  /// through unchanged.
  static String _abbreviateTranslation(String translation) {
    final words = translation.trim().split(RegExp(r'\s+'));
    if (words.length < 2) return translation;
    return words.map((w) => w.isEmpty ? '' : w[0].toUpperCase()).join();
  }

  /// (Re)schedules the widgets' daily 6am local refresh — see the design's
  /// "Refreshes each morning at 6 am." copy on the Widget screen. Batches
  /// many days at once (rather than one at a time) so the schedule survives
  /// stretches of the app not being opened; call again occasionally (this
  /// app does it on every launch) to keep the horizon from running out.
  ///
  /// No-op on iOS: WidgetKit widgets decide their own refresh timing from
  /// the `TimelineProvider`'s entries, so there is nothing to schedule
  /// through this plugin there.
  static Future<void> scheduleDailyRefresh({int days = 60}) async {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, 6);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    final times = List.generate(days, (i) => next.add(Duration(days: i)));
    try {
      await Future.wait([
        HomeWidget.scheduleWidgetUpdates(
          times,
          qualifiedAndroidName: _androidLargeProvider,
        ),
        HomeWidget.scheduleWidgetUpdates(
          times,
          qualifiedAndroidName: _androidSmallProvider,
        ),
      ]);
    } catch (e) {
      debugPrint('HomeWidgetService.scheduleDailyRefresh failed: $e');
    }
  }

  /// Checks whether the app was launched by tapping a widget and, if so,
  /// switches to Today — "Tapping either deep-links to Today" per the
  /// design. Call once at startup, after [AppState] exists.
  static Future<void> handleInitialLaunch(AppState state) async {
    try {
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (uri != null) state.setActiveTab(AppTab.today);
    } catch (e) {
      debugPrint('HomeWidgetService.handleInitialLaunch failed: $e');
    }
  }

  /// Same as [handleInitialLaunch] but for taps that arrive while the app
  /// process is already alive. Returns the subscription so callers can
  /// cancel it (not that this app ever does — it lives for the app's
  /// lifetime).
  static StreamSubscription<Uri?> listenForClicks(AppState state) {
    return HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) state.setActiveTab(AppTab.today);
    });
  }
}
