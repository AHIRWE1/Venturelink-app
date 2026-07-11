import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/opportunity_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/opportunity_matching.dart';
import '../controllers/opportunity_controller.dart';

class ExploreOpportunitiesScreen extends ConsumerWidget {
  const ExploreOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(currentAppUserProvider).value;

    if (appUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Opportunities'),
        actions: [
          if (appUser.role == UserRoles.founder)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Create Opportunity',
              onPressed: () => context.go(AppRoutes.founderCreateOpportunity),
            ),
        ],
      ),
      body: _ExploreBody(
        userSkills: appUser.skills,
        userRole: appUser.role,
        studentId: appUser.uid,
      ),
    );
  }
}

class _ExploreBody extends ConsumerStatefulWidget {
  final List<String> userSkills;
  final String userRole;
  final String studentId;

  const _ExploreBody({
    required this.userSkills,
    required this.userRole,
    required this.studentId,
  });

  @override
  ConsumerState<_ExploreBody> createState() => _ExploreBodyState();
}

class _ExploreBodyState extends ConsumerState<_ExploreBody> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialQuery = ref.read(exploreInitialQueryProvider);
      final initialCategory = ref.read(exploreInitialCategoryProvider);
      if (initialQuery != null || initialCategory != null) {
        setState(() {
          if (initialQuery != null) _searchController.text = initialQuery;
          if (initialCategory != null) _selectedCategory = initialCategory;
        });
        ref.read(exploreInitialQueryProvider.notifier).state = null;
        ref.read(exploreInitialCategoryProvider.notifier).state = null;
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final opportunitiesAsync = ref.watch(opportunitiesProvider);

    return opportunitiesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
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
            .where((opportunity) => opportunity.title.trim().isNotEmpty)
            .toList();
        final categories = <String>{'All'};
        for (final opportunity in opportunities) {
          if (opportunity.category.trim().isNotEmpty) {
            categories.add(opportunity.category.trim());
          }
        }
        final sortedCategories = categories.toList()..sort();

        final filtered = applyOpportunityFilters(
          opportunities,
          query: _searchController.text,
          selectedCategory: _selectedCategory,
        );
        final recommended = getRecommendedOpportunities(
          filtered,
          widget.userSkills,
        );
        final recent = getRecentOpportunities(filtered);

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(opportunitiesProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discover ALU startup roles',
                        style: AppTextStyles.heading1,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Search opportunities that match your skills and interests.',
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: 18),
                      _SearchBar(
                        controller: _searchController,
                        onChanged: () {},
                      ),
                      const SizedBox(height: 14),
                      Container(
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
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${filtered.length} opportunities',
                                    style: AppTextStyles.heading2.copyWith(
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Matched by your search and selected category.',
                                    style: AppTextStyles.body,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                '${recommended.length} matches',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 46,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: sortedCategories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = sortedCategories[index];
                            final isSelected = category == _selectedCategory;
                            return ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (_) => setState(() {
                                _selectedCategory = category;
                              }),
                              selectedColor: AppColors.primary.withValues(
                                alpha: 0.18,
                              ),
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
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recommended for you',
                        style: AppTextStyles.heading2,
                      ),
                      Text(
                        '${recommended.length} matches',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: recommended.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: EmptyStateWidget(
                          icon: Icons.auto_awesome_outlined,
                          title: 'No recommendations yet',
                          subtitle: 'Add more skills to get better matches.',
                        ),
                      )
                    : SizedBox(
                        height: 220,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                          scrollDirection: Axis.horizontal,
                          itemCount: recommended.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: 240,
                              child: OpportunityCard(
                                opportunity: recommended[index],
                                studentId: widget.studentId,
                                featured: true,
                              ),
                            );
                          },
                        ),
                      ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Recent opportunities',
                    style: AppTextStyles.heading2,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: recent.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: EmptyStateWidget(
                            icon: Icons.work_outline,
                            title: 'No recent opportunities',
                            subtitle: 'Try another keyword or category.',
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: EdgeInsets.only(
                              bottom: index == recent.length - 1 ? 16 : 12,
                            ),
                            child: OpportunityCard(
                              opportunity: recent[index],
                              studentId: widget.studentId,
                            ),
                          ),
                          childCount: recent.length,
                        ),
                      ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Browse all', style: AppTextStyles.heading2),
                      Text(
                        '${filtered.length} results',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                sliver: filtered.isEmpty
                    ? SliverToBoxAdapter(
                        child: opportunities.isEmpty
                            ? (widget.userRole == UserRoles.founder
                                  ? EmptyStateWidget(
                                      icon: Icons.work_outline,
                                      title:
                                          "You haven't posted any"
                                          ' opportunities yet',
                                      subtitle:
                                          'Create your first internship'
                                          ' opportunity.',
                                      buttonText: 'Create Opportunity',
                                      onPressed: () => context.go(
                                        AppRoutes.founderCreateOpportunity,
                                      ),
                                    )
                                  : const EmptyStateWidget(
                                      icon: Icons.work_outline,
                                      title: 'No opportunities available',
                                      subtitle:
                                          'Check back later for new'
                                          ' opportunities.',
                                    ))
                            : const EmptyStateWidget(
                                icon: Icons.search_off_outlined,
                                title: 'No opportunities found',
                                subtitle:
                                    'Try changing your search or filters.',
                              ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: EdgeInsets.only(
                              bottom: index == filtered.length - 1 ? 0 : 10,
                            ),
                            child: OpportunityCard(
                              opportunity: filtered[index],
                              studentId: widget.studentId,
                            ),
                          ),
                          childCount: filtered.length,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_outlined),
        hintText: 'Search by title, category, skills…',
        filled: true,
        fillColor: AppColors.secondary.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
