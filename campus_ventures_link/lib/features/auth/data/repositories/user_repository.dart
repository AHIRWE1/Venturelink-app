import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../shared/models/app_user.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreConstants.users);

  Future<void> createUser(AppUser user) async {
    await _users.doc(user.uid).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return AppUser.fromMap(doc.data()!);
  }

  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return AppUser.fromMap(doc.data()!);
    });
  }

  Stream<List<AppUser>> watchAllUsers() {
    return _users.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => AppUser.fromMap(doc.data())).toList(),
    );
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  Future<void> completeOnboarding({
    required String uid,
    required String name,
    required String role,
    required List<String> skills,
    required String bio,
    String? githubUrl,
    String? linkedinUrl,
    String? websiteUrl,
  }) async {
    await _users.doc(uid).update({
      'name': name,
      'role': role,
      'skills': skills,
      'bio': bio,
      'githubUrl': githubUrl,
      'linkedinUrl': linkedinUrl,
      'websiteUrl': websiteUrl,
      'cvUrl': githubUrl ?? websiteUrl,
      'onboardingCompleted': true,
    });
  }
}
