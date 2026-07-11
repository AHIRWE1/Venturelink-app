import 'package:flutter/material.dart';

/// Brand colors (primary/secondary/accent/success/error/warning) stay
/// identical across light and dark mode — only the neutral
/// background/surface/text colors adapt.
///
/// [_isDark] is driven by [syncBrightness], which the app root calls every
/// build with `Theme.of(context).brightness` — i.e. whatever MaterialApp
/// actually resolved from [ThemeMode] (system, or an explicit manual
/// override from the Appearance setting), not the raw OS brightness. That
/// keeps these getters correct even when a user picks "Dark" while their
/// OS is set to light. Falls back to the platform brightness once at
/// class-load time so nothing looks wrong before the first frame.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF8B80F9);

  static const Color accent = Color(0xFF4ECDC4);

  static const Color success = Color(0xFF2ECC71);

  static const Color error = Color(0xFFE74C3C);

  static const Color warning = Color(0xFFF39C12);

  static bool _isDark =
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  static void syncBrightness(Brightness brightness) {
    _isDark = brightness == Brightness.dark;
  }

  static Color get background =>
      _isDark ? const Color(0xFF121218) : const Color(0xFFF5F7FB);

  static Color get surface =>
      _isDark ? const Color(0xFF1E1E27) : Colors.white;

  static Color get textPrimary =>
      _isDark ? const Color(0xFFF3F4F6) : const Color(0xFF1F2937);

  static Color get textSecondary =>
      _isDark ? const Color(0xFFA1A1AA) : const Color(0xFF6B7280);
}
