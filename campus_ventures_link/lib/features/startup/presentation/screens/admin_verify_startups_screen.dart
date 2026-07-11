import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/startup.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../controllers/startup_controller.dart';

const _statusFilters = ['All', 'pending', 'approved', 'rejected'];

class AdminVerifyStartupsScreen extends ConsumerStatefulWidget {
  const AdminVerifyStartupsScreen({super.key});

  @override
  ConsumerState<AdminVerifyStartupsScreen> createState() =>
      _AdminVerifyStartupsScreenState();
}

class _AdminVerifyStartupsScreenState
    extends ConsumerState<AdminVerifyStartupsScreen> {
  String _selectedStatus = 'pending';

  @override
  Widget build(BuildContext context) {
    final startupsAsync = ref.watch(startupListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Verify Startups')),
      body: startupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load startups: $error')),
        data: (startups) {
          final filtered = _selectedStatus == 'All'
              ? startups
              : startups
                    .where(
                      (s) =>
                          s.verificationStatus.toLowerCase() ==
                          _selectedStatus,
                    )
                    .toList();

          return Column(
            children: [
              SizedBox(
                height: 46,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: _statusFilters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final status = _statusFilters[index];
                    final isSelected = status == _selectedStatus;
                    final label = status == 'All'
                        ? 'All'
                        : status[0].toUpperCase() + status.substring(1);
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedStatus = status),
                      selectedColor: AppColors.primary.withValues(alpha: 0.18),
                      backgroundColor: AppColors.secondary.withValues(
                        alpha: 0.08,
                      ),
                      labelStyle: AppTextStyles.body.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.verified_outlined,
                        title: _selectedStatus == 'pending' || _selectedStatus == 'All'
                            ? 'No startups awaiting review'
                            : 'No $_selectedStatus startups',
                        subtitle:
                            'All submitted startups have already been reviewed.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _StartupReviewCard(startup: filtered[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StartupReviewCard extends ConsumerWidget {
  final Startup startup;

  const _StartupReviewCard({required this.startup});

  Future<void> _setStatus(
    BuildContext context,
    WidgetRef ref,
    String status,
  ) async {
    final success = await ref
        .read(startupControllerProvider.notifier)
        .updateVerificationStatus(id: startup.id, status: status);
    if (success && context.mounted) {
      final message = status == 'approved'
          ? 'Startup approved successfully.'
          : 'Startup rejected.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = startup.verificationStatus.toLowerCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                    Text(
                      startup.startupName,
                      style: AppTextStyles.heading2.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      startup.industry.isNotEmpty
                          ? startup.industry
                          : 'Industry not set',
                      style: AppTextStyles.body.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: startup.verificationStatus),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            startup.description.isNotEmpty
                ? startup.description
                : 'No description provided yet.',
            style: AppTextStyles.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (status != 'approved')
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _setStatus(context, ref, 'approved'),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Approve'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: BorderSide(
                        color: AppColors.success.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              if (status != 'approved' && status != 'rejected')
                const SizedBox(width: 10),
              if (status != 'rejected')
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _setStatus(context, ref, 'rejected'),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
