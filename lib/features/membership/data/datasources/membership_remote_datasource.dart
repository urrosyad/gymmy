import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymmy/features/membership/data/models/membership_model.dart';

class MembershipRemoteDatasource {
  final FirebaseFirestore _firestore;

  MembershipRemoteDatasource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  static const _collection = 'gym_members_registry';

  Future<MembershipModel?> fetchActiveMembership(String userUid) async {
    final query = await _firestore
        .collection(_collection)
        .where('mem_user_uid', isEqualTo: userUid)
        .where('mem_membership_status', isEqualTo: 'active')
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    return MembershipModel.fromMap(doc.id, doc.data());
  }
}
