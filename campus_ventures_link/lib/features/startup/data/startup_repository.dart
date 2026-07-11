import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../shared/models/startup.dart';

class StartupRepository {
  final FirebaseFirestore _firestore;

  StartupRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _startups =>
      _firestore.collection(FirestoreConstants.startups);

  Stream<List<Startup>> watchStartups({String? ownerId}) {
    // Combining `where('ownerId', ...)` with `orderBy('createdAt', ...)`
    // requires a Firestore composite index that isn't provisioned in this
    // project. The admin listing (ownerId == null) only ever needs a
    // single-field sort, so it keeps the orderBy; the founder's own list
    // is realistically 0-1 documents, so it skips the sort entirely rather
    // than depending on an index that would need manual setup in the
    // Firebase console.
    if (ownerId != null) {
      return _startups.where('ownerId', isEqualTo: ownerId).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Startup.fromMap({...doc.data(), 'id': doc.id}))
            .toList(),
      );
    }
    return _startups
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Startup.fromMap({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  Future<void> createStartup(Startup startup) async {
    await _startups.doc(startup.id).set({
      ...startup.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStartup(String id, Map<String, dynamic> data) async {
    await _startups.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteStartup(String id) async {
    await _startups.doc(id).delete();
  }

  Future<Startup?> getStartupById(String id) async {
    final doc = await _startups.doc(id).get();
    if (!doc.exists) return null;
    return Startup.fromMap({...doc.data()!, 'id': doc.id});
  }

  Future<Startup?> getStartupByOwner(String ownerId) async {
    // No `orderBy` here for the same reason as `watchStartups` above —
    // avoids requiring a composite index for a query that only ever
    // expects to match one document per founder.
    final snapshot = await _startups
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return Startup.fromMap({
      ...snapshot.docs.first.data(),
      'id': snapshot.docs.first.id,
    });
  }
}
