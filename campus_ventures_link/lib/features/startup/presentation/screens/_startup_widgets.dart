import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/startup.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/status_badge.dart';

class EmptyStartupCard extends StatelessWidget {
  const EmptyStartupCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.secondary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No startup yet', style: AppTextStyles.heading2),
            const SizedBox(height: 6),
            Text(
              'Create your startup to post internship opportunities. '
              'Admin verification is required before it appears to students.',
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}

class StartupProfileCard extends StatelessWidget {
  final Startup startup;
  final bool isOwner;

  const StartupProfileCard({
    super.key,
    required this.startup,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    final status = startup.verificationStatus;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.business_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(startup.startupName, style: AppTextStyles.heading2),
                      const SizedBox(height: 6),
                      Text(
                        startup.industry.isNotEmpty
                            ? startup.industry
                            : 'Industry not set',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge(status: status),
                if (startup.teamSize > 0)
                  AppChip(label: 'Team size: ${startup.teamSize}'),
                if (startup.website.isNotEmpty)
                  const AppChip(label: 'Website set'),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              startup.description.isNotEmpty
                  ? startup.description
                  : 'No description yet.',
              style: AppTextStyles.body,
            ),
            if (isOwner) ...[
              const SizedBox(height: 16),
              Text(
                'Ownership: you can edit these details anytime below.',
                style: AppTextStyles.body.copyWith(color: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

