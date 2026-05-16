import 'package:gymmy/features/gym_tenant/data/datasources/gym_tenant_remote_datasource.dart';
import 'package:gymmy/features/gym_tenant/data/models/gym_tenant_model.dart';
import 'package:gymmy/features/gym_tenant/domain/entities/gym_tenant_entity.dart';
import 'package:gymmy/features/gym_tenant/domain/repositories/gym_tenant_repository.dart';

class GymTenantRepositoryImpl implements GymTenantRepository {
  final GymTenantRemoteDatasource _datasource;

  GymTenantRepositoryImpl(this._datasource);

  @override
  Future<GymTenantEntity?> fetchOwnerGym(String ownerUid) =>
      _datasource.fetchOwnerGym(ownerUid);

  @override
  Stream<List<GymTenantEntity>> streamAllGyms() =>
      _datasource.streamAllGyms();

  @override
  Future<GymTenantEntity?> fetchGymById(String gymId) =>
      _datasource.fetchGymById(gymId);

  @override
  Future<GymTenantEntity> createGymTenant(GymTenantEntity gym) {
    // Convert entity to model for datasource
    final model = GymTenantModel(
      gtIdKey: gym.gtIdKey,
      gtNameTitle: gym.gtNameTitle,
      gtImage: gym.gtImage,
      gtLocation: gym.gtLocation,
      gtCityName: gym.gtCityName,
      gtRate: gym.gtRate,
      gtOwnerUid: gym.gtOwnerUid,
      gtDescriptionText: gym.gtDescriptionText,
      gtDailyPriceAmount: gym.gtDailyPriceAmount,
      gtMembershipPriceAmount: gym.gtMembershipPriceAmount,
      gtAvailableFacilities: gym.gtAvailableFacilities,
      gtIsActive: gym.gtIsActive,
      gtOperationalHours: gym.gtOperationalHours,
    );
    return _datasource.createGymTenant(model);
  }
}
