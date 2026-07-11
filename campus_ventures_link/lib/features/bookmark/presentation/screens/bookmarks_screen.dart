import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/bookmark.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/opportunity_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../opportunity/presentation/controllers/opportunity_controller.dart';
import '../controllers/bookmark_controller.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  bool _isGrid = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentAppUserProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bookmarks = ref.watch(
      StreamProvider.autoDispose.family<List<Bookmark>, String>((
        ref,
        studentId,
      ) {
        return ref
            .read(bookmarkRepositoryProvider)
            .watchBookmarksForStudent(studentId);
      })(user.uid),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved Opportunities'),
        actions: [
          IconButton(
            tooltip: _isGrid ? 'Switch to list view' : 'Switch to grid view',
            icon: Icon(_isGrid ? Icons.view_list_outlined : Icons.grid_view_outlined),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
        ],
      ),
      body: bookmarks.when(
        data: (items) {
          if (items.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.bookmark_border,
              title: 'No saved opportunities',
              subtitle: 'Bookmark opportunities to access them later.',
              buttonText: 'Browse Opportunities',
              onPressed: () => context.go(AppRoutes.studentExplore),
            );
          }

          if (_isGrid) {
            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.78,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final opportunityAsync = ref.watch(
                  opportunityByIdProvider(items[index].opportunityId),
                );
                final opportunity = opportunityAsync.value;
                if (opportunity == null) return const SizedBox.shrink();
                return OpportunityCard(
                  opportunity: opportunity,
                  studentId: user.uid,
                  featured: true,
                );
              },
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final opportunityAsync = ref.watch(
                opportunityByIdProvider(items[index].opportunityId),
              );
              final opportunity = opportunityAsync.value;
              if (opportunity == null) {
                return const SizedBox.shrink();
              }
              return OpportunityCard(
                opportunity: opportunity,
                studentId: user.uid,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load bookmarks: $error')),
      ),
    );
  }
}
