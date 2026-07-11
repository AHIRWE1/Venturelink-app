import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// A single tile in a dashboard's statistics grid — an icon chip, a value
/// (a widget so callers can pass either a number or something like a
/// [StatusBadge]), and a label. Used by every dashboard's stats grid.
class MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget value;
  final Color color;

  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.primary,
  });

  /// Convenience constructor for the common case of a plain numeric value.
  factory MetricCard.count({
    Key? key,
    required IconData icon,
    required String label,
    required int count,
    Color color = AppColors.primary,
  }) {
    return MetricCard(
      key: key,
      icon: icon,
      label: label,
      color: color,
      value: Text('$count', style: AppTextStyles.heading1.copyWith(fontSize: 22)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          value,
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.body.copyWith(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
