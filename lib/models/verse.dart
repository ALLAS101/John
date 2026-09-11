/// A single scripture verse, with its spoken-audio source.
class Verse {
  const Verse({
    required this.text,
    required this.reference,
    required this.translation,
    required this.reflectionPrompt,
    this.audioUrl,
    String? widgetExcerptLarge,
    String? widgetExcerptSmall,
  }) : _widgetExcerptLarge = widgetExcerptLarge,
       _widgetExcerptSmall = widgetExcerptSmall;

  final String text;
  final String reference;
  final String translation;
  final String? audioUrl;

  /// The Today screen's "Sit with it" journaling prompt for this verse — a
  /// short, second-person question that applies the verse to today rather
  /// than restating it, matching the tone of the design's shipped copy (see
  /// [ofTheDay]'s). Tapping "Write about this" seeds the journal composer
  /// with this exact text.
  final String reflectionPrompt;

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
    reflectionPrompt:
        'Where did you see love given away today — not earned, just given?',
    widgetExcerptLarge:
        'For God so loved the world, that he gave his only begotten Son…',
    widgetExcerptSmall: 'God so loved the world…',
  );

  /// The full daily rotation, in order. [forDate] cycles through these by
  /// day-of-year, so the list only needs to be as long as however many
  /// distinct days you want before it repeats — it doesn't need 365 entries.
  ///
  /// 30 entries — a month-long cycle before it repeats — spanning a range of
  /// themes (love, hope, peace, courage, rest, gratitude...) rather than
  /// staying in one book or mood. All King James Version, since it's public
  /// domain and every entry is checked word-for-word against it; each has
  /// its own [reflectionPrompt] rather than reusing [ofTheDay]'s. No curated
  /// `widgetExcerptLarge`/`widgetExcerptSmall` beyond entry 0 — the
  /// word-boundary truncation fallback (see those getters) is good enough,
  /// and hand-curating 29 more clause breaks isn't worth it for now.
  ///
  /// Adding entries here is also what drives `tool/generate_daily_audio.dart`
  /// (see its doc comment) — each entry gets its own pre-generated shared
  /// audio file, so growing this list is the *only* step needed to add more
  /// days to the rotation end-to-end (the next push re-runs that pipeline
  /// for whichever entries are new).
  static const List<Verse> dailyVerses = [
    ofTheDay,
    Verse(
      text: 'The LORD is my shepherd; I shall not want.',
      reference: 'Psalm 23:1',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you still trying to provide for yourself that\'s '
          'already being carried for you?',
    ),
    Verse(
      text: 'I can do all things through Christ which strengtheneth me.',
      reference: 'Philippians 4:13',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s one thing today that felt beyond you — and where might '
          'strength for it actually come from?',
    ),
    Verse(
      text:
          'For I know the thoughts that I think toward you, saith the '
          'LORD, thoughts of peace, and not of evil, to give you an '
          'expected end.',
      reference: 'Jeremiah 29:11',
      translation: 'King James Version',
      reflectionPrompt:
          'What future are you quietly afraid of — and what would it mean '
          'to trade that fear for a plan you can\'t yet see?',
    ),
    Verse(
      text:
          'Trust in the LORD with all thine heart; and lean not unto thine '
          'own understanding. In all thy ways acknowledge him, and he '
          'shall direct thy paths.',
      reference: 'Proverbs 3:5-6',
      translation: 'King James Version',
      reflectionPrompt:
          'Where are you leaning on your own understanding right now '
          'instead of asking for direction?',
    ),
    Verse(
      text:
          'Fear thou not; for I am with thee: be not dismayed; for I am '
          'thy God: I will strengthen thee; yea, I will help thee; yea, I '
          'will uphold thee with the right hand of my righteousness.',
      reference: 'Isaiah 41:10',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s the thing you\'re facing today that you\'d rather not '
          'face alone?',
    ),
    Verse(
      text:
          'And we know that all things work together for good to them '
          'that love God, to them who are the called according to his '
          'purpose.',
      reference: 'Romans 8:28',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there a hard chapter of your story you haven\'t yet believed '
          'could be redeemed?',
    ),
    Verse(
      text: 'God is our refuge and strength, a very present help in trouble.',
      reference: 'Psalm 46:1',
      translation: 'King James Version',
      reflectionPrompt:
          'Where do you actually run when trouble shows up — and is it '
          'working?',
    ),
    Verse(
      text:
          'Come unto me, all ye that labour and are heavy laden, and I '
          'will give you rest.',
      reference: 'Matthew 11:28',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you still carrying that you were never meant to carry '
          'alone?',
    ),
    Verse(
      text:
          'Have not I commanded thee? Be strong and of a good courage; be '
          'not afraid, neither be thou dismayed: for the LORD thy God is '
          'with thee whithersoever thou goest.',
      reference: 'Joshua 1:9',
      translation: 'King James Version',
      reflectionPrompt:
          'Where do you need courage today more than you need certainty?',
    ),
    Verse(
      text: 'This is the day which the LORD hath made; we will rejoice and '
          'be glad in it.',
      reference: 'Psalm 118:24',
      translation: 'King James Version',
      reflectionPrompt:
          'What would change if you treated today as made, not just '
          'endured?',
    ),
    Verse(
      text:
          'Now the God of hope fill you with all joy and peace in '
          'believing, that ye may abound in hope, through the power of '
          'the Holy Ghost.',
      reference: 'Romans 15:13',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s crowding out hope in you right now — and what would it '
          'take to let it back in?',
    ),
    Verse(
      text:
          'Therefore if any man be in Christ, he is a new creature: old '
          'things are passed away; behold, all things are become new.',
      reference: '2 Corinthians 5:17',
      translation: 'King James Version',
      reflectionPrompt:
          'What old version of yourself are you still carrying around out '
          'of habit?',
    ),
    Verse(
      text:
          'The LORD is nigh unto them that are of a broken heart; and '
          'saveth such as be of a contrite spirit.',
      reference: 'Psalm 34:18',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there a broken part of today you\'ve been hiding instead of '
          'bringing near?',
    ),
    Verse(
      text:
          'Be careful for nothing; but in every thing by prayer and '
          'supplication with thanksgiving let your requests be made known '
          'unto God. And the peace of God, which passeth all '
          'understanding, shall keep your hearts and minds through Christ '
          'Jesus.',
      reference: 'Philippians 4:6-7',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s the one worry you keep picking back up after you\'ve '
          'already set it down?',
    ),
    Verse(
      text:
          'Enter into his gates with thanksgiving, and into his courts '
          'with praise: be thankful unto him, and bless his name.',
      reference: 'Psalm 100:4',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s one thing today you could name out loud as thanks, '
          'before you ask for anything else?',
    ),
    Verse(
      text: 'We love him, because he first loved us.',
      reference: '1 John 4:19',
      translation: 'King James Version',
      reflectionPrompt:
          'Where does your love for others start from obligation instead '
          'of from having been loved first?',
    ),
    Verse(
      text:
          'But the fruit of the Spirit is love, joy, peace, longsuffering, '
          'gentleness, goodness, faith, meekness, temperance: against '
          'such there is no law.',
      reference: 'Galatians 5:22-23',
      translation: 'King James Version',
      reflectionPrompt:
          'Which of these — patience, gentleness, self-control — is '
          'hardest for you to let grow right now?',
    ),
    Verse(
      text: 'Commit thy works unto the LORD, and thy thoughts shall be '
          'established.',
      reference: 'Proverbs 16:3',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s one plan you\'re gripping tightly that you could '
          'actually hand over?',
    ),
    Verse(
      text:
          'But they that wait upon the LORD shall renew their strength; '
          'they shall mount up with wings as eagles; they shall run, and '
          'not be weary; and they shall walk, and not faint.',
      reference: 'Isaiah 40:31',
      translation: 'King James Version',
      reflectionPrompt:
          'Where are you running on empty instead of waiting to be '
          'renewed?',
    ),
    Verse(
      text:
          'The LORD is my light and my salvation; whom shall I fear? the '
          'LORD is the strength of my life; of whom shall I be afraid?',
      reference: 'Psalm 27:1',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s the fear that\'s been quietly setting your agenda '
          'lately?',
    ),
    Verse(
      text:
          'But seek ye first the kingdom of God, and his righteousness; '
          'and all these things shall be added unto you.',
      reference: 'Matthew 6:33',
      translation: 'King James Version',
      reflectionPrompt:
          'What have you been seeking first today, before anything else '
          'got a turn?',
    ),
    Verse(
      text:
          'I will lift up mine eyes unto the hills, from whence cometh my '
          'help. My help cometh from the LORD, which made heaven and '
          'earth.',
      reference: 'Psalm 121:1-2',
      translation: 'King James Version',
      reflectionPrompt:
          'Where have you been looking for help that was never going to '
          'be enough?',
    ),
    Verse(
      text:
          'It is of the LORD\'s mercies that we are not consumed, because '
          'his compassions fail not. They are new every morning: great is '
          'thy faithfulness.',
      reference: 'Lamentations 3:22-23',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s one thing this morning that\'s genuinely new, if you '
          'look for it?',
    ),
    Verse(
      text:
          'And be not conformed to this world: but be ye transformed by '
          'the renewing of your mind, that ye may prove what is that '
          'good, and acceptable, and perfect, will of God.',
      reference: 'Romans 12:2',
      translation: 'King James Version',
      reflectionPrompt:
          'What pattern of thinking have you absorbed from everywhere '
          'except from what\'s true?',
    ),
    Verse(
      text:
          'There is no fear in love; but perfect love casteth out fear: '
          'because fear hath torment. He that feareth is not made perfect '
          'in love.',
      reference: '1 John 4:18',
      translation: 'King James Version',
      reflectionPrompt:
          'Where is fear driving a decision that love should be making '
          'instead?',
    ),
    Verse(
      text:
          'He that dwelleth in the secret place of the most High shall '
          'abide under the shadow of the Almighty. I will say of the '
          'LORD, He is my refuge and my fortress: my God; in him will I '
          'trust.',
      reference: 'Psalm 91:1-2',
      translation: 'King James Version',
      reflectionPrompt:
          'What would it look like to actually rest in shelter today '
          'instead of just hoping for safety?',
    ),
    Verse(
      text:
          'Now faith is the substance of things hoped for, the evidence '
          'of things not seen.',
      reference: 'Hebrews 11:1',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you hoping for that you can\'t yet see — and are you '
          'still willing to trust it?',
    ),
    Verse(
      text:
          'Delight thyself also in the LORD: and he shall give thee the '
          'desires of thine heart.',
      reference: 'Psalm 37:4',
      translation: 'King James Version',
      reflectionPrompt:
          'What do you actually delight in — and does it look like the '
          'life you\'re living?',
    ),
    Verse(
      text:
          'And God shall wipe away all tears from their eyes; and there '
          'shall be no more death, neither sorrow, nor crying, neither '
          'shall there be any more pain: for the former things are passed '
          'away.',
      reference: 'Revelation 21:4',
      translation: 'King James Version',
      reflectionPrompt:
          'What pain are you carrying today that you\'re allowed to '
          'believe won\'t be permanent?',
    ),
  ];

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
