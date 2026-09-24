import 'package:flutter/material.dart';

import '../../features/colors/domain/entities/app_color_settings.dart';

abstract final class AppTheme {
  static ThemeData light({
    Locale? locale,
    AppColorSettings colors = AppColorSettings.defaults,
  }) {
    final isArabic = locale?.languageCode == 'ar';

    final fontFamily = isArabic ? 'Tajawal' : 'Inter';

    final darkBaseTextTheme = ThemeData.dark().textTheme;

    final baseTextTheme = darkBaseTextTheme.apply(fontFamily: fontFamily);

    // --------------------------------------------------------------------
    // TYPOGRAPHY RESET
    // --------------------------------------------------------------------
    //
    // Design DNA: quiet, confident, editorial. Weights top out at w700 —
    // w800/w900 read as heavy/generic and are reserved for one-off, clearly
    // justified moments (none currently). Negative letterSpacing is an
    // English/Latin-only refinement: applying it to Arabic can visually
    // disturb letter joining, so it is zeroed out for Tajawal. Arabic also
    // gets a taller line-height across the board (set per-widget via
    // AppTypography) since Tajawal reads slightly denser than Inter at the
    // same leading.
    //
    final headingLetterSpacing = isArabic ? 0.0 : -0.8;
    final displayLetterSpacing = isArabic ? 0.0 : -1.0;

    final textTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w700,
        letterSpacing: displayLetterSpacing,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w700,
        letterSpacing: displayLetterSpacing,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w700,
        letterSpacing: headingLetterSpacing,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w700,
        letterSpacing: headingLetterSpacing,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w600,
        letterSpacing: headingLetterSpacing,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: colors.primaryText,
        height: isArabic ? 1.85 : 1.7,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: colors.primaryText,
        height: isArabic ? 1.75 : 1.6,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: colors.secondaryText,
        height: isArabic ? 1.65 : 1.5,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        color: colors.primaryText,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        color: colors.secondaryText,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        color: colors.secondaryText,
        fontWeight: FontWeight.w500,
      ),
    );

    final scheme = ColorScheme.dark(
      primary: colors.accent,
      onPrimary: _contrastColor(colors.accent),
      secondary: colors.accent,
      onSecondary: _contrastColor(colors.accent),
      surface: colors.surface,
      onSurface: colors.primaryText,
      outline: colors.border,
      error: colors.error,
      onError: _contrastColor(colors.error),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: scheme,

      scaffoldBackgroundColor: colors.scaffoldBackground,
      canvasColor: colors.scaffoldBackground,

      // The primary application font follows the current locale:
      //
      // English -> Inter
      // Arabic  -> Tajawal
      fontFamily: fontFamily,
      textTheme: textTheme,

      splashFactory: InkSparkle.splashFactory,

      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: colors.border),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          ),
          backgroundColor: WidgetStatePropertyAll(colors.accent),
          foregroundColor: WidgetStatePropertyAll(
            _contrastColor(colors.accent),
          ),
          elevation: const WidgetStatePropertyAll(0),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          animationDuration: const Duration(milliseconds: 180),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          ),
          foregroundColor: WidgetStatePropertyAll(colors.accent),
          side: WidgetStatePropertyAll(BorderSide(color: colors.accent)),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          animationDuration: const Duration(milliseconds: 180),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(colors.accent),
          overlayColor: WidgetStatePropertyAll(
            colors.accent.withValues(alpha: .08),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          overlayColor: WidgetStatePropertyAll(
            colors.accent.withValues(alpha: .08),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,

        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.secondaryText),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: colors.border),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: colors.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: colors.accent, width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: colors.error),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,

        labelStyle: textTheme.labelMedium?.copyWith(
          color: colors.accent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),

        side: BorderSide(color: colors.border),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.border),
        ),

        textStyle: textTheme.bodySmall?.copyWith(
          color: colors.primaryText,
          fontSize: 12,
        ),
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          colors.secondaryText.withValues(alpha: .35),
        ),
        radius: const Radius.circular(2),
        thickness: const WidgetStatePropertyAll(5),
      ),
    );
  }

  static Color _contrastColor(Color color) {
    return color.computeLuminance() > .5 ? Colors.black : Colors.white;
  }
}
