import 'package:gymmy/features/auth/domain/entities/user_entity.dart';
import 'package:gymmy/features/auth/domain/repositories/auth_repository.dart';

class RegisterMemberUsecase {
  final AuthRepository _repository;
  RegisterMemberUsecase(this._repository);

  Future<UserEntity> call({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _repository.registerMember(
      fullName: fullName,
      email: email,
      password: password,
    );
  }
}
