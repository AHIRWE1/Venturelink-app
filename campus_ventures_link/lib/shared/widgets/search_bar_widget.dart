import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Reusable search field. Pass [onTap] with `readOnly: true` for a
/// "tap to go search elsewhere" entry point (Home); pass [controller] +
/// [onChanged] for live in-place search/filter (Explore, Admin Users).
class SearchBarWidget extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? trailing;

  const SearchBarWidget({
    super.key,
    this.hint = 'Search...',
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: readOnly ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search_outlined, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: readOnly
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          hint,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : TextField(
                        controller: controller,
                        onChanged: onChanged,
                        onTap: onTap,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
