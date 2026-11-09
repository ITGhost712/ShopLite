import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF141210);
  static const surface = Color(0xFF1D1916);
  static const surfaceRaised = Color(0xFF2B251F);
  static const cream = Color(0xFFFFF9F1);
  static const muted = Color(0xFFCDC1B5);
  static const copper = Color(0xFFE29A63);
  static const line = Color(0xFF40372F);
}

abstract final class ShopType {
  static const family = 'Poppins';

  static const display = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w600,
    letterSpacing: -.8,
    height: 1.12,
  );

  static const eyebrow = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w600,
    fontSize: 11,
    letterSpacing: 1.6,
    height: 1.25,
  );

  static const reading = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w400,
  );

  static const strong = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w600,
  );

  static const numerals = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static final price = numerals.copyWith(
    fontWeight: FontWeight.w400,
    letterSpacing: -.25,
  );
}

ThemeData buildShopLiteTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final background = dark ? AppColors.ink : AppColors.cream;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF9A4D25),
    brightness: brightness,
    primary: dark ? AppColors.copper : const Color(0xFF87401C),
    onPrimary: dark ? AppColors.ink : Colors.white,
    surface: dark ? AppColors.surface : const Color(0xFFFFFCF8),
    onSurface: dark ? AppColors.cream : AppColors.ink,
    onSurfaceVariant: dark ? AppColors.muted : const Color(0xFF635044),
    surfaceContainerHighest: dark
        ? AppColors.surfaceRaised
        : const Color(0xFFF0E5D9),
    outlineVariant: dark ? AppColors.line : const Color(0xFFDBC9BA),
  );
  final foreground = scheme.onSurface;
  final muted = scheme.onSurfaceVariant;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    fontFamily: ShopType.family,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: foreground,
      centerTitle: true,
      titleTextStyle: ShopType.eyebrow.copyWith(color: foreground),
    ),
    textTheme: TextTheme(
      headlineLarge: ShopType.display.copyWith(fontSize: 36, color: foreground),
      headlineMedium: ShopType.display.copyWith(
        fontSize: 32,
        color: foreground,
      ),
      headlineSmall: ShopType.display.copyWith(fontSize: 25, color: foreground),
      titleLarge: ShopType.strong.copyWith(color: foreground),
      titleMedium: ShopType.strong.copyWith(color: foreground, fontSize: 16),
      titleSmall: ShopType.strong.copyWith(color: foreground, fontSize: 14),
      bodyLarge: ShopType.reading.copyWith(
        color: foreground,
        fontSize: 16,
        height: 1.35,
      ),
      bodyMedium: ShopType.reading.copyWith(
        color: muted,
        fontSize: 14,
        height: 1.3,
      ),
      bodySmall: ShopType.reading.copyWith(
        color: muted,
        fontSize: 13,
        height: 1.35,
      ),
      labelLarge: ShopType.strong.copyWith(fontSize: 14, letterSpacing: .15),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark
          ? Colors.white.withValues(alpha: .08)
          : scheme.surfaceContainerHighest,
      hintStyle: ShopType.reading.copyWith(color: muted, fontSize: 15),
      prefixIconColor: foreground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        shape: const StadiumBorder(),
        textStyle: ShopType.strong.copyWith(fontSize: 14, letterSpacing: .15),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      labelTextStyle: WidgetStatePropertyAll(
        ShopType.reading.copyWith(color: foreground, fontSize: 14),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: background,
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => ShopType.strong.copyWith(
          fontSize: 12,
          letterSpacing: .3,
          color: states.contains(WidgetState.selected) ? scheme.primary : muted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : foreground,
        ),
      ),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.surfaceContainerHighest,
      contentTextStyle: ShopType.reading.copyWith(
        color: foreground,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
