import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AuthFormScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;

  const AuthFormScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              Text(AppStrings.appName, style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text(subtitle, style: AppTextStyles.body),
              const SizedBox(height: 32),
              Text(title, style: AppTextStyles.heading1.copyWith(fontSize: 26)),
              const SizedBox(height: 24),
              child,
              if (footer != null) ...[
                const SizedBox(height: 24),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
