import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/startup/presentation/controllers/startup_controller.dart';
import '../models/opportunity.dart';
import 'bookmark_toggle_button.dart';
import 'status_badge.dart';

/// Reusable opportunity card used across Home, Explore, and Bookmarks.
///
/// `featured: true` renders the gradient "Recommended" style card from the
/// design reference (used in horizontal carousels); `featured: false`
/// renders the white list-style card (used in vertical lists).
class OpportunityCard extends ConsumerWidget {
  final Opportunity opportunity;
  final String studentId;
  final bool featured;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.studentId,
    this.featured = false,
  });

  void _open(BuildContext context) {
    context.go(
      AppRoutes.opportunityDetails.replaceFirst(
        ':opportunityId',
        opportunity.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(startupByIdProvider(opportunity.startupId));
    final startupName = startupAsync.value?.startupName;

    return featured
        ? _FeaturedCard(
            opportunity: opportunity,
            studentId: studentId,
            startupName: startupName,
            onTap: () => _open(context),
          )
        : _ListCard(
            opportunity: opportunity,
            studentId: studentId,
            startupName: startupName,
            onTap: () => _open(context),
          );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Opportunity opportunity;
  final String studentId;
  final String? startupName;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.opportunity,
    required this.studentId,
    required this.startupName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  StatusBadge(status: opportunity.status),
                  const SizedBox(width: 4),
                  BookmarkToggleButton(
                    studentId: studentId,
                    opportunityId: opportunity.id,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white.withValues(alpha: 0.85),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                opportunity.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                startupName ?? 'ALU Startup',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _Pill(label: opportunity.category, light: true),
                  _Pill(label: opportunity.employmentType, light: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final Opportunity opportunity;
  final String studentId;
  final String? startupName;
  final VoidCallback onTap;

  const _ListCard({
    required this.opportunity,
    required this.studentId,
    required this.startupName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.work_outline, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.title,
                      style: AppTextStyles.heading2.copyWith(fontSize: 17),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      startupName ?? 'ALU Startup',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Pill(label: opportunity.employmentType),
                        _Pill(label: opportunity.location),
                        if (opportunity.deadline != null)
                          _Pill(label: 'Due ${_fmtDate(opportunity.deadline!)}'),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusBadge(status: opportunity.status),
                  const SizedBox(height: 4),
                  BookmarkToggleButton(
                    studentId: studentId,
                    opportunityId: opportunity.id,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool light;

  const _Pill({required this.label, this.light = false});

  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: light
            ? Colors.white.withValues(alpha: 0.18)
            : AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: light ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}
