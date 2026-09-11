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
  /// 365 entries — a full year before it repeats — spanning a range of
  /// themes (love, hope, peace, courage, rest, gratitude...) rather than
  /// staying in one book or mood. All King James Version, since it's public
  /// domain and every entry is checked word-for-word against it; each has
  /// its own [reflectionPrompt] rather than reusing [ofTheDay]'s. No curated
  /// `widgetExcerptLarge`/`widgetExcerptSmall` beyond entry 0 — the
  /// word-boundary truncation fallback (see those getters) is good enough,
  /// and hand-curating 364 more clause breaks isn't worth it for now.
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
      text:
          'This is the day which the LORD hath made; we will rejoice and '
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
      text:
          'Commit thy works unto the LORD, and thy thoughts shall be '
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
    Verse(
      text:
          'And Jesus looking upon them saith, With men it is impossible, but not with God: for with God all things are possible.',
      reference: 'Mark 10:27',
      translation: 'King James Version',
      reflectionPrompt:
          'Who have you quietly given up on ever changing, and have you let God still be working on them?',
    ),
    Verse(
      text:
          'Two are better than one; because they have a good reward for their labour. For if they fall, the one will lift up his fellow: but woe to him that is alone when he falleth; for he hath not another to help him up.',
      reference: 'Ecclesiastes 4:9-10',
      translation: 'King James Version',
      reflectionPrompt:
          'Who\'s walking close enough to you right now to actually catch you if you fell?',
    ),
    Verse(
      text:
          'These things I have spoken unto you, that in me ye might have peace. In the world ye shall have tribulation: but be of good cheer; I have overcome the world.',
      reference: 'John 16:33',
      translation: 'King James Version',
      reflectionPrompt:
          'What trouble are you facing today that you\'re letting steal your peace instead of remembering it\'s already been overcome?',
    ),
    Verse(
      text:
          'And they said, Believe on the Lord Jesus Christ, and thou shalt be saved, and thy house.',
      reference: 'Acts 16:31',
      translation: 'King James Version',
      reflectionPrompt:
          'Who in your household or family are you praying will come to actually believe, and are you still praying?',
    ),
    Verse(
      text:
          'Arise, shine; for thy light is come, and the glory of the LORD is risen upon thee.',
      reference: 'Isaiah 60:1',
      translation: 'King James Version',
      reflectionPrompt:
          'Why are you still sitting in the dark today when you were actually told to get up and shine?',
    ),
    Verse(
      text:
          'I wait for the LORD, my soul doth wait, and in his word do I hope.',
      reference: 'Psalm 130:5',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s the promise you\'re clinging to while you wait on something that hasn\'t come yet?',
    ),
    Verse(
      text:
          'Honour thy father and thy mother: that thy days may be long upon the land which the LORD thy God giveth thee.',
      reference: 'Exodus 20:12',
      translation: 'King James Version',
      reflectionPrompt:
          'How do you actually treat your parents\' voice in your life these days -- honored, or just tolerated?',
    ),
    Verse(
      text:
          'Give therefore thy servant an understanding heart to judge thy people, that I may discern between good and bad: for who is able to judge this thy so great a people?',
      reference: '1 Kings 3:9',
      translation: 'King James Version',
      reflectionPrompt:
          'Where in your life are you making calls today that need more wisdom than you\'ve asked for?',
    ),
    Verse(
      text:
          'In whom we have redemption through his blood, the forgiveness of sins, according to the riches of his grace;',
      reference: 'Ephesians 1:7',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you still measuring some sin against your own effort instead of against the riches of grace that already covered it?',
    ),
    Verse(
      text:
          'For I am the LORD, I change not; therefore ye sons of Jacob are not consumed.',
      reference: 'Malachi 3:6',
      translation: 'King James Version',
      reflectionPrompt:
          'Has enough changed around you lately that you needed reminding God hasn\'t changed with it?',
    ),
    Verse(
      text: 'Seek the LORD and his strength, seek his face continually.',
      reference: '1 Chronicles 16:11',
      translation: 'King James Version',
      reflectionPrompt:
          'Is your search for God a daily habit or something you only reach for in emergencies?',
    ),
    Verse(
      text:
          'Turn again, and tell Hezekiah the captain of my people, Thus saith the LORD, the God of David thy father, I have heard thy prayer, I have seen thy tears: behold, I will heal thee: on the third day thou shalt go up unto the house of the LORD.',
      reference: '2 Kings 20:5',
      translation: 'King James Version',
      reflectionPrompt:
          'Are there tears you\'ve cried that you\'re not sure anyone, even God, actually saw?',
    ),
    Verse(
      text:
          'According as his divine power hath given unto us all things that pertain unto life and godliness, through the knowledge of him that hath called us to glory and virtue:',
      reference: '2 Peter 1:3',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you still waiting to feel equipped for something you\'ve actually already been given what you need for?',
    ),
    Verse(
      text:
          'The LORD is good, a strong hold in the day of trouble; and he knoweth them that trust in him.',
      reference: 'Nahum 1:7',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there trouble right now you haven\'t let yourself run into, rather than around?',
    ),
    Verse(
      text:
          'Fight the good fight of faith, lay hold on eternal life, whereunto thou art also called, and hast professed a good profession before many witnesses.',
      reference: '1 Timothy 6:12',
      translation: 'King James Version',
      reflectionPrompt:
          'Have you quietly stopped showing up for some fight for your faith?',
    ),
    Verse(
      text:
          'And he arose, and came to his father. But when he was yet a great way off, his father saw him, and had compassion, and ran, and fell on his neck, and kissed him.',
      reference: 'Luke 15:20',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you afraid to come home to today, assuming disappointment instead of a run to meet you?',
    ),
    Verse(
      text: 'Faithful is he that calleth you, who also will do it.',
      reference: '1 Thessalonians 5:24',
      translation: 'King James Version',
      reflectionPrompt:
          'Has God called you to something you\'re worried he might not actually follow through on?',
    ),
    Verse(
      text:
          'And he humbled thee, and suffered thee to hunger, and fed thee with manna, which thou knewest not, neither did thy fathers know; that he might make thee know that man doth not live by bread only, but by every word that proceedeth out of the mouth of the LORD doth man live.',
      reference: 'Deuteronomy 8:3',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there something filling you up today that doesn\'t actually sustain you?',
    ),
    Verse(
      text:
          'Acquaint now thyself with him, and be at peace: thereby good shall come unto thee.',
      reference: 'Job 22:21',
      translation: 'King James Version',
      reflectionPrompt:
          'What would getting reacquainted with God, instead of running on old familiarity, look like today?',
    ),
    Verse(
      text:
          'Take therefore no thought for the morrow: for the morrow shall take thought for the things of itself. Sufficient unto the day is the evil thereof.',
      reference: 'Matthew 6:34',
      translation: 'King James Version',
      reflectionPrompt:
          'What tomorrow-shaped worry is stealing your attention from what\'s actually in front of you today?',
    ),
    Verse(
      text:
          'Jesus said unto him, If thou canst believe, all things are possible to him that believeth.',
      reference: 'Mark 9:23',
      translation: 'King James Version',
      reflectionPrompt:
          'What would you attempt today if you actually believed it were possible?',
    ),
    Verse(
      text: 'Blessed are the pure in heart: for they shall see God.',
      reference: 'Matthew 5:8',
      translation: 'King James Version',
      reflectionPrompt:
          'Is something cluttering your heart right now, making it harder to actually see God clearly?',
    ),
    Verse(
      text:
          'O God, thou art my God; early will I seek thee: my soul thirsteth for thee, my flesh longeth for thee in a dry and thirsty land, where no water is;',
      reference: 'Psalm 63:1',
      translation: 'King James Version',
      reflectionPrompt:
          'Could you seek God today before the day gets its hooks into you?',
    ),
    Verse(
      text:
          'For what shall it profit a man, if he shall gain the whole world, and lose his own soul?',
      reference: 'Mark 8:36',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you currently trading your peace or integrity for something that isn\'t actually worth the cost?',
    ),
    Verse(
      text:
          'But as it is written, Eye hath not seen, nor ear heard, neither have entered into the heart of man, the things which God hath prepared for them that love him.',
      reference: '1 Corinthians 2:9',
      translation: 'King James Version',
      reflectionPrompt:
          'Could God have prepared something bigger than anything you\'ve let yourself imagine?',
    ),
    Verse(
      text:
          'I will praise thee; for I am fearfully and wonderfully made: marvellous are thy works; and that my soul knoweth right well.',
      reference: 'Psalm 139:14',
      translation: 'King James Version',
      reflectionPrompt:
          'What part of how you were made do you criticize instead of marvel at?',
    ),
    Verse(
      text:
          'But now, O LORD, thou art our father; we are the clay, and thou our potter; and we all are the work of thy hand.',
      reference: 'Isaiah 64:8',
      translation: 'King James Version',
      reflectionPrompt:
          'Where are you resisting being shaped right now instead of letting the potter\'s hands do their work?',
    ),
    Verse(
      text:
          'Many waters cannot quench love, neither can the floods drown it: if a man would give all the substance of his house for love, it would utterly be contemned.',
      reference: 'Song of Solomon 8:7',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s tested the love in your closest relationship lately, and did it actually hold?',
    ),
    Verse(
      text:
          'So God created man in his own image, in the image of God created he him; male and female created he them.',
      reference: 'Genesis 1:27',
      translation: 'King James Version',
      reflectionPrompt:
          'Whose worth have you quietly ranked below your own today, forgetting they carry the same image you do?',
    ),
    Verse(
      text:
          'For if thou altogether holdest thy peace at this time, then shall there enlargement and deliverance arise to the Jews from another place; but thou and thy father\'s house shall be destroyed: and who knoweth whether thou art come to the kingdom for such a time as this?',
      reference: 'Esther 4:14',
      translation: 'King James Version',
      reflectionPrompt:
          'What if the position you\'re in right now isn\'t random but exactly where you\'re needed?',
    ),
    Verse(
      text:
          'Greater love hath no man than this, that a man lay down his life for his friends.',
      reference: 'John 15:13',
      translation: 'King James Version',
      reflectionPrompt:
          'Could you actually lay down something of yourself for a friend today?',
    ),
    Verse(
      text: 'Can two walk together, except they be agreed?',
      reference: 'Amos 3:3',
      translation: 'King James Version',
      reflectionPrompt:
          'Where are you and someone close to you walking in different directions without having admitted it yet?',
    ),
    Verse(
      text: 'He healeth the broken in heart, and bindeth up their wounds.',
      reference: 'Psalm 147:3',
      translation: 'King James Version',
      reflectionPrompt:
          'What wound are you still walking around with unbandaged because you haven\'t brought it to the healer?',
    ),
    Verse(
      text:
          'The fear of the LORD is the beginning of knowledge: but fools despise wisdom and instruction.',
      reference: 'Proverbs 1:7',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you trying to figure out today that might actually start with humility instead of more information?',
    ),
    Verse(
      text:
          'Wherefore comfort yourselves together, and edify one another, even as also ye do.',
      reference: '1 Thessalonians 5:11',
      translation: 'King James Version',
      reflectionPrompt:
          'Who could use a word of encouragement from you today that you haven\'t gotten around to giving?',
    ),
    Verse(
      text:
          'Bless the LORD, O my soul, and forget not all his benefits: Who forgiveth all thine iniquities; who healeth all thy diseases;',
      reference: 'Psalm 103:2-3',
      translation: 'King James Version',
      reflectionPrompt:
          'Have you already forgotten to thank God for some benefit this week?',
    ),
    Verse(
      text:
          'I will heal their backsliding, I will love them freely: for mine anger is turned away from him.',
      reference: 'Hosea 14:4',
      translation: 'King James Version',
      reflectionPrompt:
          'What wandering are you ashamed of that you haven\'t let yourself believe is already forgiven?',
    ),
    Verse(
      text:
          'Keep yourselves in the love of God, looking for the mercy of our Lord Jesus Christ unto eternal life.',
      reference: 'Jude 1:21',
      translation: 'King James Version',
      reflectionPrompt:
          'Could you name one practical way to keep yourself in God\'s love today instead of just hoping to stay there passively?',
    ),
    Verse(
      text:
          'For the wages of sin is death; but the gift of God is eternal life through Jesus Christ our Lord.',
      reference: 'Romans 6:23',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you working yourself to death today for something that was actually meant to be received as a gift?',
    ),
    Verse(
      text:
          'A merry heart doeth good like a medicine: but a broken spirit drieth the bones.',
      reference: 'Proverbs 17:22',
      translation: 'King James Version',
      reflectionPrompt:
          'Is something weighing your spirit down today that\'s affecting more of you than you realize?',
    ),
    Verse(
      text:
          'Know therefore that the LORD thy God, he is God, the faithful God, which keepeth covenant and mercy with them that love him and keep his commandments to a thousand generations;',
      reference: 'Deuteronomy 7:9',
      translation: 'King James Version',
      reflectionPrompt:
          'What have you inherited in faith or character that you\'re passing on without even realizing it?',
    ),
    Verse(
      text:
          'But the Lord is faithful, who shall stablish you, and keep you from evil.',
      reference: '2 Thessalonians 3:3',
      translation: 'King James Version',
      reflectionPrompt:
          'Where do you feel unsteady today that you haven\'t asked to be established in?',
    ),
    Verse(
      text:
          'Not that I speak in respect of want: for I have learned, in whatsoever state I am, therewith to be content.',
      reference: 'Philippians 4:11',
      translation: 'King James Version',
      reflectionPrompt:
          'What circumstance are you refusing to be content in until it changes?',
    ),
    Verse(
      text:
          'O give thanks unto the LORD; for he is good: for his mercy endureth for ever.',
      reference: 'Psalm 136:1',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there a mercy you\'ve received so many times you\'ve stopped noticing it\'s still happening?',
    ),
    Verse(
      text:
          'Behold, what manner of love the Father hath bestowed upon us, that we should be called the sons of God: therefore the world knoweth us not, because it knew him not.',
      reference: '1 John 3:1',
      translation: 'King James Version',
      reflectionPrompt:
          'Do you actually live today like someone who\'s been called a child of God, or like someone still trying to prove they belong?',
    ),
    Verse(
      text:
          'My flesh and my heart faileth: but God is the strength of my heart, and my portion for ever.',
      reference: 'Psalm 73:26',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s failing you right now that you\'re trying to replace instead of letting God be your strength?',
    ),
    Verse(
      text:
          'And if it seem evil unto you to serve the LORD, choose you this day whom ye will serve; whether the gods which your fathers served that were on the other side of the flood, or the gods of the Amorites, in whose land ye dwell: but as for me and my house, we will serve the LORD.',
      reference: 'Joshua 24:15',
      translation: 'King James Version',
      reflectionPrompt:
          'If today were the day you had to choose out loud who you serve, what would your actions already be saying?',
    ),
    Verse(
      text:
          'The name of the LORD is a strong tower: the righteous runneth into it, and is safe.',
      reference: 'Proverbs 18:10',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you running toward for safety today instead of running to God?',
    ),
    Verse(
      text:
          'The LORD is my rock, and my fortress, and my deliverer; my God, my strength, in whom I will trust; my buckler, and the horn of my salvation, and my high tower.',
      reference: 'Psalm 18:2',
      translation: 'King James Version',
      reflectionPrompt:
          'Which of today\'s problems needs a fortress more than it needs your own strength?',
    ),
    Verse(
      text:
          'And the angel of the LORD appeared unto him, and said unto him, The LORD is with thee, thou mighty man of valour.',
      reference: 'Judges 6:12',
      translation: 'King James Version',
      reflectionPrompt:
          'What if the thing you call weakness is exactly where God says mighty?',
    ),
    Verse(
      text:
          'But ye are a chosen generation, a royal priesthood, an holy nation, a peculiar people; that ye should shew forth the praises of him who hath called you out of darkness into his marvellous light:',
      reference: '1 Peter 2:9',
      translation: 'King James Version',
      reflectionPrompt:
          'Do you sometimes forget you don\'t have to go back to the darkness you were called out of?',
    ),
    Verse(
      text:
          'Be still, and know that I am God: I will be exalted among the heathen, I will be exalted in the earth.',
      reference: 'Psalm 46:10',
      translation: 'King James Version',
      reflectionPrompt:
          'Could you name the first thing you\'d have to stop doing today to actually be still?',
    ),
    Verse(
      text:
          'Rejoicing in hope; patient in tribulation; continuing instant in prayer;',
      reference: 'Romans 12:12',
      translation: 'King James Version',
      reflectionPrompt:
          'Which is harder for you right now -- staying hopeful, staying patient, or staying prayerful?',
    ),
    Verse(
      text:
          'The LORD is my strength and song, and he is become my salvation: he is my God, and I will prepare him an habitation; my father\'s God, and I will exalt him.',
      reference: 'Exodus 15:2',
      translation: 'King James Version',
      reflectionPrompt:
          'When was the last time something hard for you turned into something you now sing about?',
    ),
    Verse(
      text:
          'So teach us to number our days, that we may apply our hearts unto wisdom.',
      reference: 'Psalm 90:12',
      translation: 'King James Version',
      reflectionPrompt:
          'If you actually counted the days you have left, would today look different?',
    ),
    Verse(
      text:
          'For thus saith the Lord GOD, the Holy One of Israel; In returning and rest shall ye be saved; in quietness and in confidence shall be your strength: and ye would not.',
      reference: 'Isaiah 30:15',
      translation: 'King James Version',
      reflectionPrompt:
          'Where are you choosing to strive today when rest was actually the stronger option?',
    ),
    Verse(
      text:
          'But he knoweth the way that I take: when he hath tried me, I shall come forth as gold.',
      reference: 'Job 23:10',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you being refined by right now that you\'d rather just be rescued from?',
    ),
    Verse(
      text:
          'And he believed in the LORD; and he counted it to him for righteousness.',
      reference: 'Genesis 15:6',
      translation: 'King James Version',
      reflectionPrompt:
          'What would it look like to let simple trust count for more today than having everything figured out?',
    ),
    Verse(
      text:
          'Neither is there salvation in any other: for there is none other name under heaven given among men, whereby we must be saved.',
      reference: 'Acts 4:12',
      translation: 'King James Version',
      reflectionPrompt:
          'Where are you looking for rescue today from something other than the one place it actually comes from?',
    ),
    Verse(
      text:
          'But thou, O LORD, art a shield for me; my glory, and the lifter up of mine head.',
      reference: 'Psalm 3:3',
      translation: 'King James Version',
      reflectionPrompt:
          'Who or what has been holding your head down that you could let God lift instead?',
    ),
    Verse(
      text:
          'The LORD our God be with us, as he was with our fathers: let him not leave us, nor forsake us:',
      reference: '1 Kings 8:57',
      translation: 'King James Version',
      reflectionPrompt:
          'Have you thanked the people, or God, for the faith you inherited from those before you?',
    ),
    Verse(
      text:
          'Put on therefore, as the elect of God, holy and beloved, bowels of mercies, kindness, humbleness of mind, meekness, longsuffering;',
      reference: 'Colossians 3:12',
      translation: 'King James Version',
      reflectionPrompt:
          'Which of these -- kindness, patience, humility -- did you forget to put on before you left the house today?',
    ),
    Verse(
      text:
          'The LORD hath appeared of old unto me, saying, Yea, I have loved thee with an everlasting love: therefore with lovingkindness have I drawn thee.',
      reference: 'Jeremiah 31:3',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s drawn you closer to God recently, and was it love, or was it just crisis?',
    ),
    Verse(
      text:
          'Thou wilt keep him in perfect peace, whose mind is stayed on thee: because he trusteth in thee.',
      reference: 'Isaiah 26:3',
      translation: 'King James Version',
      reflectionPrompt:
          'Where is your mind actually fixed right now, and is that where your peace is coming from or where it\'s leaking out?',
    ),
    Verse(
      text:
          'But thanks be to God, which giveth us the victory through our Lord Jesus Christ.',
      reference: '1 Corinthians 15:57',
      translation: 'King James Version',
      reflectionPrompt:
          'What victory in your life have you claimed for yourself that was actually a gift?',
    ),
    Verse(
      text:
          'For which cause we faint not; but though our outward man perish, yet the inward man is renewed day by day.',
      reference: '2 Corinthians 4:16',
      translation: 'King James Version',
      reflectionPrompt:
          'Is something wearing down on the outside for you right now that you\'re not tending to on the inside?',
    ),
    Verse(
      text:
          'For bodily exercise profiteth little: but godliness is profitable unto all things, having promise of the life that now is, and of that which is to come.',
      reference: '1 Timothy 4:8',
      translation: 'King James Version',
      reflectionPrompt:
          'How much of your discipline this week has gone toward your body compared to your soul?',
    ),
    Verse(
      text:
          'A man that hath friends must shew himself friendly: and there is a friend that sticketh closer than a brother.',
      reference: 'Proverbs 18:24',
      translation: 'King James Version',
      reflectionPrompt:
          'Who has stuck closer to you than family has, and have you told them what that\'s meant?',
    ),
    Verse(
      text:
          'And Jesus said unto them, I am the bread of life: he that cometh to me shall never hunger; and he that believeth on me shall never thirst.',
      reference: 'John 6:35',
      translation: 'King James Version',
      reflectionPrompt:
          'Underneath the actual hunger you feel today, what are you really hungry for?',
    ),
    Verse(
      text:
          'Yet now be strong, O Zerubbabel, saith the LORD; and be strong, O Joshua, son of Josedech, the high priest; and be strong, all ye people of the land, saith the LORD, and work: for I am with you, saith the LORD of hosts:',
      reference: 'Haggai 2:4',
      translation: 'King James Version',
      reflectionPrompt:
          'Could you pick back up some half-finished work today, knowing you\'re not doing it alone?',
    ),
    Verse(
      text:
          'There are many devices in a man\'s heart; nevertheless the counsel of the LORD, that shall stand.',
      reference: 'Proverbs 19:21',
      translation: 'King James Version',
      reflectionPrompt:
          'Which of your plans are you gripping as if it has to be your version that wins?',
    ),
    Verse(
      text:
          'Now the Lord is that Spirit: and where the Spirit of the Lord is, there is liberty.',
      reference: '2 Corinthians 3:17',
      translation: 'King James Version',
      reflectionPrompt:
          'Where do you feel most trapped today, and have you invited the Spirit into that specific place?',
    ),
    Verse(
      text:
          'And he said to them all, If any man will come after me, let him deny himself, and take up his cross daily, and follow me.',
      reference: 'Luke 9:23',
      translation: 'King James Version',
      reflectionPrompt:
          'What would denying yourself actually look like today, in something small and specific?',
    ),
    Verse(
      text:
          'And above all things have fervent charity among yourselves: for charity shall cover the multitude of sins.',
      reference: '1 Peter 4:8',
      translation: 'King James Version',
      reflectionPrompt:
          'Whose flaws could you choose to cover with love today instead of keeping score of?',
    ),
    Verse(
      text:
          'Therefore I say unto you, What things soever ye desire, when ye pray, believe that ye receive them, and ye shall have them.',
      reference: 'Mark 11:24',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you praying about something today with more doubt than expectation?',
    ),
    Verse(
      text:
          'Keep thy heart with all diligence; for out of it are the issues of life.',
      reference: 'Proverbs 4:23',
      translation: 'King James Version',
      reflectionPrompt:
          'Is something getting into your heart unguarded today that\'s shaping more than you realize?',
    ),
    Verse(
      text:
          'What? know ye not that your body is the temple of the Holy Ghost which is in you, which ye have of God, and ye are not your own? For ye are bought with a price: therefore glorify God in your body, and in your spirit, which are God\'s.',
      reference: '1 Corinthians 6:19-20',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you doing to yourself today that you wouldn\'t do if you remembered whose you actually are?',
    ),
    Verse(
      text:
          'And he spake a parable unto them to this end, that men ought always to pray, and not to faint;',
      reference: 'Luke 18:1',
      translation: 'King James Version',
      reflectionPrompt:
          'What have you nearly stopped praying about because it\'s taken longer than you hoped?',
    ),
    Verse(
      text:
          'The way of a fool is right in his own eyes: but he that hearkeneth unto counsel is wise.',
      reference: 'Proverbs 12:15',
      translation: 'King James Version',
      reflectionPrompt:
          'Whose advice have you been dismissing lately because it wasn\'t what you wanted to hear?',
    ),
    Verse(
      text:
          'For we are his workmanship, created in Christ Jesus unto good works, which God hath before ordained that we should walk in them.',
      reference: 'Ephesians 2:10',
      translation: 'King James Version',
      reflectionPrompt:
          'What good work do you suspect you were specifically made for that you keep putting off?',
    ),
    Verse(
      text:
          'So shall my word be that goeth forth out of my mouth: it shall not return unto me void, but it shall accomplish that which I please, and it shall prosper in the thing whereto I sent it.',
      reference: 'Isaiah 55:11',
      translation: 'King James Version',
      reflectionPrompt:
          'What word from God have you prayed or read that you\'ve quietly assumed won\'t actually do anything?',
    ),
    Verse(
      text:
          'Cause me to hear thy lovingkindness in the morning; for in thee do I trust: cause me to know the way wherein I should walk; for I lift up my soul unto thee.',
      reference: 'Psalm 143:8',
      translation: 'King James Version',
      reflectionPrompt:
          'What decision are you facing that you haven\'t actually asked to be shown the way through yet?',
    ),
    Verse(
      text:
          'Ask, and it shall be given you; seek, and ye shall find; knock, and it shall be opened unto you:',
      reference: 'Matthew 7:7',
      translation: 'King James Version',
      reflectionPrompt:
          'Have you stopped asking for something because you got tired of not seeing an answer yet?',
    ),
    Verse(
      text:
          'But be ye doers of the word, and not hearers only, deceiving your own selves.',
      reference: 'James 1:22',
      translation: 'King James Version',
      reflectionPrompt:
          'Have you agreed with something in scripture or a sermon lately that you haven\'t actually put into practice?',
    ),
    Verse(
      text:
          'And, behold, I am with thee, and will keep thee in all places whither thou goest, and will bring thee again into this land; for I will not leave thee, until I have done that which I have spoken to thee of.',
      reference: 'Genesis 28:15',
      translation: 'King James Version',
      reflectionPrompt:
          'Where are you assuming you\'re on your own today when a promise says otherwise?',
    ),
    Verse(
      text:
          'The heavens declare the glory of God; and the firmament sheweth his handywork.',
      reference: 'Psalm 19:1',
      translation: 'King James Version',
      reflectionPrompt:
          'When did you last actually stop and let the sky say something to you?',
    ),
    Verse(
      text: 'Hatred stirreth up strifes: but love covereth all sins.',
      reference: 'Proverbs 10:12',
      translation: 'King James Version',
      reflectionPrompt:
          'Whose mistake are you still stirring up instead of covering with love?',
    ),
    Verse(
      text:
          'A new heart also will I give you, and a new spirit will I put within you: and I will take away the stony heart out of your flesh, and I will give you an heart of flesh.',
      reference: 'Ezekiel 36:26',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there a part of you stuck in an old pattern that actually needs replacing, not just managing?',
    ),
    Verse(
      text:
          'Give, and it shall be given unto you; good measure, pressed down, and shaken together, and running over, shall men give into your bosom. For with the same measure that ye mete withal it shall be measured to you again.',
      reference: 'Luke 6:38',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you holding something back from giving today because you\'re not sure it will come back to you?',
    ),
    Verse(
      text:
          'My voice shalt thou hear in the morning, O LORD; in the morning will I direct my prayer unto thee, and will look up.',
      reference: 'Psalm 5:3',
      translation: 'King James Version',
      reflectionPrompt:
          'What does the first ten minutes of your morning actually go toward?',
    ),
    Verse(
      text:
          'That if thou shalt confess with thy mouth the Lord Jesus, and shalt believe in thine heart that God hath raised him from the dead, thou shalt be saved.',
      reference: 'Romans 10:9',
      translation: 'King James Version',
      reflectionPrompt:
          'Is your faith today something you\'d actually say out loud, or just privately assume?',
    ),
    Verse(
      text:
          'A man\'s heart deviseth his way: but the LORD directeth his steps.',
      reference: 'Proverbs 16:9',
      translation: 'King James Version',
      reflectionPrompt:
          'How tightly are you holding today\'s plan compared to how open you are to it being redirected?',
    ),
    Verse(
      text: 'They that sow in tears shall reap in joy.',
      reference: 'Psalm 126:5',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you planting right now through tears that you haven\'t let yourself believe will turn into joy?',
    ),
    Verse(
      text:
          'This book of the law shall not depart out of thy mouth; but thou shalt meditate therein day and night, that thou mayest observe to do according to all that is written therein: for then thou shalt make thy way prosperous, and then thou shalt have good success.',
      reference: 'Joshua 1:8',
      translation: 'King James Version',
      reflectionPrompt:
          'Is your mind on repeat with something other than the words that actually shape you?',
    ),
    Verse(
      text:
          'Let every thing that hath breath praise the LORD. Praise ye the LORD.',
      reference: 'Psalm 150:6',
      translation: 'King James Version',
      reflectionPrompt:
          'Would today change if praise were the first thing your breath went toward instead of the last?',
    ),
    Verse(
      text:
          'For in him we live, and move, and have our being; as certain also of your own poets have said, For we are also his offspring.',
      reference: 'Acts 17:28',
      translation: 'King James Version',
      reflectionPrompt:
          'Where do you act like your life is self-sustained instead of held together by something bigger?',
    ),
    Verse(
      text:
          'Only fear the LORD, and serve him in truth with all your heart: for consider how great things he hath done for you.',
      reference: '1 Samuel 12:24',
      translation: 'King James Version',
      reflectionPrompt:
          'Has something God\'s done for you failed to change how seriously you take following him?',
    ),
    Verse(
      text:
          'Shew me thy ways, O LORD; teach me thy paths. Lead me in thy truth, and teach me: for thou art the God of my salvation; on thee do I wait all the day.',
      reference: 'Psalm 25:4-5',
      translation: 'King James Version',
      reflectionPrompt:
          'Where do you want direction today but haven\'t actually asked for it?',
    ),
    Verse(
      text:
          'A soft answer turneth away wrath: but grievous words stir up anger.',
      reference: 'Proverbs 15:1',
      translation: 'King James Version',
      reflectionPrompt:
          'In the next hard conversation you have today, will your words de-escalate or add fuel?',
    ),
    Verse(
      text:
          'For thou art my hope, O Lord GOD: thou art my trust from my youth.',
      reference: 'Psalm 71:5',
      translation: 'King James Version',
      reflectionPrompt:
          'How has what you actually trust in shifted since you were young, and was it for the better?',
    ),
    Verse(
      text:
          'Ye are the light of the world. A city that is set on an hill cannot be hid.',
      reference: 'Matthew 5:14',
      translation: 'King James Version',
      reflectionPrompt:
          'Where are you dimming yourself today out of fear of being seen?',
    ),
    Verse(
      text: 'Set your affection on things above, not on things on the earth.',
      reference: 'Colossians 3:2',
      translation: 'King James Version',
      reflectionPrompt:
          'Is your attention fixed on the ground today when it could be lifted higher?',
    ),
    Verse(
      text: 'What time I am afraid, I will trust in thee.',
      reference: 'Psalm 56:3',
      translation: 'King James Version',
      reflectionPrompt:
          'When fear shows up today, what would choosing trust over it actually look like in the moment?',
    ),
    Verse(
      text:
          'And now abideth faith, hope, charity, these three; but the greatest of these is charity.',
      reference: '1 Corinthians 13:13',
      translation: 'King James Version',
      reflectionPrompt:
          'Where are you majoring in being right or being certain today instead of majoring in love?',
    ),
    Verse(
      text:
          'The LORD is my strength and my shield; my heart trusted in him, and I am helped: therefore my heart greatly rejoiceth; and with my song will I praise him.',
      reference: 'Psalm 28:7',
      translation: 'King James Version',
      reflectionPrompt:
          'What did trusting God actually get you through recently that you haven\'t celebrated yet?',
    ),
    Verse(
      text:
          'Behold, God is my salvation; I will trust, and not be afraid: for the LORD JEHOVAH is my strength and my song; he also is become my salvation.',
      reference: 'Isaiah 12:2',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there a fear today that trust is actually strong enough to replace, if you let it?',
    ),
    Verse(
      text:
          'I will instruct thee and teach thee in the way which thou shalt go: I will guide thee with mine eye.',
      reference: 'Psalm 32:8',
      translation: 'King James Version',
      reflectionPrompt:
          'What decision today would go easier if you actually paused to be guided instead of guessing?',
    ),
    Verse(
      text:
          'He brought me to the banqueting house, and his banner over me was love.',
      reference: 'Song of Solomon 2:4',
      translation: 'King James Version',
      reflectionPrompt:
          'When did someone last make you feel publicly, unmistakably loved, and when did you last do that for someone else?',
    ),
    Verse(
      text:
          'As the hart panteth after the water brooks, so panteth my soul after thee, O God.',
      reference: 'Psalm 42:1',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you actually thirsty for today underneath everything you\'re chasing?',
    ),
    Verse(
      text:
          'A good name is rather to be chosen than great riches, and loving favour rather than silver and gold.',
      reference: 'Proverbs 22:1',
      translation: 'King James Version',
      reflectionPrompt:
          'Would you protect your reputation for integrity harder today than your bank balance?',
    ),
    Verse(
      text:
          'Stand fast therefore in the liberty wherewith Christ hath made us free, and be not entangled again with the yoke of bondage.',
      reference: 'Galatians 5:1',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you drifting back toward an old bondage you\'ve already been set free from once?',
    ),
    Verse(
      text:
          'Except the LORD build the house, they labour in vain that build it: except the LORD keep the city, the watchman waketh but in vain.',
      reference: 'Psalm 127:1',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you building something right now without actually including God in the plans?',
    ),
    Verse(
      text: 'For with God nothing shall be impossible.',
      reference: 'Luke 1:37',
      translation: 'King James Version',
      reflectionPrompt:
          'What unexpected, even unbelievable news are you sitting with today that you need to trust God can actually handle?',
    ),
    Verse(
      text:
          'For the word of God is quick, and powerful, and sharper than any twoedged sword, piercing even to the dividing asunder of soul and spirit, and of the joints and marrow, and is a discerner of the thoughts and intents of the heart.',
      reference: 'Hebrews 4:12',
      translation: 'King James Version',
      reflectionPrompt:
          'What have you been avoiding looking at honestly that scripture keeps cutting straight toward?',
    ),
    Verse(
      text:
          'Also I heard the voice of the Lord, saying, Whom shall I send, and who will go for us? Then said I, Here am I; send me.',
      reference: 'Isaiah 6:8',
      translation: 'King James Version',
      reflectionPrompt:
          'If you heard that question today, would send me actually be your honest answer?',
    ),
    Verse(
      text:
          'But as for you, ye thought evil against me; but God meant it unto good, to bring to pass, as it is this day, to save much people alive.',
      reference: 'Genesis 50:20',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there a wrong done to you that you\'re still waiting to see turned into something good?',
    ),
    Verse(
      text: 'But godliness with contentment is great gain.',
      reference: '1 Timothy 6:6',
      translation: 'King James Version',
      reflectionPrompt:
          'What would you have to stop chasing to actually feel like you already have enough?',
    ),
    Verse(
      text:
          'Search me, O God, and know my heart: try me, and know my thoughts: And see if there be any wicked way in me, and lead me in the way everlasting.',
      reference: 'Psalm 139:23-24',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there a part of you that you\'d rather God not look at too closely today?',
    ),
    Verse(
      text: 'The LORD shall fight for you, and ye shall hold your peace.',
      reference: 'Exodus 14:14',
      translation: 'King James Version',
      reflectionPrompt:
          'What battle are you exhausting yourself in today that you could actually stop fighting?',
    ),
    Verse(
      text:
          'Then spake Jesus again unto them, saying, I am the light of the world: he that followeth me shall not walk in darkness, but shall have the light of life.',
      reference: 'John 8:12',
      translation: 'King James Version',
      reflectionPrompt:
          'What decision today would look different if you were walking toward light instead of guessing in the dark?',
    ),
    Verse(
      text:
          'Let your light so shine before men, that they may see your good works, and glorify your Father which is in heaven.',
      reference: 'Matthew 5:16',
      translation: 'King James Version',
      reflectionPrompt:
          'When people see something good in you today, who do you want them to actually credit?',
    ),
    Verse(
      text:
          'But if from thence thou shalt seek the LORD thy God, thou shalt find him, if thou seek him with all thy heart and with all thy soul.',
      reference: 'Deuteronomy 4:29',
      translation: 'King James Version',
      reflectionPrompt:
          'Is the way you\'re seeking God today halfhearted, or with everything you\'ve got?',
    ),
    Verse(
      text:
          'A new commandment I give unto you, That ye love one another; as I have loved you, that ye also love one another.',
      reference: 'John 13:34',
      translation: 'King James Version',
      reflectionPrompt:
          'Who is hardest for you to love the way you\'ve been loved, and what would that love actually require today?',
    ),
    Verse(
      text:
          'Be merciful unto me, O God, be merciful unto me: for my soul trusteth in thee: yea, in the shadow of thy wings will I make my refuge, until these calamities be overpast.',
      reference: 'Psalm 57:1',
      translation: 'King James Version',
      reflectionPrompt:
          'What season are you just trying to survive right now, and where are you taking shelter in it?',
    ),
    Verse(
      text:
          'And the Spirit and the bride say, Come. And let him that heareth say, Come. And let him that is athirst come. And whosoever will, let him take the water of life freely.',
      reference: 'Revelation 22:17',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s stopping you from simply coming today, when the invitation was never about earning it?',
    ),
    Verse(
      text:
          'I am the vine, ye are the branches: He that abideth in me, and I in him, the same bringeth forth much fruit: for without me ye can do nothing.',
      reference: 'John 15:5',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you trying to produce today disconnected from the source you actually need?',
    ),
    Verse(
      text:
          'And I looked, and rose up, and said unto the nobles, and to the rulers, and to the rest of the people, Be not ye afraid of them: remember the Lord, which is great and terrible, and fight for your brethren, your sons, and your daughters, your wives, and your houses.',
      reference: 'Nehemiah 4:14',
      translation: 'King James Version',
      reflectionPrompt:
          'Who are you responsible for protecting today, and is fear or love driving how you show up for them?',
    ),
    Verse(
      text:
          'For I am not ashamed of the gospel of Christ: for it is the power of God unto salvation to every one that believeth; to the Jew first, and also to the Greek.',
      reference: 'Romans 1:16',
      translation: 'King James Version',
      reflectionPrompt:
          'Where have you gone quiet about your faith today out of fear of what people would think?',
    ),
    Verse(
      text:
          'But grow in grace, and in the knowledge of our Lord and Saviour Jesus Christ. To him be glory both now and for ever. Amen.',
      reference: '2 Peter 3:18',
      translation: 'King James Version',
      reflectionPrompt:
          'Where have you gotten comfortable staying the same instead of still growing?',
    ),
    Verse(
      text:
          'Although the fig tree shall not blossom, neither shall fruit be in the vines; the labour of the olive shall fail, and the fields shall yield no meat; the flock shall be cut off from the fold, and there shall be no herd in the stalls: Yet I will rejoice in the LORD, I will joy in the God of my salvation.',
      reference: 'Habakkuk 3:17-18',
      translation: 'King James Version',
      reflectionPrompt:
          'If everything you\'re counting on today came up empty, would you still have a reason to rejoice?',
    ),
    Verse(
      text:
          'For this child I prayed; and the LORD hath given me my petition which I asked of him:',
      reference: '1 Samuel 1:27',
      translation: 'King James Version',
      reflectionPrompt:
          'What answered prayer in your life have you stopped thanking God for?',
    ),
    Verse(
      text:
          'Better is the end of a thing than the beginning thereof: and the patient in spirit is better than the proud in spirit.',
      reference: 'Ecclesiastes 7:8',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you rushing to finish something today that would go better with more patience and less ego?',
    ),
    Verse(
      text:
          'And the LORD shall guide thee continually, and satisfy thy soul in drought, and make fat thy bones: and thou shalt be like a watered garden, and like a spring of water, whose waters fail not.',
      reference: 'Isaiah 58:11',
      translation: 'King James Version',
      reflectionPrompt:
          'Where do you feel dry right now that you haven\'t actually asked to be watered?',
    ),
    Verse(
      text:
          'Then said Jesus, Father, forgive them; for they know not what they do. And they parted his raiment, and cast lots.',
      reference: 'Luke 23:34',
      translation: 'King James Version',
      reflectionPrompt:
          'Who hurt you without fully realizing what they were doing, and could you actually pray that prayer for them?',
    ),
    Verse(
      text:
          'As soon as Jesus heard the word that was spoken, he saith unto the ruler of the synagogue, Be not afraid, only believe.',
      reference: 'Mark 5:36',
      translation: 'King James Version',
      reflectionPrompt:
          'What news or fear today is tempting you to stop believing before you even see what happens?',
    ),
    Verse(
      text:
          'Blessed be God, even the Father of our Lord Jesus Christ, the Father of mercies, and the God of all comfort; Who comforteth us in all our tribulation, that we may be able to comfort them which are in any trouble, by the comfort wherewith we ourselves are comforted of God.',
      reference: '2 Corinthians 1:3-4',
      translation: 'King James Version',
      reflectionPrompt:
          'What comfort have you received in a hard season that you could actually pass on to someone else today?',
    ),
    Verse(
      text:
          'For the Son of man is come to seek and to save that which was lost.',
      reference: 'Luke 19:10',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there a part of you that still feels like it\'s the one being sought after, rather than already found?',
    ),
    Verse(
      text:
          'And this is the confidence that we have in him, that, if we ask any thing according to his will, he heareth us:',
      reference: '1 John 5:14',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you praying for today that you haven\'t actually stopped to ask is aligned with what God wants?',
    ),
    Verse(
      text:
          'But without faith it is impossible to please him: for he that cometh to God must believe that he is, and that he is a rewarder of them that diligently seek him.',
      reference: 'Hebrews 11:6',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you seeking God today because you believe he rewards those who do, or have you stopped expecting anything back?',
    ),
    Verse(
      text:
          'And let the peace of God rule in your hearts, to the which also ye are called in one body; and be ye thankful.',
      reference: 'Colossians 3:15',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s actually ruling your heart today -- peace, or something anxious and loud?',
    ),
    Verse(
      text:
          'Therefore being justified by faith, we have peace with God through our Lord Jesus Christ:',
      reference: 'Romans 5:1',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you living today like someone at peace with God, or still trying to earn a peace you already have?',
    ),
    Verse(
      text: 'Fear ye not therefore, ye are of more value than many sparrows.',
      reference: 'Matthew 10:31',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s making you feel small or forgettable today that this verse says just isn\'t true?',
    ),
    Verse(
      text:
          'And I say unto you, Ask, and it shall be given you; seek, and ye shall find; knock, and it shall be opened unto you.',
      reference: 'Luke 11:9',
      translation: 'King James Version',
      reflectionPrompt:
          'Have you asked for something once and given up instead of asking again?',
    ),
    Verse(
      text:
          'For Ezra had prepared his heart to seek the law of the LORD, and to do it, and to teach in Israel statutes and judgments.',
      reference: 'Ezra 7:10',
      translation: 'King James Version',
      reflectionPrompt:
          'What have you been meaning to actually practice, not just learn about?',
    ),
    Verse(
      text:
          'Looking unto Jesus the author and finisher of our faith; who for the joy that was set before him endured the cross, despising the shame, and is set down at the right hand of the throne of God.',
      reference: 'Hebrews 12:2',
      translation: 'King James Version',
      reflectionPrompt:
          'Would what you\'re enduring today be easier if you kept your eyes on what\'s ahead instead of the pain itself?',
    ),
    Verse(
      text:
          'Come now, and let us reason together, saith the LORD: though your sins be as scarlet, they shall be as white as snow; though they be red like crimson, they shall be as wool.',
      reference: 'Isaiah 1:18',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there a stain you\'re convinced is too set in to actually be made clean?',
    ),
    Verse(
      text:
          'But let judgment run down as waters, and righteousness as a mighty stream.',
      reference: 'Amos 5:24',
      translation: 'King James Version',
      reflectionPrompt:
          'Where is injustice something you\'ve gotten used to instead of something you actively work against?',
    ),
    Verse(
      text:
          'But the LORD said unto Samuel, Look not on his countenance, or on the height of his stature; because I have refused him: for the LORD seeth not as man seeth; for man looketh on the outward appearance, but the LORD looketh on the heart.',
      reference: '1 Samuel 16:7',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you polishing on the outside today that you\'re neglecting on the inside?',
    ),
    Verse(
      text:
          'Blessed be the God and Father of our Lord Jesus Christ, which according to his abundant mercy hath begotten us again unto a lively hope by the resurrection of Jesus Christ from the dead,',
      reference: '1 Peter 1:3',
      translation: 'King James Version',
      reflectionPrompt:
          'What hope in your life traces back to something you didn\'t earn but were simply given?',
    ),
    Verse(
      text:
          'God is not a man, that he should lie; neither the son of man, that he should repent: hath he said, and shall he not do it? or hath he spoken, and shall he not make it good?',
      reference: 'Numbers 23:19',
      translation: 'King James Version',
      reflectionPrompt:
          'Which promise of God are you quietly treating like it might not hold?',
    ),
    Verse(
      text:
          'The grass withereth, the flower fadeth: but the word of our God shall stand for ever.',
      reference: 'Isaiah 40:8',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you building your confidence on today that\'s actually as temporary as grass?',
    ),
    Verse(
      text:
          'And all these blessings shall come on thee, and overtake thee, if thou shalt hearken unto the voice of the LORD thy God.',
      reference: 'Deuteronomy 28:2',
      translation: 'King James Version',
      reflectionPrompt:
          'Where have you stopped expecting good to catch up with you?',
    ),
    Verse(
      text: 'Blessed are they that mourn: for they shall be comforted.',
      reference: 'Matthew 5:4',
      translation: 'King James Version',
      reflectionPrompt:
          'What grief are you carrying that you haven\'t let yourself fully feel, let alone be comforted in?',
    ),
    Verse(
      text:
          'Let no man despise thy youth; but be thou an example of the believers, in word, in conversation, in charity, in spirit, in faith, in purity.',
      reference: '1 Timothy 4:12',
      translation: 'King James Version',
      reflectionPrompt:
          'Where do you discount your own influence because of your age or experience, when your example could still matter?',
    ),
    Verse(
      text:
          'And now, Israel, what doth the LORD thy God require of thee, but to fear the LORD thy God, to walk in all his ways, and to love him, and to serve the LORD thy God with all thy heart and with all thy soul,',
      reference: 'Deuteronomy 10:12',
      translation: 'King James Version',
      reflectionPrompt:
          'If someone asked what God actually requires of you, would your life today match your answer?',
    ),
    Verse(
      text:
          'Thou shalt not avenge, nor bear any grudge against the children of thy people, but thou shalt love thy neighbour as thyself: I am the LORD.',
      reference: 'Leviticus 19:18',
      translation: 'King James Version',
      reflectionPrompt:
          'Whose name still stings a little when you think of them -- and what would it cost to let that go?',
    ),
    Verse(
      text:
          'Wait on the LORD: be of good courage, and he shall strengthen thine heart: wait, I say, on the LORD.',
      reference: 'Psalm 27:14',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you tempted to force something today instead of waiting for it to unfold?',
    ),
    Verse(
      text:
          'Be sober, be vigilant; because your adversary the devil, as a roaring lion, walketh about, seeking whom he may devour:',
      reference: '1 Peter 5:8',
      translation: 'King James Version',
      reflectionPrompt:
          'Where have you let your guard down lately in a way that\'s left you more vulnerable than you realized?',
    ),
    Verse(
      text: 'Let all your things be done with charity.',
      reference: '1 Corinthians 16:14',
      translation: 'King James Version',
      reflectionPrompt:
          'Could a task on your list today change completely if you did it out of love instead of obligation?',
    ),
    Verse(
      text:
          'As far as the east is from the west, so far hath he removed our transgressions from us.',
      reference: 'Psalm 103:12',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there an old failure you\'re still carrying around that\'s actually already been put that far away?',
    ),
    Verse(
      text:
          'And I will make of thee a great nation, and I will bless thee, and make thy name great; and thou shalt be a blessing: And I will bless them that bless thee, and curse him that curseth thee: and in thee shall all families of the earth be blessed.',
      reference: 'Genesis 12:2-3',
      translation: 'King James Version',
      reflectionPrompt:
          'How is the blessing in your life meant to reach someone else today instead of stopping with you?',
    ),
    Verse(
      text:
          'Submit yourselves therefore to God. Resist the devil, and he will flee from you.',
      reference: 'James 4:7',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you fighting today with your own willpower that actually needs surrender first?',
    ),
    Verse(
      text:
          'Thy word have I hid in mine heart, that I might not sin against thee.',
      reference: 'Psalm 119:11',
      translation: 'King James Version',
      reflectionPrompt:
          'Do you have anything memorized well enough to reach for the moment temptation shows up?',
    ),
    Verse(
      text:
          'Then he answered and spake unto me, saying, This is the word of the LORD unto Zerubbabel, saying, Not by might, nor by power, but by my spirit, saith the LORD of hosts.',
      reference: 'Zechariah 4:6',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you trying to force through sheer effort today that might need surrender instead?',
    ),
    Verse(
      text:
          'But sanctify the Lord God in your hearts: and be ready always to give an answer to every man that asketh you a reason of the hope that is in you with meekness and fear:',
      reference: '1 Peter 3:15',
      translation: 'King James Version',
      reflectionPrompt:
          'If someone asked you today why you have hope, could you actually explain it -- gently, not defensively?',
    ),
    Verse(
      text:
          'Repent ye therefore, and be converted, that your sins may be blotted out, when the times of refreshing shall come from the presence of the Lord;',
      reference: 'Acts 3:19',
      translation: 'King James Version',
      reflectionPrompt:
          'Would today look different if you actually turned away from something instead of just feeling bad about it?',
    ),
    Verse(
      text:
          'My brethren, count it all joy when ye fall into divers temptations; Knowing this, that the trying of your faith worketh patience.',
      reference: 'James 1:2-3',
      translation: 'King James Version',
      reflectionPrompt:
          'What trial are you in right now that you\'re enduring instead of actually letting shape you?',
    ),
    Verse(
      text:
          'For the eyes of the LORD run to and fro throughout the whole earth, to shew himself strong in the behalf of them whose heart is perfect toward him. Herein thou hast done foolishly: therefore from henceforth thou shalt have wars.',
      reference: '2 Chronicles 16:9',
      translation: 'King James Version',
      reflectionPrompt:
          'Is your heart wholly toward God today, or divided between him and something else?',
    ),
    Verse(
      text:
          'The liberal soul shall be made fat: and he that watereth shall be watered also himself.',
      reference: 'Proverbs 11:25',
      translation: 'King James Version',
      reflectionPrompt:
          'Who could you pour into today, trusting that generosity doesn\'t actually leave you empty?',
    ),
    Verse(
      text:
          'Let us therefore come boldly unto the throne of grace, that we may obtain mercy, and find grace to help in time of need.',
      reference: 'Hebrews 4:16',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there something you need right now that you\'ve been too ashamed to actually ask God for boldly?',
    ),
    Verse(
      text:
          'I know that thou canst do every thing, and that no thought can be withholden from thee.',
      reference: 'Job 42:2',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you still trying to accomplish alone something you actually believe only God can do?',
    ),
    Verse(
      text:
          'But unto you that fear my name shall the Sun of righteousness arise with healing in his wings; and ye shall go forth, and grow up as calves of the stall.',
      reference: 'Malachi 4:2',
      translation: 'King James Version',
      reflectionPrompt:
          'Where do you need healing today that you\'ve stopped actively hoping for?',
    ),
    Verse(
      text:
          'And as ye would that men should do to you, do ye also to them likewise.',
      reference: 'Luke 6:31',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s one small kindness you\'d want done for you today that you could just go ahead and do for someone else first?',
    ),
    Verse(
      text:
          'Therefore all things whatsoever ye would that men should do to you, do ye even so to them: for this is the law and the prophets.',
      reference: 'Matthew 7:12',
      translation: 'King James Version',
      reflectionPrompt:
          'How would you want to be treated in the next interaction you\'re dreading today, and are you willing to lead with that?',
    ),
    Verse(
      text:
          'For thou, Lord, art good, and ready to forgive; and plenteous in mercy unto all them that call upon thee.',
      reference: 'Psalm 86:5',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you still asking forgiveness for as if God might say no this time?',
    ),
    Verse(
      text:
          'For I reckon that the sufferings of this present time are not worthy to be compared with the glory which shall be revealed in us.',
      reference: 'Romans 8:18',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you measuring some current suffering as too big instead of temporary?',
    ),
    Verse(
      text:
          'In those days there was no king in Israel: every man did that which was right in his own eyes.',
      reference: 'Judges 21:25',
      translation: 'King James Version',
      reflectionPrompt:
          'Where have you quietly made yourself the only authority on what\'s right?',
    ),
    Verse(
      text:
          'But he was wounded for our transgressions, he was bruised for our iniquities: the chastisement of our peace was upon him; and with his stripes we are healed.',
      reference: 'Isaiah 53:5',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there a wound you\'re still nursing that you haven\'t actually brought to the one who was wounded for you?',
    ),
    Verse(
      text:
          'For they all made us afraid, saying, Their hands shall be weakened from the work, that it be not done. Now therefore, O God, strengthen my hands.',
      reference: 'Nehemiah 6:9',
      translation: 'King James Version',
      reflectionPrompt:
          'What discouragement is trying to weaken your hands today, and what\'s your version of asking God to strengthen them?',
    ),
    Verse(
      text:
          'And even to your old age I am he; and even to hoar hairs will I carry you: I have made, and I will bear; even I will carry, and will deliver you.',
      reference: 'Isaiah 46:4',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you afraid will happen when you\'re older or weaker that this promise says you don\'t have to fear?',
    ),
    Verse(
      text:
          'And he said unto me, My grace is sufficient for thee: for my strength is made perfect in weakness. Most gladly therefore will I rather glory in my infirmities, that the power of Christ may rest upon me.',
      reference: '2 Corinthians 12:9',
      translation: 'King James Version',
      reflectionPrompt:
          'What weakness are you hiding today that might actually be the place God wants to show up strongest?',
    ),
    Verse(
      text: 'In the beginning God created the heaven and the earth.',
      reference: 'Genesis 1:1',
      translation: 'King James Version',
      reflectionPrompt:
          'Where in your world today are you treating things as random instead of made on purpose?',
    ),
    Verse(
      text:
          'Jesus said unto him, Thou shalt love the Lord thy God with all thy heart, and with all thy soul, and with all thy mind.',
      reference: 'Matthew 22:37',
      translation: 'King James Version',
      reflectionPrompt:
          'Is your mind actually engaged in loving God today, or just going through the motions?',
    ),
    Verse(
      text:
          'There is therefore now no condemnation to them which are in Christ Jesus, who walk not after the flesh, but after the Spirit.',
      reference: 'Romans 8:1',
      translation: 'King James Version',
      reflectionPrompt:
          'What old guilt are you still sentencing yourself for that\'s actually already been dismissed?',
    ),
    Verse(
      text:
          'But ye shall receive power, after that the Holy Ghost is come upon you: and ye shall be witnesses unto me both in Jerusalem, and in all Judaea, and in Samaria, and unto the uttermost part of the earth.',
      reference: 'Acts 1:8',
      translation: 'King James Version',
      reflectionPrompt:
          'Where\'s the nearest starting point in your own life today, the place closest to home you\'ve been avoiding being a witness in?',
    ),
    Verse(
      text:
          'For the LORD God is a sun and shield: the LORD will give grace and glory: no good thing will he withhold from them that walk uprightly.',
      reference: 'Psalm 84:11',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you assuming some good thing is being withheld from you that you haven\'t actually asked about?',
    ),
    Verse(
      text:
          'For I am persuaded, that neither death, nor life, nor angels, nor principalities, nor powers, nor things present, nor things to come, Nor height, nor depth, nor any other creature, shall be able to separate us from the love of God, which is in Christ Jesus our Lord.',
      reference: 'Romans 8:38-39',
      translation: 'King James Version',
      reflectionPrompt:
          'What have you quietly assumed might be enough to make God stop loving you?',
    ),
    Verse(
      text:
          'Draw nigh to God, and he will draw nigh to you. Cleanse your hands, ye sinners; and purify your hearts, ye double minded.',
      reference: 'James 4:8',
      translation: 'King James Version',
      reflectionPrompt:
          'Has something kept you at arm\'s length from God this week that a single step closer could change?',
    ),
    Verse(
      text:
          'For I know that my redeemer liveth, and that he shall stand at the latter day upon the earth:',
      reference: 'Job 19:25',
      translation: 'King James Version',
      reflectionPrompt:
          'Amid everything uncertain today, is there one thing you actually do know for sure?',
    ),
    Verse(
      text:
          'All scripture is given by inspiration of God, and is profitable for doctrine, for reproof, for correction, for instruction in righteousness: That the man of God may be perfect, throughly furnished unto all good works.',
      reference: '2 Timothy 3:16-17',
      translation: 'King James Version',
      reflectionPrompt:
          'What correction have you been avoiding that scripture\'s already been trying to give you?',
    ),
    Verse(
      text:
          'Every good gift and every perfect gift is from above, and cometh down from the Father of lights, with whom is no variableness, neither shadow of turning.',
      reference: 'James 1:17',
      translation: 'King James Version',
      reflectionPrompt:
          'What good thing in your life have you stopped tracing back to where it actually came from?',
    ),
    Verse(
      text:
          'But as many as received him, to them gave he power to become the sons of God, even to them that believe on his name:',
      reference: 'John 1:12',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you living today out of the identity you\'ve been given, or out of an old one you haven\'t let go?',
    ),
    Verse(
      text:
          'The LORD recompense thy work, and a full reward be given thee of the LORD God of Israel, under whose wings thou art come to trust.',
      reference: 'Ruth 2:12',
      translation: 'King James Version',
      reflectionPrompt:
          'Do you assume some quiet faithfulness of yours has gone unnoticed, even by God?',
    ),
    Verse(
      text:
          'If any of you lack wisdom, let him ask of God, that giveth to all men liberally, and upbraideth not; and it shall be given him.',
      reference: 'James 1:5',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you stuck on a decision today that you haven\'t actually just asked God to help you see clearly?',
    ),
    Verse(
      text:
          'For we have great joy and consolation in thy love, because the bowels of the saints are refreshed by thee, brother.',
      reference: 'Philemon 1:7',
      translation: 'King James Version',
      reflectionPrompt:
          'Who have you actually refreshed lately just by how you loved them?',
    ),
    Verse(
      text:
          'And the LORD God said, It is not good that the man should be alone; I will make him an help meet for him.',
      reference: 'Genesis 2:18',
      translation: 'King James Version',
      reflectionPrompt:
          'Who has God placed near you that you\'ve been trying to do life without?',
    ),
    Verse(
      text:
          'Now when Daniel knew that the writing was signed, he went into his house; and his windows being open in his chamber toward Jerusalem, he kneeled upon his knees three times a day, and prayed, and gave thanks before his God, as he did aforetime.',
      reference: 'Daniel 6:10',
      translation: 'King James Version',
      reflectionPrompt:
          'Would your prayer life survive if it suddenly became risky or inconvenient to keep it up?',
    ),
    Verse(
      text:
          'I waited patiently for the LORD; and he inclined unto me, and heard my cry. He brought me up also out of an horrible pit, out of the miry clay, and set my feet upon a rock, and established my goings.',
      reference: 'Psalm 40:1-2',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there a pit you\'re waiting to be pulled out of, and are you still waiting patiently or have you given up?',
    ),
    Verse(
      text: 'For all have sinned, and come short of the glory of God;',
      reference: 'Romans 3:23',
      translation: 'King James Version',
      reflectionPrompt:
          'Who have you been judging today as if you didn\'t need the same grace they do?',
    ),
    Verse(
      text:
          'And this is love, that we walk after his commandments. This is the commandment, That, as ye have heard from the beginning, ye should walk in it.',
      reference: '2 John 1:6',
      translation: 'King James Version',
      reflectionPrompt:
          'Where do you say you love God but your actual daily choices tell a different story?',
    ),
    Verse(
      text:
          'For his anger endureth but a moment; in his favour is life: weeping may endure for a night, but joy cometh in the morning.',
      reference: 'Psalm 30:5',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you in a night right now that you haven\'t let yourself believe has a morning coming?',
    ),
    Verse(
      text:
          'He that walketh with wise men shall be wise: but a companion of fools shall be destroyed.',
      reference: 'Proverbs 13:20',
      translation: 'King James Version',
      reflectionPrompt:
          'Are the people you spend the most time with actually making you wiser or just more comfortable?',
    ),
    Verse(
      text:
          'And thou shalt love the LORD thy God with all thine heart, and with all thy soul, and with all thy might.',
      reference: 'Deuteronomy 6:5',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you giving all of yourself to loving God today, or just whatever\'s left after everything else competing for it?',
    ),
    Verse(
      text:
          'Study to shew thyself approved unto God, a workman that needeth not to be ashamed, rightly dividing the word of truth.',
      reference: '2 Timothy 2:15',
      translation: 'King James Version',
      reflectionPrompt:
          'Where are you relying on secondhand opinions about truth instead of studying it for yourself?',
    ),
    Verse(
      text:
          'Behold, his soul which is lifted up is not upright in him: but the just shall live by his faith.',
      reference: 'Habakkuk 2:4',
      translation: 'King James Version',
      reflectionPrompt:
          'Is the way you\'re living today actually built on faith, or on what you can already see working out?',
    ),
    Verse(
      text:
          'Where there is no vision, the people perish: but he that keepeth the law, happy is he.',
      reference: 'Proverbs 29:18',
      translation: 'King James Version',
      reflectionPrompt:
          'Has your vision for your life gone slack, and what\'s quietly filled the gap instead?',
    ),
    Verse(
      text:
          'For unto us a child is born, unto us a son is given: and the government shall be upon his shoulder: and his name shall be called Wonderful, Counsellor, The mighty God, The everlasting Father, The Prince of Peace.',
      reference: 'Isaiah 9:6',
      translation: 'King James Version',
      reflectionPrompt:
          'Which of these names for God -- Counsellor, Prince of Peace -- do you most need to lean on today?',
    ),
    Verse(
      text:
          'I have shewed you all things, how that so labouring ye ought to support the weak, and to remember the words of the Lord Jesus, how he said, It is more blessed to give than to receive.',
      reference: 'Acts 20:35',
      translation: 'King James Version',
      reflectionPrompt:
          'What could you give away today -- time, attention, money -- expecting nothing back?',
    ),
    Verse(
      text:
          'Beloved, I wish above all things that thou mayest prosper and be in health, even as thy soul prospereth.',
      reference: '3 John 1:2',
      translation: 'King James Version',
      reflectionPrompt:
          'Who could you genuinely wish, and pray, good health and flourishing over today, beyond a passing thought?',
    ),
    Verse(
      text:
          'But I say unto you, Love your enemies, bless them that curse you, do good to them that hate you, and pray for them which despitefully use you, and persecute you;',
      reference: 'Matthew 5:44',
      translation: 'King James Version',
      reflectionPrompt:
          'Who\'s easiest for you to write off today that you\'re actually being asked to pray for instead?',
    ),
    Verse(
      text:
          'Thine, O LORD, is the greatness, and the power, and the glory, and the victory, and the majesty: for all that is in the heaven and in the earth is thine; thine is the kingdom, O LORD, and thou art exalted as head above all.',
      reference: '1 Chronicles 29:11',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you trying to control today that actually already belongs to someone bigger than you?',
    ),
    Verse(
      text:
          'And let us consider one another to provoke unto love and to good works:',
      reference: 'Hebrews 10:24',
      translation: 'King James Version',
      reflectionPrompt:
          'Who could you actually challenge toward something better today instead of just leaving them be?',
    ),
    Verse(
      text:
          'The Lord is not slack concerning his promise, as some men count slackness; but is longsuffering to us-ward, not willing that any should perish, but that all should come to repentance.',
      reference: '2 Peter 3:9',
      translation: 'King James Version',
      reflectionPrompt:
          'Who are you tired of waiting on God to change, when he might just be patiently giving them more time?',
    ),
    Verse(
      text:
          'Teaching them to observe all things whatsoever I have commanded you: and, lo, I am with you alway, even unto the end of the world. Amen.',
      reference: 'Matthew 28:20',
      translation: 'King James Version',
      reflectionPrompt:
          'Does what you\'re facing today feel like it\'s testing whether always really means always?',
    ),
    Verse(
      text:
          'Behold, I stand at the door, and knock: if any man hear my voice, and open the door, I will come in to him, and will sup with him, and he with me.',
      reference: 'Revelation 3:20',
      translation: 'King James Version',
      reflectionPrompt:
          'Where is God knocking in your life right now that you haven\'t actually opened the door to?',
    ),
    Verse(
      text:
          'When thou passest through the waters, I will be with thee; and through the rivers, they shall not overflow thee: when thou walkest through the fire, thou shalt not be burned; neither shall the flame kindle upon thee.',
      reference: 'Isaiah 43:2',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s the fire or flood you\'re currently walking through, and where have you stopped expecting to come out the other side?',
    ),
    Verse(
      text:
          'When I consider thy heavens, the work of thy fingers, the moon and the stars, which thou hast ordained; What is man, that thou art mindful of him? and the son of man, that thou visitest him?',
      reference: 'Psalm 8:3-4',
      translation: 'King James Version',
      reflectionPrompt:
          'Does the size of the world make you feel forgotten, or does it ever make you feel specifically known?',
    ),
    Verse(
      text:
          'And be ye kind one to another, tenderhearted, forgiving one another, even as God for Christ\'s sake hath forgiven you.',
      reference: 'Ephesians 4:32',
      translation: 'King James Version',
      reflectionPrompt:
          'Who are you withholding forgiveness from at a standard stricter than the one you\'ve been forgiven by?',
    ),
    Verse(
      text:
          'For my thoughts are not your thoughts, neither are your ways my ways, saith the LORD. For as the heavens are higher than the earth, so are my ways higher than your ways, and my thoughts than your thoughts.',
      reference: 'Isaiah 55:8-9',
      translation: 'King James Version',
      reflectionPrompt:
          'Where are you demanding God\'s plan make sense to you before you\'ll trust it?',
    ),
    Verse(
      text:
          'The LORD is nigh unto all them that call upon him, to all that call upon him in truth.',
      reference: 'Psalm 145:18',
      translation: 'King James Version',
      reflectionPrompt:
          'Are the prayers you\'re praying today honest, or are you performing them?',
    ),
    Verse(
      text:
          'I have fought a good fight, I have finished my course, I have kept the faith:',
      reference: '2 Timothy 4:7',
      translation: 'King James Version',
      reflectionPrompt:
          'If today were near the end, would you be able to say you kept the faith, or that you quit somewhere along the way?',
    ),
    Verse(
      text: '(For we walk by faith, not by sight:)',
      reference: '2 Corinthians 5:7',
      translation: 'King James Version',
      reflectionPrompt:
          'What decision today requires you to move before you can actually see the outcome?',
    ),
    Verse(
      text:
          'Strength and honour are her clothing; and she shall rejoice in time to come.',
      reference: 'Proverbs 31:25',
      translation: 'King James Version',
      reflectionPrompt:
          'Do you actually believe good things are still ahead of you, or are you bracing for the worst by default?',
    ),
    Verse(
      text:
          'He hath shewed thee, O man, what is good; and what doth the LORD require of thee, but to do justly, and to love mercy, and to walk humbly with thy God?',
      reference: 'Micah 6:8',
      translation: 'King James Version',
      reflectionPrompt:
          'Which of the three -- justice, mercy, humility -- are you currently weakest in living out?',
    ),
    Verse(
      text:
          'Jesus said unto her, I am the resurrection, and the life: he that believeth in me, though he were dead, yet shall he live:',
      reference: 'John 11:25',
      translation: 'King James Version',
      reflectionPrompt:
          'What feels dead in your life right now that you haven\'t let yourself hope could still live?',
    ),
    Verse(
      text:
          'Finally, my brethren, be strong in the Lord, and in the power of his might.',
      reference: 'Ephesians 6:10',
      translation: 'King James Version',
      reflectionPrompt:
          'Where are you running on your own strength today when you could actually be drawing on his?',
    ),
    Verse(
      text:
          'And ye shall seek me, and find me, when ye shall search for me with all your heart.',
      reference: 'Jeremiah 29:13',
      translation: 'King James Version',
      reflectionPrompt: 'Is your search for God halfhearted or all in today?',
    ),
    Verse(
      text:
          'Then shall we know, if we follow on to know the LORD: his going forth is prepared as the morning; and he shall come unto us as the rain, as the latter and former rain unto the earth.',
      reference: 'Hosea 6:3',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you still pursuing a deeper knowing of God, or did you stop growing somewhere back down the road?',
    ),
    Verse(
      text:
          'My sheep hear my voice, and I know them, and they follow me: And I give unto them eternal life; and they shall never perish, neither shall any man pluck them out of my hand.',
      reference: 'John 10:27-28',
      translation: 'King James Version',
      reflectionPrompt:
          'How well do you actually know the sound of God\'s voice compared to all the others competing for your attention?',
    ),
    Verse(
      text:
          'As for God, his way is perfect; the word of the LORD is tried: he is a buckler to all them that trust in him.',
      reference: '2 Samuel 22:31',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s one way God\'s word has already proven true in your life that you keep forgetting to lean on?',
    ),
    Verse(
      text:
          'And he that sat upon the throne said, Behold, I make all things new. And he said unto me, Write: for these words are true and faithful.',
      reference: 'Revelation 21:5',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there something in your life that feels too far gone to be made new -- and what if that\'s exactly where he wants to start?',
    ),
    Verse(
      text:
          'Create in me a clean heart, O God; and renew a right spirit within me.',
      reference: 'Psalm 51:10',
      translation: 'King James Version',
      reflectionPrompt:
          'What part of your heart needs less patching up and more actually being made new?',
    ),
    Verse(
      text:
          'Confess your faults one to another, and pray one for another, that ye may be healed. The effectual fervent prayer of a righteous man availeth much.',
      reference: 'James 5:16',
      translation: 'King James Version',
      reflectionPrompt:
          'Who do you trust enough to actually confess a struggle to instead of carrying it alone?',
    ),
    Verse(
      text:
          'Which hope we have as an anchor of the soul, both sure and stedfast, and which entereth into that within the veil;',
      reference: 'Hebrews 6:19',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s anchoring you today when things feel unsteady, and is it actually strong enough to hold?',
    ),
    Verse(
      text:
          'Then saith he unto his disciples, The harvest truly is plenteous, but the labourers are few;',
      reference: 'Matthew 9:37',
      translation: 'King James Version',
      reflectionPrompt:
          'Where do you see a need today that you\'ve been waiting for someone else to step up and meet?',
    ),
    Verse(
      text:
          'Let nothing be done through strife or vainglory; but in lowliness of mind let each esteem other better than themselves. Look not every man on his own things, but every man also on the things of others.',
      reference: 'Philippians 2:3-4',
      translation: 'King James Version',
      reflectionPrompt:
          'Whose needs have you not really looked at today because you were too focused on your own?',
    ),
    Verse(
      text:
          'I am crucified with Christ: nevertheless I live; yet not I, but Christ liveth in me: and the life which I now live in the flesh I live by the faith of the Son of God, who loved me, and gave himself for me.',
      reference: 'Galatians 2:20',
      translation: 'King James Version',
      reflectionPrompt:
          'Whose life are you actually living out today -- the old one, or the one he\'s living through you now?',
    ),
    Verse(
      text:
          'His lord said unto him, Well done, thou good and faithful servant: thou hast been faithful over a few things, I will make thee ruler over many things: enter thou into the joy of thy lord.',
      reference: 'Matthew 25:21',
      translation: 'King James Version',
      reflectionPrompt:
          'What small, unnoticed responsibility today is actually the faithfulness that matters most?',
    ),
    Verse(
      text:
          'Remember ye not the former things, neither consider the things of old. Behold, I will do a new thing; now it shall spring forth; shall ye not know it? I will even make a way in the wilderness, and rivers in the desert.',
      reference: 'Isaiah 43:18-19',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there an old story about yourself you\'re still rehearsing instead of watching for what\'s new?',
    ),
    Verse(
      text:
          'But Jesus beheld them, and said unto them, With men this is impossible; but with God all things are possible.',
      reference: 'Matthew 19:26',
      translation: 'King James Version',
      reflectionPrompt:
          'Have you already decided something is impossible without actually bringing it to God?',
    ),
    Verse(
      text:
          'For God hath not given us the spirit of fear; but of power, and of love, and of a sound mind.',
      reference: '2 Timothy 1:7',
      translation: 'King James Version',
      reflectionPrompt:
          'Which of these -- power, love, a sound mind -- feels furthest from you right now, and what\'s crowding it out?',
    ),
    Verse(
      text:
          'Not by works of righteousness which we have done, but according to his mercy he saved us, by the washing of regeneration, and renewing of the Holy Ghost;',
      reference: 'Titus 3:5',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you still trying to earn something today that was actually already given to you by mercy?',
    ),
    Verse(
      text:
          'In the multitude of my thoughts within me thy comforts delight my soul.',
      reference: 'Psalm 94:19',
      translation: 'King James Version',
      reflectionPrompt:
          'Which racing thought tonight needs to be met with comfort instead of just more worrying?',
    ),
    Verse(
      text:
          'And God is able to make all grace abound toward you; that ye, always having all sufficiency in all things, may abound to every good work:',
      reference: '2 Corinthians 9:8',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you putting off some good work because you don\'t feel like you have enough for it yet?',
    ),
    Verse(
      text:
          'And I will restore to you the years that the locust hath eaten, the cankerworm, and the caterpiller, and the palmerworm, my great army which I sent among you.',
      reference: 'Joel 2:25',
      translation: 'King James Version',
      reflectionPrompt:
          'Are there years or seasons you feel were wasted that you\'re ready to let God restore instead of just mourn?',
    ),
    Verse(
      text:
          'And whatsoever ye do, do it heartily, as to the Lord, and not unto men;',
      reference: 'Colossians 3:23',
      translation: 'King James Version',
      reflectionPrompt:
          'Would you do a task today differently if you did it as if God himself were the one you were serving?',
    ),
    Verse(
      text:
          'Being confident of this very thing, that he which hath begun a good work in you will perform it until the day of Jesus Christ:',
      reference: 'Philippians 1:6',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you tempted to give up on an unfinished work in you that God hasn\'t given up on?',
    ),
    Verse(
      text:
          'I will both lay me down in peace, and sleep: for thou, LORD, only makest me dwell in safety.',
      reference: 'Psalm 4:8',
      translation: 'King James Version',
      reflectionPrompt:
          'Has something kept you awake lately that you haven\'t actually handed over before trying to sleep?',
    ),
    Verse(
      text: 'Be not overcome of evil, but overcome evil with good.',
      reference: 'Romans 12:21',
      translation: 'King James Version',
      reflectionPrompt:
          'Where has someone\'s wrong toward you been shaping your response more than your own values have?',
    ),
    Verse(
      text:
          'Cast thy burden upon the LORD, and he shall sustain thee: he shall never suffer the righteous to be moved.',
      reference: 'Psalm 55:22',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there a burden you keep picking back up right after you\'ve prayed about it?',
    ),
    Verse(
      text:
          'A friend loveth at all times, and a brother is born for adversity.',
      reference: 'Proverbs 17:17',
      translation: 'King James Version',
      reflectionPrompt:
          'Who has shown up for you in a hard season that you haven\'t properly thanked?',
    ),
    Verse(
      text:
          'Praise ye the LORD. Blessed is the man that feareth the LORD, that delighteth greatly in his commandments.',
      reference: 'Psalm 112:1',
      translation: 'King James Version',
      reflectionPrompt:
          'Does following God feel like duty to you right now, or has any of it become delight?',
    ),
    Verse(
      text:
          'But God commendeth his love toward us, in that, while we were yet sinners, Christ died for us.',
      reference: 'Romans 5:8',
      translation: 'King James Version',
      reflectionPrompt:
          'Who could you love today before they\'ve earned it, the way you were loved first?',
    ),
    Verse(
      text:
          'And God said unto Moses, I AM THAT I AM: and he said, Thus shalt thou say unto the children of Israel, I AM hath sent me unto you.',
      reference: 'Exodus 3:14',
      translation: 'King James Version',
      reflectionPrompt:
          'Do you need God to simply be for you today, rather than explain?',
    ),
    Verse(
      text:
          'What shall we then say to these things? If God be for us, who can be against us?',
      reference: 'Romans 8:31',
      translation: 'King James Version',
      reflectionPrompt:
          'Who or what are you letting intimidate you today as if you were facing it without backup?',
    ),
    Verse(
      text:
          'Cast thy bread upon the waters: for thou shalt find it after many days.',
      reference: 'Ecclesiastes 11:1',
      translation: 'King James Version',
      reflectionPrompt:
          'Have you done some good thing that hasn\'t paid off yet -- and are you still willing to trust that it will?',
    ),
    Verse(
      text:
          'And Ruth said, Intreat me not to leave thee, or to return from following after thee: for whither thou goest, I will go; and where thou lodgest, I will lodge: thy people shall be my people, and thy God my God:',
      reference: 'Ruth 1:16',
      translation: 'King James Version',
      reflectionPrompt: 'Who have you committed to only as long as it\'s easy?',
    ),
    Verse(
      text:
          'For where two or three are gathered together in my name, there am I in the midst of them.',
      reference: 'Matthew 18:20',
      translation: 'King James Version',
      reflectionPrompt:
          'Who could you actually gather with today instead of trying to carry this alone?',
    ),
    Verse(
      text:
          'The LORD thy God in the midst of thee is mighty; he will save, he will rejoice over thee with joy; he will rest in his love, he will joy over thee with singing.',
      reference: 'Zephaniah 3:17',
      translation: 'King James Version',
      reflectionPrompt:
          'What would it feel like to actually believe God is singing over you today instead of disappointed in you?',
    ),
    Verse(
      text:
          'And I will give them one heart, and I will put a new spirit within you; and I will take the stony heart out of their flesh, and will give them an heart of flesh:',
      reference: 'Ezekiel 11:19',
      translation: 'King James Version',
      reflectionPrompt:
          'Where has your heart gone hard lately that you\'d rather it stayed soft?',
    ),
    Verse(
      text:
          'Though he slay me, yet will I trust in him: but I will maintain mine own ways before him.',
      reference: 'Job 13:15',
      translation: 'King James Version',
      reflectionPrompt:
          'Would your trust in God survive the worst outcome you\'re currently afraid of?',
    ),
    Verse(
      text:
          'Finally, brethren, whatsoever things are true, whatsoever things are honest, whatsoever things are just, whatsoever things are pure, whatsoever things are lovely, whatsoever things are of good report; if there be any virtue, and if there be any praise, think on these things.',
      reference: 'Philippians 4:8',
      translation: 'King James Version',
      reflectionPrompt:
          'Whatever\'s occupying your thoughts most today, would you actually call it true, pure, or lovely?',
    ),
    Verse(
      text: 'Casting all your care upon him; for he careth for you.',
      reference: '1 Peter 5:7',
      translation: 'King James Version',
      reflectionPrompt:
          'What care are you carrying today as if no one, not even God, actually cares about it?',
    ),
    Verse(
      text:
          'Wherefore seeing we also are compassed about with so great a cloud of witnesses, let us lay aside every weight, and the sin which doth so easily beset us, and let us run with patience the race that is set before us,',
      reference: 'Hebrews 12:1',
      translation: 'King James Version',
      reflectionPrompt:
          'What weight, not even sin, just extra baggage, are you carrying today that\'s slowing your race?',
    ),
    Verse(
      text:
          'Behold, how good and how pleasant it is for brethren to dwell together in unity!',
      reference: 'Psalm 133:1',
      translation: 'King James Version',
      reflectionPrompt:
          'Where is there tension in a relationship today that unity would actually feel better than being right?',
    ),
    Verse(
      text:
          'And he answered, Fear not: for they that be with us are more than they that be with them.',
      reference: '2 Kings 6:16',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s outnumbering you today that might not be as alone against you as it looks?',
    ),
    Verse(
      text:
          'Blessed is the man that trusteth in the LORD, and whose hope the LORD is.',
      reference: 'Jeremiah 17:7',
      translation: 'King James Version',
      reflectionPrompt:
          'Where is your hope actually anchored today, in God, or in something that could let you down?',
    ),
    Verse(
      text:
          'He that followeth after righteousness and mercy findeth life, righteousness, and honour.',
      reference: 'Proverbs 21:21',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you chasing being right today, or chasing what\'s actually righteous and merciful?',
    ),
    Verse(
      text: 'For where your treasure is, there will your heart be also.',
      reference: 'Luke 12:34',
      translation: 'King James Version',
      reflectionPrompt:
          'If someone tracked your time and money this week, what would they conclude you actually treasure?',
    ),
    Verse(
      text:
          'The thief cometh not, but for to steal, and to kill, and to destroy: I am come that they might have life, and that they might have it more abundantly.',
      reference: 'John 10:10',
      translation: 'King James Version',
      reflectionPrompt:
          'Is something quietly stealing life from you right now that you\'ve mistaken for normal?',
    ),
    Verse(
      text: 'Thy word is a lamp unto my feet, and a light unto my path.',
      reference: 'Psalm 119:105',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you trying to see your whole future today when you were only given light for the next step?',
    ),
    Verse(
      text:
          'But whosoever drinketh of the water that I shall give him shall never thirst; but the water that I shall give him shall be in him a well of water springing up into everlasting life.',
      reference: 'John 4:14',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you drinking from today that always leaves you thirsty again?',
    ),
    Verse(
      text:
          'Put on the whole armour of God, that ye may be able to stand against the wiles of the devil.',
      reference: 'Ephesians 6:11',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you walking into today unprepared for spiritually that deserves more than good intentions?',
    ),
    Verse(
      text:
          'And let us not be weary in well doing: for in due season we shall reap, if we faint not.',
      reference: 'Galatians 6:9',
      translation: 'King James Version',
      reflectionPrompt:
          'What good thing are you tempted to quit right before it would have paid off?',
    ),
    Verse(
      text:
          'The LORD is merciful and gracious, slow to anger, and plenteous in mercy.',
      reference: 'Psalm 103:8',
      translation: 'King James Version',
      reflectionPrompt:
          'Where do you need to borrow some of God\'s patience today instead of your own, which is already running out?',
    ),
    Verse(
      text:
          'I have heard of thee by the hearing of the ear: but now mine eye seeth thee.',
      reference: 'Job 42:5',
      translation: 'King James Version',
      reflectionPrompt:
          'Is your faith today something you\'ve heard about, or something you\'ve actually seen for yourself?',
    ),
    Verse(
      text:
          'Jesus saith unto him, Thomas, because thou hast seen me, thou hast believed: blessed are they that have not seen, and yet have believed.',
      reference: 'John 20:29',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you still waiting to see before you\'ll actually believe it\'s true?',
    ),
    Verse(
      text:
          'And all this assembly shall know that the LORD saveth not with sword and spear: for the battle is the LORD\'S, and he will give you into our hands.',
      reference: '1 Samuel 17:47',
      translation: 'King James Version',
      reflectionPrompt:
          'What giant are you facing today that you\'re trying to defeat with your own weapons instead of remembering whose battle it actually is?',
    ),
    Verse(
      text:
          'When my soul fainted within me I remembered the LORD: and my prayer came in unto thee, into thine holy temple.',
      reference: 'Jonah 2:7',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s the moment today when you\'re most likely to forget God until you\'re desperate -- could you remember him sooner?',
    ),
    Verse(
      text:
          'Whatsoever thy hand findeth to do, do it with thy might; for there is no work, nor device, nor knowledge, nor wisdom, in the grave, whither thou goest.',
      reference: 'Ecclesiastes 9:10',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s one thing today you\'ve been doing halfway that deserves your full effort?',
    ),
    Verse(
      text:
          'And the LORD, he it is that doth go before thee; he will be with thee, he will not fail thee, neither forsake thee: fear not, neither be dismayed.',
      reference: 'Deuteronomy 31:8',
      translation: 'King James Version',
      reflectionPrompt:
          'Where do you wish someone had gone ahead of you to check that the road was safe?',
    ),
    Verse(
      text:
          'And after the earthquake a fire; but the LORD was not in the fire: and after the fire a still small voice.',
      reference: '1 Kings 19:12',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you listening for God in the noise today when he might be waiting in the quiet?',
    ),
    Verse(
      text:
          'There is a way which seemeth right unto a man, but the end thereof are the ways of death.',
      reference: 'Proverbs 14:12',
      translation: 'King James Version',
      reflectionPrompt:
          'What choice feels obviously right to you today that you haven\'t actually tested against anything outside your own judgment?',
    ),
    Verse(
      text:
          'For God sent not his Son into the world to condemn the world; but that the world through him might be saved.',
      reference: 'John 3:17',
      translation: 'King James Version',
      reflectionPrompt:
          'Who are you condemning today, including yourself, that grace was actually sent for?',
    ),
    Verse(
      text:
          'Therefore I will look unto the LORD; I will wait for the God of my salvation: my God will hear me.',
      reference: 'Micah 7:7',
      translation: 'King James Version',
      reflectionPrompt:
          'When everything else has let you down lately, where have you actually turned to look?',
    ),
    Verse(
      text:
          'I am Alpha and Omega, the beginning and the end, the first and the last.',
      reference: 'Revelation 22:13',
      translation: 'King James Version',
      reflectionPrompt:
          'Whatever this chapter of your life ends up looking like, do you trust who gets the final word on it?',
    ),
    Verse(
      text:
          'If my people, which are called by my name, shall humble themselves, and pray, and seek my face, and turn from their wicked ways; then will I hear from heaven, and will forgive their sin, and will heal their land.',
      reference: '2 Chronicles 7:14',
      translation: 'King James Version',
      reflectionPrompt:
          'Is pride protecting you today from a cost genuine humility would ask you to pay?',
    ),
    Verse(
      text:
          'Jesus saith unto him, I am the way, the truth, and the life: no man cometh unto the Father, but by me.',
      reference: 'John 14:6',
      translation: 'King James Version',
      reflectionPrompt:
          'Where are you looking for your own way today instead of asking to be shown the way?',
    ),
    Verse(
      text:
          'O taste and see that the LORD is good: blessed is the man that trusteth in him.',
      reference: 'Psalm 34:8',
      translation: 'King James Version',
      reflectionPrompt:
          'Where have you been taking God\'s goodness on secondhand information instead of tasting it yourself?',
    ),
    Verse(
      text:
          'My little children, let us not love in word, neither in tongue; but in deed and in truth.',
      reference: '1 John 3:18',
      translation: 'King James Version',
      reflectionPrompt:
          'Who have you told you love but haven\'t actually shown it to lately in something practical?',
    ),
    Verse(
      text:
          'Brethren, I count not myself to have apprehended: but this one thing I do, forgetting those things which are behind, and reaching forth unto those things which are before, I press toward the mark for the prize of the high calling of God in Christ Jesus.',
      reference: 'Philippians 3:13-14',
      translation: 'King James Version',
      reflectionPrompt:
          'What from your past are you still dragging forward that\'s slowing your reach toward what\'s ahead?',
    ),
    Verse(
      text:
          'Be strong and of a good courage, fear not, nor be afraid of them: for the LORD thy God, he it is that doth go with thee; he will not fail thee, nor forsake thee.',
      reference: 'Deuteronomy 31:6',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you bracing to face today as if you might be abandoned in it?',
    ),
    Verse(
      text:
          'Before I formed thee in the belly I knew thee; and before thou camest forth out of the womb I sanctified thee, and I ordained thee a prophet unto the nations.',
      reference: 'Jeremiah 1:5',
      translation: 'King James Version',
      reflectionPrompt:
          'What purpose do you suspect you were made for that you\'ve been too afraid to actually step into?',
    ),
    Verse(
      text:
          'And the angel said unto them, Fear not: for, behold, I bring you good tidings of great joy, which shall be to all people.',
      reference: 'Luke 2:10',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there a fear in you today that needs to hear some genuinely good news?',
    ),
    Verse(
      text:
          'In the beginning was the Word, and the Word was with God, and the Word was God.',
      reference: 'John 1:1',
      translation: 'King James Version',
      reflectionPrompt:
          'Do you know what foundation you\'re actually building today\'s decisions on?',
    ),
    Verse(
      text:
          'The Spirit of God hath made me, and the breath of the Almighty hath given me life.',
      reference: 'Job 33:4',
      translation: 'King James Version',
      reflectionPrompt:
          'When did you last actually notice that your next breath isn\'t something you\'re owed?',
    ),
    Verse(
      text:
          'Peace I leave with you, my peace I give unto you: not as the world giveth, give I unto you. Let not your heart be troubled, neither let it be afraid.',
      reference: 'John 14:27',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you settling for the world\'s fragile peace today, or the kind that isn\'t shaken?',
    ),
    Verse(
      text:
          'And they continued stedfastly in the apostles\' doctrine and fellowship, and in breaking of bread, and in prayers.',
      reference: 'Acts 2:42',
      translation: 'King James Version',
      reflectionPrompt:
          'Which of these -- learning, community, shared meals, prayer -- has quietly dropped out of your week?',
    ),
    Verse(
      text:
          'If we confess our sins, he is faithful and just to forgive us our sins, and to cleanse us from all unrighteousness.',
      reference: '1 John 1:9',
      translation: 'King James Version',
      reflectionPrompt:
          'What sin are you still hiding today that confession would actually clear rather than more hiding?',
    ),
    Verse(
      text:
          'For even the Son of man came not to be ministered unto, but to minister, and to give his life a ransom for many.',
      reference: 'Mark 10:45',
      translation: 'King James Version',
      reflectionPrompt:
          'Where today could you choose to serve instead of expecting to be served?',
    ),
    Verse(
      text:
          'Favour is deceitful, and beauty is vain: but a woman that feareth the LORD, she shall be praised.',
      reference: 'Proverbs 31:30',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you working hardest to be praised for today that won\'t actually matter in ten years?',
    ),
    Verse(
      text:
          'O give thanks unto the LORD, for he is good: for his mercy endureth for ever.',
      reference: 'Psalm 107:1',
      translation: 'King James Version',
      reflectionPrompt:
          'What\'s one thing today that\'s purely good, with no strings attached, that you haven\'t thanked anyone for?',
    ),
    Verse(
      text:
          'Call unto me, and I will answer thee, and shew thee great and mighty things, which thou knowest not.',
      reference: 'Jeremiah 33:3',
      translation: 'King James Version',
      reflectionPrompt:
          'Have you stopped asking God to show you something because you assumed the answer wouldn\'t come?',
    ),
    Verse(
      text:
          'And thou shalt love the Lord thy God with all thy heart, and with all thy soul, and with all thy mind, and with all thy strength: this is the first commandment. And the second is like, namely this, Thou shalt love thy neighbour as thyself. There is none other commandment greater than these.',
      reference: 'Mark 12:30-31',
      translation: 'King James Version',
      reflectionPrompt:
          'If someone graded today by how well you loved God and your neighbor, what grade would you actually earn?',
    ),
    Verse(
      text:
          'For whatsoever things were written aforetime were written for our learning, that we through patience and comfort of the scriptures might have hope.',
      reference: 'Romans 15:4',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there an old story in scripture you haven\'t gone back to lately for the hope it actually offers you now?',
    ),
    Verse(
      text:
          'I love the LORD, because he hath heard my voice and my supplications. Because he hath inclined his ear unto me, therefore will I call upon him as long as I live.',
      reference: 'Psalm 116:1-2',
      translation: 'King James Version',
      reflectionPrompt:
          'Who in your life loves you more because you actually listened to them, and does God get the same credit from you?',
    ),
    Verse(
      text:
          'While the earth remaineth, seedtime and harvest, and cold and heat, and summer and winter, and day and night shall not cease.',
      reference: 'Genesis 8:22',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there a rhythm in your life right now that feels shaky, one you could actually trust to keep coming back around?',
    ),
    Verse(
      text:
          'And they that be wise shall shine as the brightness of the firmament; and they that turn many to righteousness as the stars for ever and ever.',
      reference: 'Daniel 12:3',
      translation: 'King James Version',
      reflectionPrompt:
          'Who is watching your life closely enough that your integrity could actually change their direction?',
    ),
    Verse(
      text:
          'Train up a child in the way he should go: and when he is old, he will not depart from it.',
      reference: 'Proverbs 22:6',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you actually modeling today for the young people watching you, whether or not you meant to?',
    ),
    Verse(
      text:
          'Now unto him that is able to do exceeding abundantly above all that we ask or think, according to the power that worketh in us,',
      reference: 'Ephesians 3:20',
      translation: 'King James Version',
      reflectionPrompt:
          'Have you stopped asking God for something because it seemed too big to actually happen?',
    ),
    Verse(
      text:
          'He hath made every thing beautiful in his time: also he hath set the world in their heart, so that no man can find out the work that God maketh from the beginning to the end.',
      reference: 'Ecclesiastes 3:11',
      translation: 'King James Version',
      reflectionPrompt:
          'What don\'t you understand about your circumstances right now that you\'re being asked to trust anyway?',
    ),
    Verse(
      text:
          'Know ye not that ye are the temple of God, and that the Spirit of God dwelleth in you?',
      reference: '1 Corinthians 3:16',
      translation: 'King James Version',
      reflectionPrompt:
          'How are you treating your body and mind today -- like a temple, or like an afterthought?',
    ),
    Verse(
      text:
          'For by grace are ye saved through faith; and that not of yourselves: it is the gift of God: Not of works, lest any man should boast.',
      reference: 'Ephesians 2:8-9',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you still trying to prove you deserve that was actually never going to be earned?',
    ),
    Verse(
      text:
          'Pleasant words are as an honeycomb, sweet to the soul, and health to the bones.',
      reference: 'Proverbs 16:24',
      translation: 'King James Version',
      reflectionPrompt:
          'Who could use a genuinely kind word from you today that you\'ve been too busy or too proud to give?',
    ),
    Verse(
      text:
          'And now, O Lord GOD, thou art that God, and thy words be true, and thou hast promised this goodness unto thy servant:',
      reference: '2 Samuel 7:28',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there a promise from God you\'re still waiting on that you haven\'t stopped believing is true?',
    ),
    Verse(
      text:
          'And the LORD passed by before him, and proclaimed, The LORD, The LORD God, merciful and gracious, longsuffering, and abundant in goodness and truth,',
      reference: 'Exodus 34:6',
      translation: 'King James Version',
      reflectionPrompt:
          'Which of these -- mercy, patience, goodness -- do you find hardest to believe is actually how God sees you?',
    ),
    Verse(
      text:
          'The LORD is good unto them that wait for him, to the soul that seeketh him. It is good that a man should both hope and quietly wait for the salvation of the LORD.',
      reference: 'Lamentations 3:25-26',
      translation: 'King James Version',
      reflectionPrompt:
          'Could you actually wait quietly today for something instead of forcing or fixing it yourself?',
    ),
    Verse(
      text:
          'Let your conversation be without covetousness; and be content with such things as ye have: for he hath said, I will never leave thee, nor forsake thee.',
      reference: 'Hebrews 13:5',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there something you\'re coveting today that\'s actually distracting you from the promise that you\'re not alone?',
    ),
    Verse(
      text: 'Thou art all fair, my love; there is no spot in thee.',
      reference: 'Song of Solomon 4:7',
      translation: 'King James Version',
      reflectionPrompt:
          'Whose eyes do you need to see yourself through today instead of your own harshest critique?',
    ),
    Verse(
      text:
          'To every thing there is a season, and a time to every purpose under the heaven:',
      reference: 'Ecclesiastes 3:1',
      translation: 'King James Version',
      reflectionPrompt:
          'Do you know what season you\'re actually in right now, and are you living like it?',
    ),
    Verse(
      text:
          'And said, Naked came I out of my mother\'s womb, and naked shall I return thither: the LORD gave, and the LORD hath taken away; blessed be the name of the LORD.',
      reference: 'Job 1:21',
      translation: 'King James Version',
      reflectionPrompt:
          'Could you still bless God\'s name today if he took away the thing you\'re gripping tightest?',
    ),
    Verse(
      text:
          'And I will walk among you, and will be your God, and ye shall be my people.',
      reference: 'Leviticus 26:12',
      translation: 'King James Version',
      reflectionPrompt:
          'Where do you keep God at a respectful distance instead of letting him walk alongside you today?',
    ),
    Verse(
      text:
          'The LORD bless thee, and keep thee: The LORD make his face shine upon thee, and be gracious unto thee: The LORD lift up his countenance upon thee, and give thee peace.',
      reference: 'Numbers 6:24-26',
      translation: 'King James Version',
      reflectionPrompt:
          'Would today feel different if you received it as blessed rather than just got through it?',
    ),
    Verse(
      text:
          'There hath no temptation taken you but such as is common to man: but God is faithful, who will not suffer you to be tempted above that ye are able; but will with the temptation also make a way to escape, that ye may be able to bear it.',
      reference: '1 Corinthians 10:13',
      translation: 'King James Version',
      reflectionPrompt:
          'Is there a temptation that keeps catching you off guard, one you haven\'t actually planned an exit for?',
    ),
    Verse(
      text:
          'Iron sharpeneth iron; so a man sharpeneth the countenance of his friend.',
      reference: 'Proverbs 27:17',
      translation: 'King James Version',
      reflectionPrompt:
          'Who in your life actually challenges you to be better instead of just agreeing with everything you do?',
    ),
    Verse(
      text:
          'Then he said unto them, Go your way, eat the fat, and drink the sweet, and send portions unto them for whom nothing is prepared: for this day is holy unto our Lord: neither be ye sorry; for the joy of the LORD is your strength.',
      reference: 'Nehemiah 8:10',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you trying to power through today on willpower instead of joy?',
    ),
    Verse(
      text:
          'I am Alpha and Omega, the beginning and the ending, saith the Lord, which is, and which was, and which is to come, the Almighty.',
      reference: 'Revelation 1:8',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you worrying will outlast God\'s control of it?',
    ),
    Verse(
      text:
          'Blessed is the man that walketh not in the counsel of the ungodly, nor standeth in the way of sinners, nor sitteth in the seat of the scornful. But his delight is in the law of the LORD; and in his law doth he meditate day and night.',
      reference: 'Psalm 1:1-2',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you letting yourself delight in that isn\'t actually good for the person you\'re becoming?',
    ),
    Verse(
      text:
          'For I the LORD thy God will hold thy right hand, saying unto thee, Fear not; I will help thee.',
      reference: 'Isaiah 41:13',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you white-knuckling through something today instead of letting your hand be held?',
    ),
    Verse(
      text:
          'Every man also to whom God hath given riches and wealth, and hath given him power to eat thereof, and to take his portion, and to rejoice in his labour; this is the gift of God.',
      reference: 'Ecclesiastes 5:19',
      translation: 'King James Version',
      reflectionPrompt:
          'Are you actually enjoying what you\'ve been given, or too busy chasing more of it to notice?',
    ),
    Verse(
      text: 'Truly my soul waiteth upon God: from him cometh my salvation.',
      reference: 'Psalm 62:1',
      translation: 'King James Version',
      reflectionPrompt:
          'How many other things are you waiting on today besides God, and which one are you actually trusting most?',
    ),
    Verse(
      text:
          'Daniel answered and said, Blessed be the name of God for ever and ever: for wisdom and might are his:',
      reference: 'Daniel 2:20',
      translation: 'King James Version',
      reflectionPrompt:
          'Whose wisdom are you taking credit for today that actually came from somewhere higher?',
    ),
    Verse(
      text:
          'And he said, My presence shall go with thee, and I will give thee rest.',
      reference: 'Exodus 33:14',
      translation: 'King James Version',
      reflectionPrompt:
          'What are you pushing through today without pausing to notice you\'re not doing it alone?',
    ),
    Verse(
      text:
          'Thou wilt shew me the path of life: in thy presence is fulness of joy; at thy right hand there are pleasures for evermore.',
      reference: 'Psalm 16:11',
      translation: 'King James Version',
      reflectionPrompt:
          'Where are you looking for joy today that isn\'t actually in his presence?',
    ),
    Verse(
      text:
          'Rejoice evermore. Pray without ceasing. In every thing give thanks: for this is the will of God in Christ Jesus concerning you.',
      reference: '1 Thessalonians 5:16-18',
      translation: 'King James Version',
      reflectionPrompt:
          'Which of these three -- constant joy, constant prayer, constant thanks -- have you let slide the most this week?',
    ),
  ];

  /// Index into [dailyVerses] for [date] — the same day-of-year always
  /// maps to the same index, in both the app and
  /// `tool/generate_daily_audio.dart` (which imports this file directly
  /// rather than re-implementing the mapping), so a client and the
  /// pre-generated audio for "today" always agree on which verse that is.
  static int indexForDate(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return dayOfYear % dailyVerses.length;
  }

  /// The verse for [date] — what Today (and the widgets) actually show.
  static Verse forDate(DateTime date) => dailyVerses[indexForDate(date)];
}
