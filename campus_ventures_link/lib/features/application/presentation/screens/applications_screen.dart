import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/application.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../opportunity/presentation/controllers/opportunity_controller.dart';
import '../controllers/application_controller.dart';

const _statusFilters = ['All', 'pending', 'interview', 'accepted', 'rejected'];

class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() =>
      _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentAppUserProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final applications = ref.watch(studentApplicationsProvider(user.uid));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Applications')),
      body: applications.when(
        data: (items) {
          final filtered = _selectedStatus == 'All'
              ? items
              : items
                    .where((app) => app.status.toLowerCase() == _selectedStatus)
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
                    ? (items.isEmpty
                          ? EmptyStateWidget(
                              icon: Icons.assignment_outlined,
                              title:
                                  "You haven't applied for any opportunities"
                                  ' yet',
                              subtitle:
                                  'Explore internships and apply to gain'
                                  ' experience.',
                              buttonText: 'Explore Opportunities',
                              onPressed: () =>
                                  context.go(AppRoutes.studentExplore),
                            )
                          : const EmptyStateWidget(
                              icon: Icons.filter_alt_off_outlined,
                              title: 'No applications with this status',
                              subtitle:
                                  'Try a different filter to see more'
                                  ' applications.',
                            ))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) =>
                            _ApplicationCard(application: filtered[index]),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load applications: $error')),
      ),
    );
  }
}

class _ApplicationCard extends ConsumerWidget {
  final ApplicationModel application;
  const _ApplicationCard({required this.application});

  Future<void> _confirmWithdraw(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw application?'),
        content: const Text(
          'This will remove your application. You can re-apply later if the '
          'opportunity is still open.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(applicationControllerProvider.notifier)
        .withdraw(application.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Application withdrawn')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunityAsync = ref.watch(
      opportunityByIdProvider(application.opportunityId),
    );
    final opportunity = opportunityAsync.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
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
              Icons.assignment_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opportunity?.title ?? 'Opportunity unavailable',
                  style: AppTextStyles.heading2.copyWith(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    StatusBadge(status: application.status),
                    const SizedBox(width: 8),
                    if (application.createdAt != null)
                      Expanded(
                        child: Text(
                          'Applied ${_fmtDate(application.createdAt!)}',
                          style: AppTextStyles.body.copyWith(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Withdraw application',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmWithdraw(context, ref),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
