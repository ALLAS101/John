/// A prayer-journal tag. Order here is the order chips render in.
enum JournalTag { gratitude, request, praise, confession }

extension JournalTagLabel on JournalTag {
  String get label => switch (this) {
        JournalTag.gratitude => 'Gratitude',
        JournalTag.request => 'Request',
        JournalTag.praise => 'Praise',
        JournalTag.confession => 'Confession',
      };
}

/// Parses a tag stored by [JournalTag.name] (e.g. from persisted JSON),
/// falling back to gratitude for anything unrecognized rather than throwing
/// — persisted data should never be able to crash the app on load.
JournalTag journalTagFromName(String? name) {
  return JournalTag.values.firstWhere(
    (t) => t.name == name,
    orElse: () => JournalTag.gratitude,
  );
}

/// One journal entry: a written or dictated prayer, tagged and dated.
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.body,
    required this.tag,
    required this.createdAt,
  });

  final String id;
  final String body;
  final JournalTag tag;
  final DateTime createdAt;

  /// A short relative label ("Yesterday", "Tuesday", "3 days ago") for the
  /// "Earlier" list — real dates in the seed data are computed relative to
  /// today so the app always shows something plausible.
  String relativeDate(DateTime now) {
    final difference = DateTime(now.year, now.month, now.day)
        .difference(DateTime(createdAt.year, createdAt.month, createdAt.day))
        .inDays;
    if (difference <= 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) {
      const weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return weekdays[createdAt.weekday - 1];
    }
    return '$difference days ago';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'body': body,
        'tag': tag.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        body: json['body'] as String,
        tag: journalTagFromName(json['tag'] as String?),
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
                DateTime.now(),
      );
}
