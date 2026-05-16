import 'package:gymmy/features/gym_tenant/domain/entities/gym_tenant_entity.dart';
import 'package:gymmy/features/gym_tenant/domain/repositories/gym_tenant_repository.dart';

class CreateGymUsecase {
  final GymTenantRepository _repository;

  CreateGymUsecase(this._repository);

  Future<GymTenantEntity> call(GymTenantEntity gym) =>
      _repository.createGymTenant(gym);
}
