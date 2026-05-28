import 'package:cloud_firestore/cloud_firestore.dart';

class OwnerDataRepository {
  final FirebaseFirestore _firestore;

  OwnerDataRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // ===========================================================================
  // GYM TENANT UPDATE
  // ===========================================================================

  Future<void> updateGymPrices({
    required String gymId,
    required double dailyPrice,
    required double membershipPrice,
  }) async {
    await _firestore.collection('gym_tenants').doc(gymId).update({
      'gt_daily_price_amount': dailyPrice,
      'gt_membership_price_amount': membershipPrice,
    });
  }

  Future<void> updateGymProfile({
    required String gymId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection('gym_tenants').doc(gymId).update(data);
  }

  // ===========================================================================
  // EQUIPMENT CRUD
  // ===========================================================================

  Stream<List<Map<String, dynamic>>> streamEquipments(String gymId) {
    return _firestore
        .collection('gym_equipments')
        .where('equip_parent_gym_id', isEqualTo: gymId)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['equip_id_key'] = d.id;
              return data;
            }).toList());
  }

  Future<void> createEquipment({
    required String gymId,
    required String name,
    String imageUrl = '',
    String instruction = '',
    String tutorialLink = '',
    String category = 'umum',
  }) async {
    final ref = _firestore.collection('gym_equipments').doc();
    await ref.set({
      'equip_id_key': ref.id,
      'equip_parent_gym_id': gymId,
      'equip_name_label': name,
      'equip_image_storage_url': imageUrl,
      'equip_usage_instruction_text': instruction,
      'equip_tutorial_video_link': tutorialLink,
      'equip_is_active_status': true,
      'equip_created_at': FieldValue.serverTimestamp(),
      'equip_last_updated_at': FieldValue.serverTimestamp(),
      'equip_category_type': category,
      'equip_total_usage_count': 0,
    });
  }

  Future<void> updateEquipment({
    required String equipId,
    required Map<String, dynamic> data,
  }) async {
    data['equip_last_updated_at'] = FieldValue.serverTimestamp();
    await _firestore.collection('gym_equipments').doc(equipId).update(data);
  }

  Future<void> deleteEquipment(String equipId) async {
    await _firestore.collection('gym_equipments').doc(equipId).delete();
  }

  // ===========================================================================
  // CLASSES CRUD
  // ===========================================================================

  Stream<List<Map<String, dynamic>>> streamClasses(String gymId) {
    return _firestore
        .collection('gym_classes_catalog')
        .where('class_parent_gym_id', isEqualTo: gymId)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['class_id_key'] = d.id;
              return data;
            }).toList());
  }

  Future<void> createClass({
    required String gymId,
    required String title,
    required double price,
    required String schedule,
    required int sessionCount,
    String description = '',
    int maxCapacity = 20,
    bool isPersonalTrainer = false,
  }) async {
    final ref = _firestore.collection('gym_classes_catalog').doc();
    await ref.set({
      'class_id_key': ref.id,
      'class_parent_gym_id': gymId,
      'class_title_name': title,
      'class_pricing_amount': price,
      'class_schedule_text': schedule,
      'class_session_count': sessionCount,
      'class_is_personal_trainer': isPersonalTrainer,
      'class_description_text': description,
      'class_thumbnail_image_url': '',
      'class_max_capacity': maxCapacity,
      'class_current_subscribers': 0,
      'class_is_active': true,
    });
  }

  Future<void> updateClass({
    required String classId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection('gym_classes_catalog').doc(classId).update(data);
  }

  Future<void> deleteClass(String classId) async {
    await _firestore.collection('gym_classes_catalog').doc(classId).delete();
  }

  // ===========================================================================
  // RANKS CRUD
  // ===========================================================================

  Stream<List<Map<String, dynamic>>> streamRanks(String gymId) {
    return _firestore
        .collection('gym_master_ranks')
        .where('rank_parent_gym_id', isEqualTo: gymId)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              data['rank_id_key'] = d.id;
              return data;
            }).toList());
  }

  Future<void> createRank({
    required String gymId,
    required String title,
    required int minPoints,
    required List<String> benefits,
    required int priorityOrder,
  }) async {
    final ref = _firestore.collection('gym_master_ranks').doc();
    await ref.set({
      'rank_id_key': ref.id,
      'rank_parent_gym_id': gymId,
      'rank_title_name': title,
      'rank_min_points_threshold': minPoints,
      'rank_benefit_description_list': benefits,
      'rank_badge_image_url': '',
      'rank_priority_order': priorityOrder,
      'rank_is_active': true,
    });
  }

  Future<void> updateRank({
    required String rankId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection('gym_master_ranks').doc(rankId).update(data);
  }

  Future<void> deleteRank(String rankId) async {
    await _firestore.collection('gym_master_ranks').doc(rankId).delete();
  }
}
