import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Colored pill used to show application/startup status. Follows the same
/// color mapping originally introduced by the startup module's status chip:
/// pending = amber, accepted/approved/active = primary, rejected = error.
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  static ({Color bg, Color fg, IconData icon}) _styleFor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'approved':
      case 'active':
      case 'open':
        return (
          bg: AppColors.success.withValues(alpha: 0.14),
          fg: const Color(0xFF15803D),
          icon: Icons.check_circle_outline,
        );
      case 'interview':
      case 'under_review':
        return (
          bg: AppColors.primary.withValues(alpha: 0.12),
          fg: AppColors.primary,
          icon: Icons.forum_outlined,
        );
      case 'rejected':
        return (
          bg: AppColors.error.withValues(alpha: 0.12),
          fg: AppColors.error,
          icon: Icons.cancel_outlined,
        );
      case 'withdrawn':
      case 'closed':
        return (
          bg: AppColors.textSecondary.withValues(alpha: 0.12),
          fg: AppColors.textSecondary,
          icon: Icons.undo_outlined,
        );
      case 'pending':
      default:
        return (
          bg: AppColors.warning.withValues(alpha: 0.16),
          fg: const Color(0xFF92640A),
          icon: Icons.schedule_outlined,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(status);
    final label = status.isEmpty
        ? 'Pending'
        : status[0].toUpperCase() + status.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: style.fg,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
