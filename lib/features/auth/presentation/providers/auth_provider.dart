import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/di/injection.dart';
import 'package:gymmy/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:gymmy/features/auth/domain/usecases/login_usecase.dart';
import 'package:gymmy/features/auth/domain/usecases/logout_usecase.dart';
import 'package:gymmy/features/auth/domain/usecases/register_member_usecase.dart';
import 'package:gymmy/features/auth/domain/usecases/register_owner_usecase.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  late final LoginUsecase _loginUsecase;
  late final RegisterMemberUsecase _registerMemberUsecase;
  late final RegisterOwnerUsecase _registerOwnerUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;

  @override
  AuthState build() {
    _loginUsecase = sl<LoginUsecase>();
    _registerMemberUsecase = sl<RegisterMemberUsecase>();
    _registerOwnerUsecase = sl<RegisterOwnerUsecase>();
    _logoutUsecase = sl<LogoutUsecase>();
    _getCurrentUserUsecase = sl<GetCurrentUserUsecase>();

    // Check session asynchronously after build
    Future.microtask(_checkSession);

    return const AuthState();
  }

  // ---------------------------------------------------------------------------
  // Session check on startup
  // ---------------------------------------------------------------------------
  Future<void> _checkSession() async {
    state = state.copyWith(status: AuthStatus.checkingSession);
    try {
      final user = await _getCurrentUserUsecase();
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final user = await _loginUsecase(email: email, password: password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      _handleError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Register member
  // ---------------------------------------------------------------------------
  Future<void> registerMember({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final user = await _registerMemberUsecase(
        fullName: fullName,
        email: email,
        password: password,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      _handleError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Register owner
  // ---------------------------------------------------------------------------
  Future<void> registerOwner({
    required String fullName,
    required String email,
    required String password,
    required String gymName,
    required String gymAddress,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final user = await _registerOwnerUsecase(
        fullName: fullName,
        email: email,
        password: password,
        gymName: gymName,
        gymAddress: gymAddress,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      _handleError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Error handling
  // ---------------------------------------------------------------------------
  void _handleError(Object error) {
    String msg = error.toString();
    
    // We try to extract Firebase exception codes from the message
    // Usually it looks like [firebase_auth/wrong-password] ...
    
    if (msg.contains('invalid-email')) {
      state = state.copyWith(status: AuthStatus.error, emailError: 'Invalid email address');
    } else if (msg.contains('user-not-found')) {
      state = state.copyWith(status: AuthStatus.error, emailError: 'Account not found');
    } else if (msg.contains('email-already-in-use')) {
      state = state.copyWith(status: AuthStatus.error, emailError: 'Email already registered');
    } else if (msg.contains('wrong-password') || msg.contains('INVALID_LOGIN_CREDENTIALS')) {
      state = state.copyWith(status: AuthStatus.error, passwordError: 'Incorrect password');
    } else if (msg.contains('weak-password')) {
      state = state.copyWith(status: AuthStatus.error, passwordError: 'Password too weak');
    } else if (msg.contains('network-request-failed')) {
      state = state.copyWith(status: AuthStatus.error, generalError: 'Network connection failed');
    } else {
      // Clean up "Exception: " if present
      state = state.copyWith(
        status: AuthStatus.error,
        generalError: msg.replaceFirst('Exception: ', ''),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    await _logoutUsecase();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    if (state.status == AuthStatus.error) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider (Riverpod 3.x API)
// ---------------------------------------------------------------------------
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
