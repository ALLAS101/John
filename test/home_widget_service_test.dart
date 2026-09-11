// Verifies HomeWidgetService actually calls the `home_widget` platform
// channel with the arguments the native widgets (and the design's exact
// copy) depend on — by mocking the channel and inspecting what crossed it,
// not by reading the service's source and trusting it.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:john316/models/app_tab.dart';
import 'package:john316/models/verse.dart';
import 'package:john316/services/home_widget_service.dart';
import 'package:john316/state/app_state.dart';

const _channel = MethodChannel('home_widget');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final calls = <MethodCall>[];
  Object? initialLaunchUriToReturn;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    calls.clear();
    initialLaunchUriToReturn = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'initiallyLaunchedFromHomeWidget':
          return initialLaunchUriToReturn;
        default:
          return true;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  test('syncVerse pushes the exact strings the widgets render, per size',
      () async {
    final state = await AppState.create();
    state.streak = 12;

    await HomeWidgetService.syncVerse(state);

    final saved = {
      for (final call in calls.where((c) => c.method == 'saveWidgetData'))
        (call.arguments as Map)['id'] as String: (call.arguments as Map)['data'],
    };

    // Derived from whatever verse the rotation actually lands on today,
    // rather than hardcoding entry 0's text — the rotation has grown past a
    // single verse, so "today" won't always be John 3:16.
    final todaysVerse = Verse.forDate(DateTime.now());
    expect(saved['widget_verse_large'], todaysVerse.widgetExcerptLarge);
    expect(saved['widget_verse_small'], todaysVerse.widgetExcerptSmall);
    // Every entry uses "King James Version", so the abbreviated suffix is
    // stable even though the reference itself varies by day.
    expect(saved['widget_footer_left'], '${todaysVerse.reference} · KJV');
    expect(saved['widget_streak_label'], '12-day streak');

    final updated = calls
        .where((c) => c.method == 'updateWidget')
        .map((c) => (c.arguments as Map))
        .toList();
    expect(
      updated.any(
        (a) =>
            a['qualifiedAndroidName'] ==
            'com.pepla.john316.widget.VerseWidgetLargeProvider',
      ),
      isTrue,
    );
    expect(
      updated.any(
        (a) =>
            a['qualifiedAndroidName'] ==
            'com.pepla.john316.widget.VerseWidgetSmallProvider',
      ),
      isTrue,
    );
    expect(updated.any((a) => a['ios'] == 'VerseWidget'), isTrue);
  });

  test('syncVerse never throws even if the platform channel rejects it',
      () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      throw PlatformException(code: 'boom');
    });
    final state = await AppState.create();

    // Must not throw — a widget sync failure is background plumbing, never
    // something that should crash or interrupt the foreground app.
    await HomeWidgetService.syncVerse(state);
  });

  test('scheduleDailyRefresh schedules only future 6am local times',
      () async {
    await HomeWidgetService.scheduleDailyRefresh(days: 5);

    final schedule = calls.firstWhere(
      (c) => c.method == 'scheduleWidgetUpdates',
    );
    final args = schedule.arguments as Map;
    final millis = (args['updateTimes'] as List).cast<int>();
    expect(millis, hasLength(5));

    final now = DateTime.now();
    for (final ms in millis) {
      final time = DateTime.fromMillisecondsSinceEpoch(ms);
      expect(time.hour, 6);
      expect(time.minute, 0);
      expect(time.isAfter(now), isTrue);
    }
    // Consecutive entries are exactly one day apart.
    for (var i = 1; i < millis.length; i++) {
      expect(millis[i] - millis[i - 1], const Duration(days: 1).inMilliseconds);
    }
  });

  test('handleInitialLaunch switches to Today when launched from a widget',
      () async {
    initialLaunchUriToReturn = 'john316://today?homeWidget=true';
    final state = await AppState.create();
    state.setActiveTab(AppTab.plan);

    await HomeWidgetService.handleInitialLaunch(state);

    expect(state.activeTab, AppTab.today);
  });

  test('handleInitialLaunch leaves the tab alone on a normal launch',
      () async {
    initialLaunchUriToReturn = null;
    final state = await AppState.create();
    state.setActiveTab(AppTab.journal);

    await HomeWidgetService.handleInitialLaunch(state);

    expect(state.activeTab, AppTab.journal);
  });
}
