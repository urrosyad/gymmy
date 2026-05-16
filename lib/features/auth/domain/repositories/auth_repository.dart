import 'package:gymmy/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Login with email and password. Returns [UserEntity] on success.
  Future<UserEntity> login({
    required String email,
    required String password,
  });

  /// Register a new member account.
  Future<UserEntity> registerMember({
    required String fullName,
    required String email,
    required String password,
  });

  /// Register a new gym owner. Gym setup is done separately via wizard.
  Future<UserEntity> registerOwner({
    required String fullName,
    required String email,
    required String password,
  });

  /// Sign out the currently authenticated user.
  Future<void> logout();

  /// Fetch the [UserEntity] for the currently authenticated Firebase user.
  /// Returns null if no user is signed in or the profile document doesn't exist.
  Future<UserEntity?> getCurrentUser();
}
