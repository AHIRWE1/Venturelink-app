import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Full-bleed gradient hero header used at the top of every dashboard
/// (Student Home, Founder Dashboard, Admin Dashboard) and available for
/// any new screen that wants the same "hero" treatment (e.g. Create
/// Opportunity, Profile). Centralizes the header so all three dashboards
/// stay visually identical instead of each hand-rolling their own gradient
/// Container.
class GradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Icon buttons / avatar shown at the top-right of the header.
  final Widget? trailing;

  /// Extra content below the title/subtitle row — e.g. a row of live stat
  /// chips on Student Home.
  final Widget? bottom;
  final List<Color>? colors;

  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottom != null ? 24 : 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? const [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
            if (bottom != null) ...[const SizedBox(height: 20), bottom!],
          ],
        ),
      ),
    );
  }
}
