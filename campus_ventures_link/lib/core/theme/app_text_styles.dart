import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Not `const` because AppColors.textPrimary/textSecondary now resolve at
  // runtime based on platform brightness (see app_colors.dart) — the call
  // site syntax (`AppTextStyles.heading1`) is unchanged either way.
  static TextStyle get heading1 => TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get heading2 => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get body =>
      TextStyle(fontSize: 16, color: AppColors.textSecondary);

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}