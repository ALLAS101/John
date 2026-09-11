import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/root_shell.dart';
import 'services/home_widget_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Persisted state (journal entries, plan progress, streak, ...) must load
  // before the first frame — otherwise the UI would flash the fallback
  // sample data, then swap to the real data a moment later.
  WidgetsFlutterBinding.ensureInitialized();
  final appState = await AppState.create();

  await HomeWidgetService.init();
  // Fire-and-forget: none of this should delay the first frame, and a
  // failure here (e.g. `home_widget` unavailable on this platform) is
  // already swallowed and logged inside the service.
  unawaited(HomeWidgetService.syncVerse(appState));
  unawaited(HomeWidgetService.scheduleDailyRefresh());
  // Keep the widgets' streak in sync without re-pushing on every unrelated
  // state change (e.g. a keystroke in the journal composer).
  var lastSyncedStreak = appState.streak;
  var lastSyncedSaved = appState.isSaved;
  appState.addListener(() {
    if (appState.streak != lastSyncedStreak ||
        appState.isSaved != lastSyncedSaved) {
      lastSyncedStreak = appState.streak;
      lastSyncedSaved = appState.isSaved;
      unawaited(HomeWidgetService.syncVerse(appState));
    }
  });

  await HomeWidgetService.handleInitialLaunch(appState);
  HomeWidgetService.listenForClicks(appState);

  runApp(John316App(appState: appState));
}

/// "John 3:16" — a daily verse and prayer journal.
///
/// John 3:16 (KJV) is the app's namesake and theme: light breaking into
/// darkness. Dark and light themes are both first-class (see
/// design_handoff_john_3_16/README.md) and the app follows the system
/// setting between them.
class John316App extends StatelessWidget {
  const John316App({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: MaterialApp(
        title: 'John 3:16',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const RootShell(),
      ),
    );
  }
}
