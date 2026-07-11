import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/app_user.dart';
import '../../../../shared/models/startup.dart';
import '../../../../shared/widgets/action_tile.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/gradient_header.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../opportunity/presentation/controllers/opportunity_controller.dart';
import '../../../startup/presentation/controllers/startup_controller.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(currentAppUserProvider).value;
    final startups = ref.watch(startupListProvider).value ?? const [];
    final opportunities = ref.watch(opportunitiesProvider).value ?? const [];
    final users = ref.watch(allUsersProvider).value ?? const [];

    final pending = startups
        .where((s) => s.verificationStatus.toLowerCase() == 'pending')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(startupListProvider);
          ref.invalidate(opportunitiesProvider);
          ref.invalidate(allUsersProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                title: 'Admin Panel',
                subtitle: 'Signed in as ${appUser?.email ?? 'admin'}',
                colors: const [Color(0xFF3F3585), AppColors.primary],
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
                    MetricCard.count(
                      icon: Icons.people_outline,
                      label: 'Users',
                      color: AppColors.primary,
                      count: users.length,
                    ),
                    MetricCard.count(
                      icon: Icons.business_outlined,
                      label: 'Startups',
                      color: AppColors.secondary,
                      count: startups.length,
                    ),
                    MetricCard.count(
                      icon: Icons.work_outline,
                      label: 'Opportunities',
                      color: AppColors.accent,
                      count: opportunities.length,
                    ),
                    MetricCard.count(
                      icon: Icons.hourglass_top_outlined,
                      label: 'Pending Approvals',
                      color: AppColors.warning,
                      count: pending.length,
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
                        icon: Icons.verified_outlined,
                        label: 'Verify Startups',
                        color: AppColors.primary,
                        axis: Axis.horizontal,
                        onTap: () => context.go(AppRoutes.adminVerify),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ActionTile(
                        icon: Icons.people_outline,
                        label: 'Manage Users',
                        color: AppColors.secondary,
                        axis: Axis.horizontal,
                        onTap: () => context.go(AppRoutes.adminUsers),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pending approvals',
                      style: AppTextStyles.heading2.copyWith(fontSize: 19),
                    ),
                    if (pending.isNotEmpty)
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.adminVerify),
                        child: Text(
                          'See all',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              sliver: SliverToBoxAdapter(
                child: pending.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.verified_outlined,
                        title: 'No startups awaiting review',
                        subtitle:
                            'All submitted startups have already been'
                            ' reviewed.',
                      )
                    : Column(
                        children: pending
                            .take(3)
                            .map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _PendingStartupTile(startup: s),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Users',
                      style: AppTextStyles.heading2.copyWith(fontSize: 19),
                    ),
                    if (users.isNotEmpty)
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.adminUsers),
                        child: Text(
                          'See all',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              sliver: SliverToBoxAdapter(
                child: users.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.people_outline,
                        title: 'No users yet',
                        subtitle: 'Registered users will appear here.',
                      )
                    : Column(
                        children: users
                            .take(3)
                            .map(
                              (u) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _UserTile(user: u),
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

class _PendingStartupTile extends StatelessWidget {
  final Startup startup;

  const _PendingStartupTile({required this.startup});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go(AppRoutes.adminVerify),
        child: Container(
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
                child: const Icon(
                  Icons.business_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  startup.startupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading2.copyWith(fontSize: 15),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: startup.verificationStatus),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AppUser user;

  const _UserTile({required this.user});

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
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.14),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.name.isNotEmpty ? user.name : user.email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading2.copyWith(fontSize: 15),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.role.isEmpty
                  ? 'unset'
                  : user.role[0].toUpperCase() + user.role.substring(1),
              style: const TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
