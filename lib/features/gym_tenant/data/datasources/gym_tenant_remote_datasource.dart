import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymmy/features/gym_tenant/data/models/gym_tenant_model.dart';

class GymTenantRemoteDatasource {
  final FirebaseFirestore _firestore;

  GymTenantRemoteDatasource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  static const _collection = 'gym_tenants';

  Future<GymTenantModel?> fetchOwnerGym(String ownerUid) async {
    final query = await _firestore
        .collection(_collection)
        .where('gt_owner_uid', isEqualTo: ownerUid)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    return GymTenantModel.fromMap(doc.id, doc.data());
  }

  Stream<List<GymTenantModel>> streamAllGyms() {
    return _firestore
        .collection(_collection)
        .where('gt_is_active', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => GymTenantModel.fromMap(d.id, d.data()))
            .toList());
  }

  Future<GymTenantModel?> fetchGymById(String gymId) async {
    final doc = await _firestore.collection(_collection).doc(gymId).get();
    if (!doc.exists || doc.data() == null) return null;
    return GymTenantModel.fromMap(doc.id, doc.data()!);
  }

  Future<GymTenantModel> createGymTenant(GymTenantModel gym) async {
    final ref = _firestore.collection(_collection).doc();
    final withId = GymTenantModel(
      gtIdKey: ref.id,
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
    await ref.set(withId.toMap());
    return withId;
  }
}
