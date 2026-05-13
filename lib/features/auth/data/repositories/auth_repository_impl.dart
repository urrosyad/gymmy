import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymmy/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:gymmy/features/auth/domain/entities/user_entity.dart';
import 'package:gymmy/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _datasource.login(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  @override
  Future<UserEntity> registerMember({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      return await _datasource.registerMember(
        fullName: fullName,
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  @override
  Future<UserEntity> registerOwner({
    required String fullName,
    required String email,
    required String password,
    required String gymName,
    required String gymAddress,
  }) async {
    try {
      return await _datasource.registerOwner(
        fullName: fullName,
        email: email,
        password: password,
        gymName: gymName,
        gymAddress: gymAddress,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  @override
  Future<void> logout() => _datasource.logout();

  @override
  Future<UserEntity?> getCurrentUser() => _datasource.getCurrentUser();

  // ---------------------------------------------------------------------------
  // Error mapping
  // ---------------------------------------------------------------------------
  Exception _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return Exception('Email address is not valid.');
      case 'weak-password':
        return Exception('Password must be at least 6 characters.');
      case 'email-already-in-use':
        return Exception('An account already exists with this email.');
      case 'wrong-password':
      case 'invalid-credential':
        return Exception('Incorrect email or password.');
      case 'user-not-found':
        return Exception('No account found with this email.');
      case 'network-request-failed':
        return Exception('Check your internet connection and try again.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please wait and try again.');
      default:
        return Exception(e.message ?? 'An unexpected error occurred.');
    }
  }
}
