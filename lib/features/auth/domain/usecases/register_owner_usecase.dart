import 'package:gymmy/features/auth/domain/entities/user_entity.dart';
import 'package:gymmy/features/auth/domain/repositories/auth_repository.dart';

class RegisterOwnerUsecase {
  final AuthRepository _repository;
  RegisterOwnerUsecase(this._repository);

  Future<UserEntity> call({
    required String fullName,
    required String email,
    required String password,
    required String gymName,
    required String gymAddress,
  }) {
    return _repository.registerOwner(
      fullName: fullName,
      email: email,
      password: password,
      gymName: gymName,
      gymAddress: gymAddress,
    );
  }
}
