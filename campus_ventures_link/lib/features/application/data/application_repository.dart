import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../shared/models/application.dart';

class ApplicationRepository {
  final FirebaseFirestore _firestore;

  ApplicationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection(FirestoreConstants.applications);

  // Sorted client-side rather than via `.orderBy('createdAt')` chained onto
  // the `.where(...)` filter below — that combination requires a Firestore
  // composite index per field that isn't provisioned in this project, and
  // these collections are small enough per-user that an in-memory sort is
  // negligible.
  Stream<List<ApplicationModel>> watchApplicationsForStudent(String studentId) {
    return _applications.where('studentId', isEqualTo: studentId).snapshots().map(
      (snapshot) => _sortedByCreatedAt(
        snapshot.docs
            .map(
              (doc) =>
                  ApplicationModel.fromMap({...doc.data(), 'id': doc.id}),
            )
            .toList(),
      ),
    );
  }

  Stream<List<ApplicationModel>> watchApplicationsForStartup(String startupId) {
    return _applications.where('startupId', isEqualTo: startupId).snapshots().map(
      (snapshot) => _sortedByCreatedAt(
        snapshot.docs
            .map(
              (doc) =>
                  ApplicationModel.fromMap({...doc.data(), 'id': doc.id}),
            )
            .toList(),
      ),
    );
  }

  List<ApplicationModel> _sortedByCreatedAt(List<ApplicationModel> items) {
    items.sort(
      (a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );
    return items;
  }

  Future<void> createApplication(ApplicationModel application) async {
    await _applications.doc(application.id).set({
      ...application.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateApplication(String id, Map<String, dynamic> data) async {
    await _applications.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteApplication(String id) async {
    await _applications.doc(id).delete();
  }
}
