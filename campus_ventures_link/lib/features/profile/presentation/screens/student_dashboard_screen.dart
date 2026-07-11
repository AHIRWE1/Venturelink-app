import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/presentation/controllers/application_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../bookmark/presentation/controllers/bookmark_controller.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/opportunity.dart';
import '../../../../shared/widgets/category_card.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/gradient_header.dart';
import '../../../../shared/widgets/opportunity_card.dart';
import '../../../../shared/widgets/search_bar_widget.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../opportunity/domain/opportunity_matching.dart';
import '../../../opportunity/presentation/controllers/opportunity_controller.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(currentAppUserProvider).value;
    final opportunitiesAsync = ref.watch(opportunitiesProvider);

    if (appUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final firstName = appUser.name.trim().isEmpty
        ? 'there'
        : appUser.name.trim().split(' ').first;

    final applicationsCount =
        ref.watch(studentApplicationsProvider(appUser.uid)).value?.length ??
        0;
    final savedCount =
        ref.watch(studentBookmarkMapProvider(appUser.uid)).value?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(opportunitiesProvider),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                title: 'Hello, $firstName \u{1F44B}',
                subtitle: 'Find meaningful ways to contribute.',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Notifications',
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Notifications'),
                            content: const Text('No new notifications yet.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.studentProfile),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white.withValues(alpha: 0.22),
                        child: Text(
                          firstName.isNotEmpty
                              ? firstName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                bottom: Row(
                  children: [
                    _StatChip(
                      icon: Icons.assignment_outlined,
                      value: applicationsCount,
                      label: 'Applications',
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: Icons.bookmark_outline,
                      value: savedCount,
                      label: 'Saved',
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverToBoxAdapter(
                child: SearchBarWidget(
                  hint: 'Search opportunities...',
                  readOnly: true,
                  onTap: () => context.go(AppRoutes.studentExplore),
                ),
              ),
            ),
            opportunitiesAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Unable to load opportunities: $error',
                    style: AppTextStyles.body,
                  ),
                ),
              ),
              data: (all) {
                final opportunities = all
                    .where((o) => o.title.trim().isNotEmpty)
                    .toList();
                final categories = <String>{};
                for (final o in opportunities) {
                  if (o.category.trim().isNotEmpty) {
                    categories.add(o.category.trim());
                  }
                }
                final recommended = getRecommendedOpportunities(
                  opportunities,
                  appUser.skills,
                );
                final recent = getRecentOpportunities(opportunities, limit: 5);

                return SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeader(
                        title: 'Recommended',
                        actionLabel: 'See all',
                        accentColor: AppColors.primary,
                        onAction: () => context.go(AppRoutes.studentExplore),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _RecommendedCarousel(
                      opportunities: recommended,
                      studentId: appUser.uid,
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeader(
                        title: 'Browse by category',
                        accentColor: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _CategoryRow(categories: categories.toList()..sort()),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeader(
                        title: 'Recent opportunities',
                        actionLabel: 'See all',
                        accentColor: AppColors.secondary,
                        onAction: () => context.go(AppRoutes.studentExplore),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (recent.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: EmptyStateWidget(
                          icon: Icons.work_outline,
                          title: 'No opportunities available',
                          subtitle: 'Check back later for new opportunities.',
                        ),
                      )
                    else
                      ...recent.map(
                        (opportunity) => Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: OpportunityCard(
                            opportunity: opportunity,
                            studentId: appUser.uid,
                          ),
                        ),
                      ),
                    const SizedBox(height: 28),
                  ]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedCarousel extends StatelessWidget {
  final List<Opportunity> opportunities;
  final String studentId;

  const _RecommendedCarousel({
    required this.opportunities,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    if (opportunities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Add skills to your profile to get personalized recommendations.',
            style: AppTextStyles.body,
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: opportunities.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) => SizedBox(
          width: 240,
          child: OpportunityCard(
            opportunity: opportunities[index],
            studentId: studentId,
            featured: true,
          ),
        ),
      ),
    );
  }
}

class _CategoryRow extends ConsumerWidget {
  final List<String> categories;

  const _CategoryRow({required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryCard(
            icon: categoryIcon(category),
            label: category,
            onTap: () {
              ref.read(exploreInitialCategoryProvider.notifier).state =
                  category;
              context.go(AppRoutes.studentExplore);
            },
          );
        },
      ),
    );
  }
}
