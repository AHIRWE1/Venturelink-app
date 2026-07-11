import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // Mirrors the literal values AppColors.background/surface/textPrimary
  // resolve to for each brightness (see app_colors.dart) — kept as
  // explicit constants here (rather than reading the ambient getters) so
  // `lightTheme`/`darkTheme` are unambiguous regardless of what the
  // current platform brightness happens to be when they're constructed.
  static const _lightBackground = Color(0xFFF5F7FB);
  static const _lightSurface = Colors.white;
  static const _lightTextPrimary = Color(0xFF1F2937);

  static const _darkBackground = Color(0xFF121218);
  static const _darkSurface = Color(0xFF1E1E27);
  static const _darkTextPrimary = Color(0xFFF3F4F6);

  static ThemeData get lightTheme => _themeFor(
    brightness: Brightness.light,
    background: _lightBackground,
    surface: _lightSurface,
    textPrimary: _lightTextPrimary,
  );

  static ThemeData get darkTheme => _themeFor(
    brightness: Brightness.dark,
    background: _darkBackground,
    surface: _darkSurface,
    textPrimary: _darkTextPrimary,
  );

  static ThemeData _themeFor({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color textPrimary,
  }) {
    final colorScheme = brightness == Brightness.dark
        ? ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: surface,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: textPrimary,
            error: AppColors.error,
          )
        : ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: surface,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: textPrimary,
            error: AppColors.error,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.35),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
