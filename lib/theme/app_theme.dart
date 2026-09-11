import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Builds the two [ThemeData]s (dark / light) the app switches between via
/// `themeMode: ThemeMode.system`. All screens read colors through the
/// [AppPalette] extension rather than `Theme.of(context).colorScheme`, since
/// the design uses bespoke tokens (gold/amber accents, warm off-white /
/// parchment bases) that don't map cleanly onto Material's scheme roles.
class AppTheme {
  const AppTheme._();

  static ThemeData build(AppPalette palette) {
    final brightness = palette.isDark ? Brightness.dark : Brightness.light;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.screenBg,
      fontFamily: 'Inter',
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.accent,
        selectionColor: palette.accent.withValues(alpha: 0.3),
        selectionHandleColor: palette.accent,
      ),
      extensions: [palette],
    );
  }

  static ThemeData get dark => build(AppPalette.dark);
  static ThemeData get light => build(AppPalette.light);
}
