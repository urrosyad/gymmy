import 'package:gymmy/features/gym_tenant/domain/entities/gym_tenant_entity.dart';

abstract class GymTenantRepository {
  /// Returns the gym owned by [ownerUid], or null if none exists.
  Future<GymTenantEntity?> fetchOwnerGym(String ownerUid);

  /// Stream of all active gyms for discovery.
  Stream<List<GymTenantEntity>> streamAllGyms();

  /// Fetch a single gym by its ID.
  Future<GymTenantEntity?> fetchGymById(String gymId);

  /// Create a new gym tenant document. Returns the created entity.
  Future<GymTenantEntity> createGymTenant(GymTenantEntity gym);
}
