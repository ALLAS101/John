// Basic smoke test: the app boots to the Today screen and the bottom tab
// bar can switch to each of the other three screens.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:john316/main.dart';
import 'package:john316/state/app_state.dart';

void main() {
  testWidgets('App boots on Today and tabs switch screens', (tester) async {
    // No real platform storage in the test environment — start with an
    // empty mock store so AppState.create() falls back to sample data.
    SharedPreferences.setMockInitialValues({});
    final appState = await AppState.create();

    await tester.pumpWidget(John316App(appState: appState));
    await tester.pumpAndSettle();

    expect(find.text('VERSE OF THE DAY'), findsOneWidget);

    await tester.tap(find.text('Journal'));
    await tester.pumpAndSettle();
    expect(find.text('Say it plainly. He already knows.'), findsOneWidget);

    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();
    expect(find.text('30 Days on Faith'), findsOneWidget);

    await tester.tap(find.text('Widget'));
    await tester.pumpAndSettle();
    expect(find.text('Widgets'), findsOneWidget);
  });
}
