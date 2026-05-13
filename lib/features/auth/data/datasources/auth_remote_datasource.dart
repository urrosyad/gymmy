import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymmy/features/auth/data/models/user_model.dart';

/// Handles all Firebase Auth and Firestore calls for authentication.
class AuthRemoteDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDatasource({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  // -------------------------------------------------------------------------
  // Login
  // -------------------------------------------------------------------------
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;
    return _fetchUserModel(uid);
  }

  // -------------------------------------------------------------------------
  // Register Member
  // -------------------------------------------------------------------------
  Future<UserModel> registerMember({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;

    final model = UserModel(
      uid: uid,
      fullName: fullName.trim(),
      email: email.trim(),
      role: 'member',
    );

    await _firestore
        .collection('user_accounts_global')
        .doc(uid)
        .set(model.toMap());

    return model;
  }

  // -------------------------------------------------------------------------
  // Register Owner
  // -------------------------------------------------------------------------
  Future<UserModel> registerOwner({
    required String fullName,
    required String email,
    required String password,
    required String gymName,
    required String gymAddress,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;

    final model = UserModel(
      uid: uid,
      fullName: fullName.trim(),
      email: email.trim(),
      role: 'owner',
    );

    // Batch write: user profile + gym tenant + default ranks
    final batch = _firestore.batch();

    // 1. Global user profile
    final userRef =
        _firestore.collection('user_accounts_global').doc(uid);
    batch.set(userRef, model.toMap());

    // 2. Gym tenant document
    final gymRef = _firestore.collection('gym_tenants').doc();
    final gymId = gymRef.id;
    batch.set(gymRef, {
      'gt_id_key': gymId,
      'gt_name_title': gymName.trim(),
      'gt_address_location': gymAddress.trim(),
      'gt_owner_uid': uid,
      'gt_business_license_number': '',
      'gt_created_at': FieldValue.serverTimestamp(),
    });

    // 3. Default ranks
    final ranks = [
      {'rank_title_name': 'Bronze', 'rank_min_points_threshold': 0},
      {'rank_title_name': 'Silver', 'rank_min_points_threshold': 500},
      {'rank_title_name': 'Gold', 'rank_min_points_threshold': 1500},
    ];
    for (final rank in ranks) {
      final rankRef = _firestore.collection('gym_master_ranks').doc();
      batch.set(rankRef, {
        'rank_id_key': rankRef.id,
        'rank_parent_gym_id': gymId,
        ...rank,
      });
    }

    await batch.commit();
    return model;
  }

  // -------------------------------------------------------------------------
  // Logout
  // -------------------------------------------------------------------------
  Future<void> logout() => _auth.signOut();

  // -------------------------------------------------------------------------
  // Get current user
  // -------------------------------------------------------------------------
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _fetchUserModel(firebaseUser.uid);
  }

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------
  Future<UserModel> _fetchUserModel(String uid) async {
    final doc = await _firestore
        .collection('user_accounts_global')
        .doc(uid)
        .get();
    if (!doc.exists) {
      throw Exception('User profile not found. Please contact support.');
    }
    return UserModel.fromMap(uid, doc.data()!);
  }
}
