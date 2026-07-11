import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/models/bookmark.dart';
import '../../data/bookmark_repository.dart';

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepository();
});

/// Maps opportunityId -> bookmarkId for the given student's saved
/// opportunities, so widgets can synchronously know whether an opportunity
/// is bookmarked and which document to delete when un-bookmarking.
final studentBookmarkMapProvider =
    StreamProvider.family<Map<String, String>, String>((ref, studentId) {
      return ref
          .watch(bookmarkRepositoryProvider)
          .watchBookmarksForStudent(studentId)
          .map(
            (bookmarks) => {
              for (final bookmark in bookmarks)
                bookmark.opportunityId: bookmark.id,
            },
          );
    });

class BookmarkState {
  final bool isLoading;
  final String? errorMessage;

  const BookmarkState({this.isLoading = false, this.errorMessage});

  BookmarkState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BookmarkState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class BookmarkController extends Notifier<BookmarkState> {
  @override
  BookmarkState build() => const BookmarkState();

  /// Toggles the bookmark for [opportunityId]. Pass the existing
  /// [existingBookmarkId] (looked up via [studentBookmarkMapProvider]) when
  /// the opportunity is already bookmarked, so it gets removed instead of
  /// creating a duplicate saved entry.
  Future<bool> toggleBookmark({
    required String studentId,
    required String opportunityId,
    String? existingBookmarkId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (existingBookmarkId != null) {
        await ref
            .read(bookmarkRepositoryProvider)
            .deleteBookmark(existingBookmarkId);
      } else {
        final bookmark = Bookmark(
          id: const Uuid().v4(),
          studentId: studentId,
          opportunityId: opportunityId,
          createdAt: DateTime.now(),
        );
        await ref.read(bookmarkRepositoryProvider).createBookmark(bookmark);
      }
      state = state.copyWith(isLoading: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to update bookmark.',
      );
      return false;
    }
  }

  Future<bool> removeBookmark(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(bookmarkRepositoryProvider).deleteBookmark(id);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to remove bookmark.',
      );
      return false;
    }
  }
}

final bookmarkControllerProvider =
    NotifierProvider<BookmarkController, BookmarkState>(BookmarkController.new);
