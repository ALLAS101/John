import 'package:flutter/material.dart';

/// A pair of colors used to badge a journal tag (background fill + label).
@immutable
class TagColor {
  const TagColor(this.bg, this.fg);
  final Color bg;
  final Color fg;
}

/// All design tokens for one theme (dark or light), grouped to match the
/// "Design Tokens" table in the design handoff README. Every color here is
/// copied verbatim from the reference HTML/CSS — see
/// design_handoff_john_3_16/README.md for the source table.
///
/// Registered as a [ThemeExtension] so screens read it with
/// `Theme.of(context).extension<AppPalette>()!` (or the `context.palette`
/// getter below).
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.isDark,
    required this.screenBg,
    required this.widgetTabBg,
    required this.warmBase,
    required this.textPrimary,
    required this.entryBodyBase,
    required this.accent,
    required this.accentText,
    required this.accentTextDeep,
    required this.solidFill,
    required this.onSolidFill,
    required this.buttonGradient,
    required this.buttonInk,
    required this.buttonShadowColor,
    required this.progressGradient,
    required this.elevatedSurfaceGradient,
    required this.elevatedSurfaceShadow,
    required this.cardBorder,
    required this.rowBorder,
    required this.subtleSurface,
    required this.composerBg,
    required this.composerBorder,
    required this.composerShadow,
    required this.dawnGlow,
    required this.planCardGradient,
    required this.planCardBorder,
    required this.widgetCardGradientLarge,
    required this.widgetCardGradientSmall,
    required this.widgetGlowLarge,
    required this.widgetGlowSmall,
    required this.tabBarBorder,
    required this.tabInactive,
    required this.tagColors,
  });

  final bool isDark;

  /// Screen background (Today / Journal / Plan).
  final Color screenBg;

  /// Background used only on the Widget-preview screen (a subtle vertical
  /// gradient rather than the flat [screenBg]). Null falls back to [screenBg].
  final Gradient widgetTabBg;

  /// Base color that opacity-driven secondary/meta/placeholder/border text
  /// and hairlines are derived from (`rgba(244,234,216,*)` dark /
  /// `rgba(22,27,48,*)` light).
  final Color warmBase;

  /// Verse text / screen headings.
  final Color textPrimary;

  /// Base color for journal entry bodies and "done" list-item titles
  /// (`rgba(247,240,226,*)` dark / `rgba(18,23,43,*)` light — close to
  /// [textPrimary] but a distinct base used at high opacity).
  final Color entryBodyBase;

  /// Primary gold/amber accent — icons, active tab, progress numerals.
  final Color accent;

  /// Accent used for eyebrows, text links, streak label.
  final Color accentText;

  /// Deepened accent for selected tag-chip label / completed plan-day number.
  final Color accentTextDeep;

  /// Solid fill for a "filled" state (saved bookmark, completed checkbox).
  final Color solidFill;

  /// Content drawn on top of [solidFill] (e.g. the day-checkbox checkmark).
  final Color onSolidFill;

  /// Listen button / mic button gradient (gold → ember dark, amber →
  /// ember light).
  final List<Color> buttonGradient;

  /// Text/icon ink color on top of [buttonGradient].
  final Color buttonInk;

  /// Base color for the drop shadow under gold buttons (alpha applied by
  /// caller).
  final Color buttonShadowColor;

  /// Plan progress-bar fill gradient (ember → gold).
  final List<Color> progressGradient;

  /// Verse / entry-composer card background.
  final Gradient elevatedSurfaceGradient;
  final BoxShadow elevatedSurfaceShadow;

  final Color cardBorder;
  final Color rowBorder;

  /// Past-entry row background.
  final Color subtleSurface;

  final Color composerBg;
  final Color composerBorder;
  final BoxShadow? composerShadow;

  /// Dawn-glow radial gradient behind the Today screen header.
  final Gradient dawnGlow;

  /// Plan progress-card background.
  final Gradient planCardGradient;
  final Color planCardBorder;

  final Gradient widgetCardGradientLarge;
  final Gradient widgetCardGradientSmall;
  final Gradient widgetGlowLarge;
  final Gradient widgetGlowSmall;

  final Color tabBarBorder;
  final Color tabInactive;

  final Map<String, TagColor> tagColors;

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    // Tokens are swapped wholesale at the theme boundary, not animated
    // between — the two themes are visually distinct enough that a color
    // lerp would produce muddy intermediate frames.
    if (other is! AppPalette) return this;
    return t < 0.5 ? this : other;
  }

  // ---------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------
  static final AppPalette dark = AppPalette(
    isDark: true,
    screenBg: const Color(0xFF0A0D1C),
    widgetTabBg: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF111634), Color(0xFF0A0D1C), Color(0xFF07091A)],
      stops: [0, 0.55, 1],
    ),
    warmBase: const Color(0xFFF4EAD8),
    textPrimary: const Color(0xFFF7F0E2),
    entryBodyBase: const Color(0xFFF7F0E2),
    accent: const Color(0xFFE8B65A),
    accentText: const Color(0xFFE8B65A),
    accentTextDeep: const Color(0xFFE8B65A),
    solidFill: const Color(0xFFE8B65A),
    onSolidFill: const Color(0xFF14100A),
    buttonGradient: const [Color(0xFFE8B65A), Color(0xFFD97742)],
    buttonInk: const Color(0xFF14100A),
    buttonShadowColor: const Color(0xFFD97742),
    progressGradient: const [Color(0xFFD97742), Color(0xFFE8B65A)],
    elevatedSurfaceGradient: LinearGradient(
      begin: const Alignment(-0.7, -1),
      end: const Alignment(0.7, 1),
      colors: [
        const Color(0xFFF4EAD8).withValues(alpha: 0.09),
        const Color(0xFFF4EAD8).withValues(alpha: 0.035),
        const Color(0x000A0D1C),
      ],
      stops: const [0, 0.55, 1],
    ),
    elevatedSurfaceShadow: BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 60,
      offset: const Offset(0, 24),
    ),
    cardBorder: const Color(0xFFF4EAD8).withValues(alpha: 0.12),
    rowBorder: const Color(0xFFF4EAD8).withValues(alpha: 0.07),
    subtleSurface: const Color(0xFFF4EAD8).withValues(alpha: 0.035),
    composerBg: const Color(0xFFF4EAD8).withValues(alpha: 0.055),
    composerBorder: const Color(0xFFF4EAD8).withValues(alpha: 0.11),
    composerShadow: null,
    dawnGlow: RadialGradient(
      colors: [
        const Color(0xFFE8B65A).withValues(alpha: 0.34),
        const Color(0xFFD97742).withValues(alpha: 0.16),
        const Color(0x000A0D1C),
      ],
      stops: const [0, 0.42, 0.72],
    ),
    planCardGradient: LinearGradient(
      begin: const Alignment(-0.6, -1),
      end: const Alignment(0.6, 1),
      colors: [
        const Color(0xFFE8B65A).withValues(alpha: 0.14),
        const Color(0xFFF4EAD8).withValues(alpha: 0.03),
      ],
      stops: const [0, 0.7],
    ),
    planCardBorder: const Color(0xFFE8B65A).withValues(alpha: 0.18),
    widgetCardGradientLarge: const LinearGradient(
      begin: Alignment(-0.5, -1),
      end: Alignment(0.5, 1),
      colors: [Color(0xFF1B2145), Color(0xFF0D1128), Color(0xFF0A0D1C)],
      stops: [0, 0.58, 1],
    ),
    widgetCardGradientSmall: const LinearGradient(
      begin: Alignment(-0.7, -1),
      end: Alignment(0.7, 1),
      colors: [Color(0xFF1B2145), Color(0xFF0C1026)],
    ),
    widgetGlowLarge: RadialGradient(
      colors: [
        const Color(0xFFE8B65A).withValues(alpha: 0.3),
        const Color(0x000A0D1C),
      ],
      stops: const [0, 0.7],
    ),
    widgetGlowSmall: RadialGradient(
      colors: [
        const Color(0xFFD97742).withValues(alpha: 0.28),
        const Color(0x000A0D1C),
      ],
      stops: const [0, 0.7],
    ),
    tabBarBorder: const Color(0xFFE8B65A).withValues(alpha: 0.12),
    tabInactive: const Color(0xFFF4EAD8).withValues(alpha: 0.38),
    tagColors: {
      'Gratitude': TagColor(
        const Color(0xFFE8B65A).withValues(alpha: 0.16),
        const Color(0xFFE8B65A),
      ),
      'Request': TagColor(
        const Color(0xFF9DB4E0).withValues(alpha: 0.16),
        const Color(0xFF9DB4E0),
      ),
      'Praise': TagColor(
        const Color(0xFFD97742).withValues(alpha: 0.18),
        const Color(0xFFE5936A),
      ),
      'Confession': TagColor(
        const Color(0xFFF4EAD8).withValues(alpha: 0.1),
        const Color(0xFFF4EAD8).withValues(alpha: 0.72),
      ),
    },
  );

  // ---------------------------------------------------------------------
  // Light theme
  // ---------------------------------------------------------------------
  static final AppPalette light = AppPalette(
    isDark: false,
    screenBg: const Color(0xFFFDF8EE),
    widgetTabBg: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFFCF4), Color(0xFFFDF8EE), Color(0xFFF7EFE0)],
      stops: [0, 0.55, 1],
    ),
    warmBase: const Color(0xFF161B30),
    textPrimary: const Color(0xFF12172B),
    entryBodyBase: const Color(0xFF12172B),
    accent: const Color(0xFF9A6512),
    accentText: const Color(0xFF8A5910),
    accentTextDeep: const Color(0xFF7E5210),
    solidFill: const Color(0xFFC9862C),
    onSolidFill: const Color(0xFFFFFFFF),
    buttonGradient: const [Color(0xFFE8A23E), Color(0xFFC9622C)],
    buttonInk: const Color(0xFF2A1704),
    buttonShadowColor: const Color(0xFFC9622C),
    progressGradient: const [Color(0xFFC9622C), Color(0xFFE8A23E)],
    elevatedSurfaceGradient: const LinearGradient(
      begin: Alignment(-0.7, -1),
      end: Alignment(0.7, 1),
      colors: [Color(0xFFFFFFFF), Color(0xFFFFFBF2), Color(0xFFFDF6EA)],
      stops: [0, 0.6, 1],
    ),
    elevatedSurfaceShadow: BoxShadow(
      color: const Color(0xFF583C14).withValues(alpha: 0.12),
      blurRadius: 46,
      offset: const Offset(0, 20),
    ),
    cardBorder: const Color(0xFF161B30).withValues(alpha: 0.08),
    rowBorder: const Color(0xFF161B30).withValues(alpha: 0.07),
    subtleSurface: Colors.white.withValues(alpha: 0.7),
    composerBg: Colors.white,
    composerBorder: const Color(0xFF161B30).withValues(alpha: 0.08),
    composerShadow: BoxShadow(
      color: const Color(0xFF583C14).withValues(alpha: 0.08),
      blurRadius: 30,
      offset: const Offset(0, 12),
    ),
    dawnGlow: RadialGradient(
      colors: [
        const Color(0xFFF0B256).withValues(alpha: 0.42),
        const Color(0xFFD97742).withValues(alpha: 0.16),
        const Color(0x00FDF8EE),
      ],
      stops: const [0, 0.44, 0.72],
    ),
    planCardGradient: LinearGradient(
      begin: const Alignment(-0.6, -1),
      end: const Alignment(0.6, 1),
      colors: [
        const Color(0xFFF0B256).withValues(alpha: 0.28),
        Colors.white.withValues(alpha: 0.9),
      ],
      stops: const [0, 0.72],
    ),
    planCardBorder: const Color(0xFF9A6512).withValues(alpha: 0.2),
    widgetCardGradientLarge: const LinearGradient(
      begin: Alignment(-0.5, -1),
      end: Alignment(0.5, 1),
      colors: [Color(0xFFFFFFFF), Color(0xFFFFF8EA), Color(0xFFFBEFDA)],
      stops: [0, 0.62, 1],
    ),
    widgetCardGradientSmall: const LinearGradient(
      begin: Alignment(-0.7, -1),
      end: Alignment(0.7, 1),
      colors: [Color(0xFFFFFFFF), Color(0xFFFCF3E3)],
    ),
    widgetGlowLarge: RadialGradient(
      colors: [
        const Color(0xFFF0B256).withValues(alpha: 0.4),
        const Color(0x00FDF8EE),
      ],
      stops: const [0, 0.7],
    ),
    widgetGlowSmall: RadialGradient(
      colors: [
        const Color(0xFFD97742).withValues(alpha: 0.24),
        const Color(0x00FDF8EE),
      ],
      stops: const [0, 0.7],
    ),
    tabBarBorder: const Color(0xFF9A6512).withValues(alpha: 0.14),
    tabInactive: const Color(0xFF161B30).withValues(alpha: 0.42),
    tagColors: {
      'Gratitude': TagColor(
        const Color(0xFFF0B256).withValues(alpha: 0.24),
        const Color(0xFF7E5210),
      ),
      'Request': TagColor(
        const Color(0xFF5A78B4).withValues(alpha: 0.18),
        const Color(0xFF3C5488),
      ),
      'Praise': TagColor(
        const Color(0xFFC9622C).withValues(alpha: 0.18),
        const Color(0xFF9B4A1E),
      ),
      'Confession': TagColor(
        const Color(0xFF161B30).withValues(alpha: 0.08),
        const Color(0xFF161B30).withValues(alpha: 0.7),
      ),
    },
  );
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
