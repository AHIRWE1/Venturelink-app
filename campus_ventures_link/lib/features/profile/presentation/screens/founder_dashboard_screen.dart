import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/application.dart';
import '../../../../shared/models/opportunity.dart';
import '../../../../shared/widgets/action_tile.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/gradient_header.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../application/presentation/controllers/application_controller.dart';
import '../../../opportunity/presentation/controllers/opportunity_controller.dart';
import '../../../startup/presentation/controllers/startup_controller.dart';

class FounderDashboardScreen extends ConsumerWidget {
  const FounderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(currentAppUserProvider).value;

    if (appUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final startupAsync = ref.watch(startupByOwnerProvider(appUser.uid));
    final startup = startupAsync.value;

    final opportunities = startup == null
        ? const <Opportunity>[]
        : (ref.watch(opportunitiesProvider).value ?? const [])
              .where((o) => o.startupId == startup.id)
              .toList();
    final applicants = startup == null
        ? const <ApplicationModel>[]
        : ref.watch(startupApplicationsProvider(startup.id)).value ??
              const [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(opportunitiesProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                title: 'Welcome, ${appUser.name.isNotEmpty ? appUser.name : 'Founder'}',
                subtitle: 'Manage your startup, post roles, and review applicants.',
                colors: const [AppColors.secondary, AppColors.primary],
                trailing: IconButton(
                  tooltip: 'Logout',
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).logout(),
                  icon: const Icon(Icons.logout, color: Colors.white),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    MetricCard(
                      icon: Icons.business_outlined,
                      label: 'Startup',
                      color: AppColors.primary,
                      value: Text(
                        startup == null ? 'Not created' : startup.startupName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.heading2.copyWith(fontSize: 16),
                      ),
                    ),
                    MetricCard.count(
                      icon: Icons.work_outline,
                      label: 'Opportunities Posted',
                      color: AppColors.secondary,
                      count: opportunities.length,
                    ),
                    MetricCard.count(
                      icon: Icons.people_outline,
                      label: 'Applicants',
                      color: AppColors.accent,
                      count: applicants.length,
                    ),
                    MetricCard(
                      icon: Icons.verified_outlined,
                      label: 'Verification Status',
                      color: AppColors.warning,
                      value: startup == null
                          ? Text(
                              'N/A',
                              style: AppTextStyles.heading2.copyWith(
                                fontSize: 16,
                              ),
                            )
                          : StatusBadge(status: startup.verificationStatus),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Quick actions',
                  style: AppTextStyles.heading2.copyWith(fontSize: 19),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: ActionTile(
                        icon: Icons.add_circle_outline,
                        label: 'Create Opportunity',
                        color: AppColors.primary,
                        onTap: () =>
                            context.go(AppRoutes.founderCreateOpportunity),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ActionTile(
                        icon: Icons.people_outline,
                        label: 'View Applicants',
                        color: AppColors.secondary,
                        onTap: () => context.go(AppRoutes.founderApplicants),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ActionTile(
                        icon: Icons.business_outlined,
                        label: 'Manage Startup',
                        color: AppColors.accent,
                        onTap: () => context.go(AppRoutes.founderStartup),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (startup != null &&
                startup.verificationStatus.toLowerCase() != 'approved' &&
                startup.verificationStatus.toLowerCase() != 'active') ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.hourglass_top_outlined,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            startup.verificationStatus.toLowerCase() ==
                                    'rejected'
                                ? 'Your startup was rejected. Update your'
                                      ' profile and resubmit for review.'
                                : 'Your startup is pending ALU admin'
                                      ' verification. You can post'
                                      ' opportunities once approved.',
                            style: AppTextStyles.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Recent opportunities',
                  style: AppTextStyles.heading2.copyWith(fontSize: 19),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              sliver: SliverToBoxAdapter(
                child: opportunities.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.work_outline,
                        title: startup == null
                            ? 'No startup yet'
                            : "You haven't posted any opportunities yet",
                        subtitle: startup == null
                            ? 'Create your startup to start posting roles.'
                            : 'Your posted roles will show up here.',
                      )
                    : Column(
                        children: opportunities
                            .take(3)
                            .map(
                              (o) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _OpportunityTile(opportunity: o),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Recent applications',
                  style: AppTextStyles.heading2.copyWith(fontSize: 19),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              sliver: SliverToBoxAdapter(
                child: applicants.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.inbox_outlined,
                        title: 'No applications received yet',
                        subtitle: 'Applications from students will appear here.',
                      )
                    : Column(
                        children: applicants
                            .take(3)
                            .map(
                              (a) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ApplicationTile(application: a),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpportunityTile extends StatelessWidget {
  final Opportunity opportunity;

  const _OpportunityTile({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.work_outline, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              opportunity.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading2.copyWith(fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(status: opportunity.status),
        ],
      ),
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  final ApplicationModel application;

  const _ApplicationTile({required this.application});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Applicant ${application.studentId.substring(0, application.studentId.length < 6 ? application.studentId.length : 6)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading2.copyWith(fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(status: application.status),
        ],
      ),
    );
  }
}
