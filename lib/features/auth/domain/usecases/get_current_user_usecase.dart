import 'package:gymmy/features/auth/domain/entities/user_entity.dart';
import 'package:gymmy/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUsecase {
  final AuthRepository _repository;
  GetCurrentUserUsecase(this._repository);

  Future<UserEntity?> call() => _repository.getCurrentUser();
}
