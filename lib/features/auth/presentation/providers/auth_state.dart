import 'package:gymmy/features/auth/domain/entities/user_entity.dart';

enum AuthStatus {
  initial,
  checkingSession,
  authenticating,
  authenticated,
  unauthenticated,
  error
}

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? emailError;
  final String? passwordError;
  final String? generalError;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.emailError,
    this.passwordError,
    this.generalError,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? emailError,
    String? passwordError,
    String? generalError,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      emailError: emailError,
      passwordError: passwordError,
      generalError: generalError,
    );
  }

  bool get isLoading =>
      status == AuthStatus.checkingSession ||
      status == AuthStatus.authenticating;
  bool get isAuthenticated => status == AuthStatus.authenticated;
}
