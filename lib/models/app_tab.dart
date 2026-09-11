/// The four bottom-tab destinations, in display order.
enum AppTab { today, journal, plan, widget }

/// Parses a tab stored by [AppTab.name] (e.g. from persisted JSON),
/// falling back to [AppTab.today] for anything unrecognized.
AppTab appTabFromName(String? name) {
  return AppTab.values.firstWhere(
    (t) => t.name == name,
    orElse: () => AppTab.today,
  );
}
