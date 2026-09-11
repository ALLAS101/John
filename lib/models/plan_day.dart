/// One day of the "30 Days on Faith" reading plan.
class PlanDay {
  const PlanDay({
    required this.number,
    required this.theme,
    required this.reference,
  });

  final int number;
  final String theme;
  final String reference;
}

/// Full 30-day plan. Days 1-9 and 17-30 are placeholder titles pending real
/// content (per the design README: "full 30-day content is content work,
/// not design work") — days 10-16 are the exact copy specified in the
/// handoff.
const List<PlanDay> planDays = [
  PlanDay(number: 1, theme: 'Where it begins', reference: 'Genesis 1:1'),
  PlanDay(number: 2, theme: 'Made in His image', reference: 'Genesis 1:27'),
  PlanDay(number: 3, theme: 'A promise kept', reference: 'Genesis 12:2'),
  PlanDay(number: 4, theme: 'Deliverance', reference: 'Exodus 14:14'),
  PlanDay(number: 5, theme: 'The shepherd king', reference: 'Psalm 23:1'),
  PlanDay(number: 6, theme: 'Wisdom calls out', reference: 'Proverbs 3:5'),
  PlanDay(number: 7, theme: 'A light to the nations', reference: 'Isaiah 9:2'),
  PlanDay(number: 8, theme: 'The word made flesh', reference: 'John 1:14'),
  PlanDay(number: 9, theme: 'Living water', reference: 'John 4:14'),
  PlanDay(number: 10, theme: 'Faith that waits', reference: 'Hebrews 11:1'),
  PlanDay(
    number: 11,
    theme: 'Loved before you knew',
    reference: 'John 3:16',
  ),
  PlanDay(number: 12, theme: 'Mustard seed', reference: 'Matthew 17:20'),
  PlanDay(number: 13, theme: 'When doubt speaks', reference: 'Mark 9:24'),
  PlanDay(
    number: 14,
    theme: 'Walking, not seeing',
    reference: '2 Corinthians 5:7',
  ),
  PlanDay(number: 15, theme: 'Held together', reference: 'Colossians 1:17'),
  PlanDay(number: 16, theme: 'Rest for the weary', reference: 'Matthew 11:28'),
  PlanDay(number: 17, theme: 'The good shepherd', reference: 'John 10:11'),
  PlanDay(number: 18, theme: 'Peace, be still', reference: 'Mark 4:39'),
  PlanDay(number: 19, theme: 'A new heart', reference: 'Ezekiel 36:26'),
  PlanDay(number: 20, theme: 'Cast your cares', reference: '1 Peter 5:7'),
  PlanDay(number: 21, theme: 'The narrow gate', reference: 'Matthew 7:13'),
  PlanDay(number: 22, theme: 'Fear not', reference: 'Isaiah 41:10'),
  PlanDay(number: 23, theme: 'Fruit of the Spirit', reference: 'Galatians 5:22'),
  PlanDay(number: 24, theme: 'Abide in me', reference: 'John 15:5'),
  PlanDay(number: 25, theme: 'A cheerful giver', reference: '2 Corinthians 9:7'),
  PlanDay(number: 26, theme: 'Press on', reference: 'Philippians 3:14'),
  PlanDay(number: 27, theme: 'Armor of light', reference: 'Romans 13:12'),
  PlanDay(number: 28, theme: 'The great commission', reference: 'Matthew 28:19'),
  PlanDay(number: 29, theme: 'A living hope', reference: '1 Peter 1:3'),
  PlanDay(number: 30, theme: 'Grace sufficient', reference: '2 Corinthians 12:9'),
];
