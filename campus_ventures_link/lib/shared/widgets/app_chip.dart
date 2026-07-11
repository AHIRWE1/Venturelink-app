import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Generic pill chip used for category filters, skill tags, and employment
/// type selection. `onTap == null` renders a static, non-interactive tag
/// (e.g. a skill chip on a details screen); passing `onTap` renders a
/// tappable filter/selector chip with a selected state.
class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final VoidCallback? onDeleted;

  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.primary : AppColors.textSecondary;
    final bg = selected
        ? AppColors.primary.withValues(alpha: 0.16)
        : AppColors.secondary.withValues(alpha: 0.08);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            color: fg,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        if (onDeleted != null) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDeleted,
            child: Icon(Icons.close, size: 15, color: fg),
          ),
        ],
      ],
    );

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: content,
    );

    if (onTap == null) return chip;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: chip,
      ),
    );
  }
}
