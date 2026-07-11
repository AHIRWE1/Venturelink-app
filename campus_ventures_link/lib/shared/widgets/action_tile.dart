import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// A single quick-action button (icon chip + label) used in every
/// dashboard's "Quick actions" row. Supports a vertical layout (icon over
/// label, for a row of 3 tiles) and a horizontal one (icon beside label,
/// for a row of 2 wider tiles).
class ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Axis axis;

  const ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
    this.axis = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final iconChip = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );

    final labelText = Text(
      label,
      textAlign: axis == Axis.vertical ? TextAlign.center : TextAlign.left,
      maxLines: 2,
      style: AppTextStyles.body.copyWith(
        fontSize: axis == Axis.vertical ? 11 : 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: axis == Axis.vertical
              ? const EdgeInsets.symmetric(vertical: 16, horizontal: 8)
              : const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: axis == Axis.vertical
              ? Column(
                  children: [iconChip, const SizedBox(height: 8), labelText],
                )
              : Row(
                  children: [
                    iconChip,
                    const SizedBox(width: 10),
                    Expanded(child: labelText),
                  ],
                ),
        ),
      ),
    );
  }
}
