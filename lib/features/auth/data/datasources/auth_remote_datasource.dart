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

    // Only create user profile — gym setup handled by Owner Setup Wizard
    await _firestore
        .collection('user_accounts_global')
        .doc(uid)
        .set(model.toMap());

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
