import 'package:flutter/material.dart';

/// Text styles for the two typefaces used across the app:
/// - **Lora** (serif) — verse text, screen titles, journal bodies.
/// - **Inter** (sans) — all other UI text.
///
/// Both are bundled as single variable-weight TTFs (see pubspec.yaml), so
/// exact weights — including the design spec's non-standard 450 — are
/// requested with [FontVariation.weight] rather than the coarser
/// [FontWeight] steps of 100.
class AppText {
  const AppText._();

  static TextStyle _lora({
    required double size,
    required double weight,
    bool italic = false,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: 'Lora',
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontVariations: [FontVariation.weight(weight)],
      fontSize: size,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle _inter({
    required double size,
    required double weight,
    bool italic = false,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontVariations: [FontVariation.weight(weight)],
      fontSize: size,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // -- Lora (serif) --------------------------------------------------

  /// Verse text — 27pt italic, line-height 1.44.
  static TextStyle verse({Color? color}) => _lora(
        size: 27,
        weight: 400,
        italic: true,
        height: 1.44,
        color: color,
      );

  /// Screen titles ("Journal", "30 Days on Faith", "Widgets") — 25-26pt.
  static TextStyle screenTitle({double size = 26, Color? color}) =>
      _lora(size: size, weight: 400, color: color);

  /// Journal entry bodies — 15.5pt.
  static TextStyle entryBody({Color? color}) =>
      _lora(size: 15.5, weight: 400, height: 1.55, color: color);

  /// Journal composer placeholder — 17pt italic.
  static TextStyle composerPlaceholder({Color? color}) => _lora(
        size: 17,
        weight: 400,
        italic: true,
        height: 1.5,
        color: color,
      );

  /// Widget verse excerpt — large (19pt) / small (15pt), italic.
  static TextStyle widgetVerse({required double size, Color? color}) =>
      _lora(size: size, weight: 400, italic: true, height: 1.4, color: color);

  /// App-icon "3:16" numeral mark.
  static TextStyle iconNumeral({required double size, Color? color}) => _lora(
        size: size,
        weight: 400,
        italic: true,
        letterSpacing: -0.02 * size,
        color: color,
      );

  // -- Inter (sans) ----------------------------------------------------

  /// Greeting — 19pt/600, -0.01em.
  static TextStyle greeting({Color? color}) => _inter(
        size: 19,
        weight: 600,
        letterSpacing: -0.19,
        color: color,
      );

  /// Body — 14.5pt.
  static TextStyle body({double height = 1.6, Color? color}) =>
      _inter(size: 14.5, weight: 400, height: height, color: color);

  /// Secondary — 13pt.
  static TextStyle secondary({Color? color}) =>
      _inter(size: 13, weight: 400, color: color);

  /// Meta / caption — 11.5-12pt.
  static TextStyle meta({double size = 11.5, double weight = 400, Color? color}) =>
      _inter(size: size, weight: weight, color: color);

  /// Eyebrow — 11pt/600, uppercase, letter-spacing 0.16em.
  static TextStyle eyebrow({Color? color}) => _inter(
        size: 11,
        weight: 600,
        letterSpacing: 1.76,
        color: color,
      );

  /// Widget-card eyebrow ("JOHN 3:16") — 10.5pt/600, tighter tracking.
  static TextStyle widgetEyebrow({double size = 10.5, Color? color}) =>
      _inter(size: size, weight: 600, letterSpacing: size * 0.14, color: color);

  /// Tab label — 10pt, 0.04em; 600 active / 450 inactive.
  static TextStyle tabLabel({required bool active, Color? color}) => _inter(
        size: 10,
        weight: active ? 600 : 450,
        letterSpacing: 0.4,
        color: color,
      );

  /// Tag chip label — 12.5pt/500.
  static TextStyle tagChip({Color? color}) =>
      _inter(size: 12.5, weight: 500, color: color);

  /// Tag badge on a journal entry — 10.5pt/600, 0.04em.
  static TextStyle tagBadge({Color? color}) => _inter(
        size: 10.5,
        weight: 600,
        letterSpacing: 0.42,
        color: color,
      );

  /// Button label (Listen) — 15pt/600.
  static TextStyle button({Color? color}) =>
      _inter(size: 15, weight: 600, color: color);

  /// Text link ("Write about this") — 13.5pt/500.
  static TextStyle link({Color? color}) =>
      _inter(size: 13.5, weight: 500, color: color);

  /// Streak-pill label — 12.5pt/600.
  static TextStyle streak({Color? color}) =>
      _inter(size: 12.5, weight: 600, color: color);

  /// Plan day-number tile — 13pt/600.
  static TextStyle dayNumber({Color? color}) =>
      _inter(size: 13, weight: 600, color: color);

  /// Plan day theme title — 15pt/500.
  static TextStyle dayTitle({Color? color}) =>
      _inter(size: 15, weight: 500, color: color);
}
