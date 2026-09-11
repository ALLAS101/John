/// A single scripture verse, with its spoken-audio source.
class Verse {
  const Verse({
    required this.text,
    required this.reference,
    required this.translation,
    this.audioUrl,
    String? widgetExcerptLarge,
    String? widgetExcerptSmall,
  }) : _widgetExcerptLarge = widgetExcerptLarge,
       _widgetExcerptSmall = widgetExcerptSmall;

  final String text;
  final String reference;
  final String translation;
  final String? audioUrl;

  final String? _widgetExcerptLarge;
  final String? _widgetExcerptSmall;

  /// Excerpt for the large (4x2 / systemMedium) home-screen widget.
  ///
  /// Editorially curated where supplied (the shipped verse uses the exact
  /// copy from the design handoff, which cuts at a clause boundary rather
  /// than a raw character count); otherwise falls back to a plain
  /// word-boundary truncation of [text] so a future, un-curated verse still
  /// renders something reasonable instead of nothing.
  String get widgetExcerptLarge => _widgetExcerptLarge ?? _truncate(text, 66);

  /// Excerpt for the small (2x2 / systemSmall) home-screen widget.
  String get widgetExcerptSmall => _widgetExcerptSmall ?? _truncate(text, 24);

  static String _truncate(String s, int maxLen) {
    if (s.length <= maxLen) return s;
    final cut = s.substring(0, maxLen);
    final lastSpace = cut.lastIndexOf(' ');
    final trimmed = lastSpace > 0 ? cut.substring(0, lastSpace) : cut;
    return '$trimmed…';
  }

  /// The app's namesake verse — also entry 0 of [dailyVerses], so it's what
  /// shows on day one of the rotation and whenever the list only has one
  /// entry (true today; see [dailyVerses]'s own doc comment).
  static const ofTheDay = Verse(
    text:
        'For God so loved the world, that he gave his only begotten Son, '
        'that whosoever believeth in him should not perish, but have '
        'everlasting life.',
    reference: 'John 3:16',
    translation: 'King James Version',
    widgetExcerptLarge:
        'For God so loved the world, that he gave his only begotten Son…',
    widgetExcerptSmall: 'God so loved the world…',
  );

  /// The full daily rotation, in order. [forDate] cycles through these by
  /// day-of-year, so the list only needs to be as long as however many
  /// distinct days you want before it repeats — it doesn't need 365 entries.
  ///
  /// Only one entry for now: real content curation (sourcing and verifying
  /// more verses) is a content task, not a UI one — see the top-level
  /// README's "Verse-of-the-day source" note. Adding entries here is also
  /// what drives `tool/generate_daily_audio.dart` (see its doc comment) —
  /// each entry gets its own pre-generated shared audio file, so growing
  /// this list is the *only* step needed to add more days to the rotation
  /// end-to-end.
  static const List<Verse> dailyVerses = [ofTheDay];

  /// Index into [dailyVerses] for [date] — the same day-of-year always
  /// maps to the same index, in both the app and
  /// `tool/generate_daily_audio.dart` (which imports this file directly
  /// rather than re-implementing the mapping), so a client and the
  /// pre-generated audio for "today" always agree on which verse that is.
  static int indexForDate(DateTime date) {
    final dayOfYear = date
        .difference(DateTime(date.year, 1, 1))
        .inDays;
    return dayOfYear % dailyVerses.length;
  }

  /// The verse for [date] — what Today (and the widgets) actually show.
  static Verse forDate(DateTime date) => dailyVerses[indexForDate(date)];
}
