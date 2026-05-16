import 'package:gymmy/features/gym_tenant/domain/entities/gym_tenant_entity.dart';
import 'package:gymmy/features/gym_tenant/domain/repositories/gym_tenant_repository.dart';

class GetAllGymsUsecase {
  final GymTenantRepository _repository;

  GetAllGymsUsecase(this._repository);

  Stream<List<GymTenantEntity>> call() => _repository.streamAllGyms();
}
