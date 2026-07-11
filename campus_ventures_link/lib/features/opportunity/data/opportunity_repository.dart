import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../shared/models/opportunity.dart';

class OpportunityRepository {
  final FirebaseFirestore _firestore;

  OpportunityRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _opportunities =>
      _firestore.collection(FirestoreConstants.opportunities);

  Stream<List<Opportunity>> watchAllOpportunities() {
    return _opportunities
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Opportunity.fromMap({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  // Sorted client-side — see the matching comment in
  // application_repository.dart for why `.orderBy` isn't chained here.
  Stream<List<Opportunity>> watchOpportunitiesForStartup(String startupId) {
    return _opportunities.where('startupId', isEqualTo: startupId).snapshots().map(
      (snapshot) {
        final items = snapshot.docs
            .map((doc) => Opportunity.fromMap({...doc.data(), 'id': doc.id}))
            .toList();
        items.sort(
          (a, b) =>
              (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
        );
        return items;
      },
    );
  }

  Future<void> createOpportunity(Opportunity opportunity) async {
    await _opportunities.doc(opportunity.id).set({
      ...opportunity.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateOpportunity(String id, Map<String, dynamic> data) async {
    await _opportunities.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteOpportunity(String id) async {
    await _opportunities.doc(id).delete();
  }

  Future<Opportunity?> getOpportunityById(String id) async {
    final doc = await _opportunities.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Opportunity.fromMap({...doc.data()!, 'id': doc.id});
  }
}
