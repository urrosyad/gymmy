import 'package:gymmy/features/gym_tenant/domain/entities/gym_tenant_entity.dart';
import 'package:gymmy/features/gym_tenant/domain/repositories/gym_tenant_repository.dart';

class GetOwnerGymUsecase {
  final GymTenantRepository _repository;

  GetOwnerGymUsecase(this._repository);

  Future<GymTenantEntity?> call(String ownerUid) =>
      _repository.fetchOwnerGym(ownerUid);
}
