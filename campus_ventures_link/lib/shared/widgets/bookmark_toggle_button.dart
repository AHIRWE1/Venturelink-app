import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../features/bookmark/presentation/controllers/bookmark_controller.dart';

/// Single reusable bookmark toggle used on opportunity cards, the details
/// screen, and the bookmarks list. Reads [studentBookmarkMapProvider] to
/// know whether [opportunityId] is already saved and, if so, which
/// bookmark document to delete on tap (instead of creating a duplicate).
class BookmarkToggleButton extends ConsumerWidget {
  final String studentId;
  final String opportunityId;
  final Color? activeColor;
  final Color? inactiveColor;

  const BookmarkToggleButton({
    super.key,
    required this.studentId,
    required this.opportunityId,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkMap = ref.watch(studentBookmarkMapProvider(studentId));

    return bookmarkMap.when(
      data: (map) {
        final bookmarkId = map[opportunityId];
        final isSaved = bookmarkId != null;
        return IconButton(
          tooltip: isSaved ? 'Remove bookmark' : 'Save opportunity',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              key: ValueKey(isSaved),
              color: isSaved
                  ? (activeColor ?? AppColors.primary)
                  : (inactiveColor ?? AppColors.textSecondary),
            ),
          ),
          onPressed: () {
            ref
                .read(bookmarkControllerProvider.notifier)
                .toggleBookmark(
                  studentId: studentId,
                  opportunityId: opportunityId,
                  existingBookmarkId: bookmarkId,
                );
          },
        );
      },
      loading: () => IconButton(
        icon: Icon(
          Icons.bookmark_border,
          color: inactiveColor ?? AppColors.textSecondary,
        ),
        onPressed: null,
      ),
      error: (_, _) => IconButton(
        icon: Icon(
          Icons.bookmark_border,
          color: inactiveColor ?? AppColors.textSecondary,
        ),
        onPressed: null,
      ),
    );
  }
}
