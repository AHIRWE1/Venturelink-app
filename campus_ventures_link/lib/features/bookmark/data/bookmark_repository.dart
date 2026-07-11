import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../shared/models/bookmark.dart';

class BookmarkRepository {
  final FirebaseFirestore _firestore;

  BookmarkRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _bookmarks =>
      _firestore.collection(FirestoreConstants.bookmarks);

  // Sorted client-side — see the matching comment in
  // application_repository.dart for why `.orderBy` isn't chained here.
  Stream<List<Bookmark>> watchBookmarksForStudent(String studentId) {
    return _bookmarks.where('studentId', isEqualTo: studentId).snapshots().map(
      (snapshot) {
        final items = snapshot.docs
            .map((doc) => Bookmark.fromMap({...doc.data(), 'id': doc.id}))
            .toList();
        items.sort(
          (a, b) =>
              (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
        );
        return items;
      },
    );
  }

  Future<void> createBookmark(Bookmark bookmark) async {
    await _bookmarks.doc(bookmark.id).set({
      ...bookmark.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteBookmark(String id) async {
    await _bookmarks.doc(id).delete();
  }
}
