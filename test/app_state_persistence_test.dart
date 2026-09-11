// Verifies AppState actually survives a restart: mutate state, create a
// fresh AppState against the same (mock) storage, and check the new
// instance reads back what the old one wrote — rather than trusting that
// _save()/_load() are wired correctly by inspection alone.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:john316/models/app_tab.dart';
import 'package:john316/models/journal_entry.dart';
import 'package:john316/state/app_state.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('first launch seeds sample data with no persisted store', () async {
    final state = await AppState.create();

    expect(state.entries, hasLength(3));
    expect(state.completedDays, {for (var i = 1; i <= 12; i++) i});
    expect(state.streak, 12);
    expect(state.isSaved, isTrue);
  });

  test('toggling saved-verse survives a fresh AppState instance', () async {
    final first = await AppState.create();
    expect(first.isSaved, isTrue);
    first.toggleSaved();
    expect(first.isSaved, isFalse);
    await first.flush();

    final second = await AppState.create();
    expect(second.isSaved, isFalse);
  });

  test('plan-day completion survives a fresh AppState instance', () async {
    final first = await AppState.create();
    expect(first.completedDays.contains(20), isFalse);
    first.togglePlanDay(20);
    expect(first.completedDays.contains(20), isTrue);
    await first.flush();

    final second = await AppState.create();
    expect(second.completedDays.contains(20), isTrue);
    expect(second.planDoneCount, 13);
  });

  test('a submitted journal entry survives a fresh AppState instance',
      () async {
    final first = await AppState.create();
    final startingCount = first.entries.length;

    first.setDraftTag(JournalTag.confession);
    first.setDraftBody('Forgive me for the harsh word this morning.');
    first.submitDraft();

    expect(first.entries, hasLength(startingCount + 1));
    expect(first.draftBody, isEmpty); // cleared after submit
    await first.flush();

    final second = await AppState.create();
    expect(second.entries, hasLength(startingCount + 1));
    final newest = second.entries.first; // entries are newest-first
    expect(newest.body, 'Forgive me for the harsh word this morning.');
    expect(newest.tag, JournalTag.confession);
  });

  test('active tab and streak survive a fresh AppState instance', () async {
    final first = await AppState.create();
    first.setActiveTab(AppTab.plan);
    first.registerEngagementToday();
    expect(first.streak, 13);
    await first.flush();

    final second = await AppState.create();
    expect(second.activeTab, AppTab.plan);
    expect(second.streak, 13);

    // Same calendar day again — should be a no-op, not a second increment.
    second.registerEngagementToday();
    expect(second.streak, 13);
  });

  test('corrupt persisted data falls back to sample data instead of crashing',
      () async {
    SharedPreferences.setMockInitialValues({
      'john316_state_v1': 'not valid json {{{',
    });

    final state = await AppState.create();
    expect(state.entries, hasLength(3));
  });
}
