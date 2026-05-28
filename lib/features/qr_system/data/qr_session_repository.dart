import 'package:cloud_firestore/cloud_firestore.dart';

class QrSessionRepository {
  final FirebaseFirestore _firestore;

  QrSessionRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Creates a daily check-in QR session and returns the session ID.
  Future<String> createDailyQrSession({
    required String userId,
    required String gymId,
  }) async {
    final ref = _firestore.collection('qr_sessions').doc();
    final now = DateTime.now();
    final expiry = now.add(const Duration(minutes: 5));

    await ref.set({
      'qr_session_id': ref.id,
      'qr_type': 'daily',
      'qr_related_user_uid': userId,
      'qr_related_gym_id': gymId,
      'qr_related_class_id': '',
      'qr_generated_at': Timestamp.fromDate(now),
      'qr_expired_at': Timestamp.fromDate(expiry),
      'qr_is_used': false,
    });

    return ref.id;
  }

  /// Validates and consumes a QR session. Returns the session data if valid.
  Future<Map<String, dynamic>?> validateAndConsumeQrSession(
      String sessionId) async {
    final doc =
        await _firestore.collection('qr_sessions').doc(sessionId).get();
    if (!doc.exists || doc.data() == null) return null;

    final data = doc.data()!;
    final isUsed = data['qr_is_used'] as bool? ?? true;
    final expiredAt = data['qr_expired_at'] as Timestamp?;

    if (isUsed) return null;
    if (expiredAt != null && expiredAt.toDate().isBefore(DateTime.now())) {
      return null;
    }

    // Mark as used
    await doc.reference.update({'qr_is_used': true});
    return data;
  }

  /// Creates a daily visit record after owner scans member's daily QR.
  Future<void> createDailyVisit({
    required String userId,
    required String gymId,
    required String qrSessionId,
    required String ownerUid,
  }) async {
    final ref = _firestore.collection('gym_daily_visits').doc();
    await ref.set({
      'daily_visit_id_key': ref.id,
      'daily_visit_user_uid': userId,
      'daily_visit_gym_id': gymId,
      'daily_visit_checkin_at': FieldValue.serverTimestamp(),
      'daily_visit_payment_status': 'paid',
      'daily_visit_qr_session_id': qrSessionId,
      'daily_visit_checkout_at': null,
      'daily_visit_validated_by_owner': ownerUid,
      'daily_visit_status': 'checked_in',
    });
  }

  /// Creates an attendance log after a check-in.
  Future<void> createAttendanceLog({
    required String userId,
    required String gymId,
    required String qrSessionId,
    required String ownerUid,
    required String category,
    String? classId,
  }) async {
    final ref = _firestore.collection('gym_attendance_logs').doc();
    await ref.set({
      'log_id_key': ref.id,
      'log_member_id': '',
      'log_gym_id': gymId,
      'log_category_type': category,
      'log_reference_class_id': classId ?? '',
      'log_recorded_at': FieldValue.serverTimestamp(),
      'log_user_uid': userId,
      'log_qr_session_id': qrSessionId,
      'log_validated_by_owner_uid': ownerUid,
      'log_device_platform': 'mobile',
    });
  }

  /// Creates a membership record when member scans owner's membership QR.
  Future<void> createMembership({
    required String userId,
    required String gymId,
    String? ownerUid,
  }) async {
    final ref = _firestore.collection('gym_members_registry').doc();
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 30));

    await ref.set({
      'mem_id_key': ref.id,
      'mem_user_uid': userId,
      'mem_gym_id': gymId,
      'mem_membership_type': 'monthly',
      'mem_membership_status': 'active',
      'mem_current_points_balance': 0,
      'mem_streak_consecutive_days': 0,
      'mem_join_timestamp': Timestamp.fromDate(now),
      'mem_membership_start_date': Timestamp.fromDate(now),
      'mem_membership_end_date': Timestamp.fromDate(endDate),
      'mem_current_rank_id': '',
      'mem_total_checkin_count': 0,
      'mem_last_checkin_at': null,
      'mem_is_frozen': false,
      'mem_created_by_owner_uid': ownerUid ?? '',
    });
  }

  /// Gets today's check-in count for a gym.
  Future<int> getTodayCheckinCount(String gymId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final query = await _firestore
        .collection('gym_daily_visits')
        .where('daily_visit_gym_id', isEqualTo: gymId)
        .where('daily_visit_checkin_at',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();
    return query.docs.length;
  }

  /// Gets total member count for a gym.
  Future<int> getMemberCount(String gymId) async {
    final query = await _firestore
        .collection('gym_members_registry')
        .where('mem_gym_id', isEqualTo: gymId)
        .get();
    return query.docs.length;
  }

  /// Gets members list for a gym.
  Future<List<Map<String, dynamic>>> getGymMembers(String gymId) async {
    final query = await _firestore
        .collection('gym_members_registry')
        .where('mem_gym_id', isEqualTo: gymId)
        .get();
    return query.docs.map((d) => d.data()).toList();
  }

  /// Gets total equipment count for a gym.
  Future<int> getEquipmentCount(String gymId) async {
    final query = await _firestore
        .collection('gym_equipments')
        .where('equip_parent_gym_id', isEqualTo: gymId)
        .get();
    return query.docs.length;
  }

  /// Gets total class count for a gym.
  Future<int> getClassCount(String gymId) async {
    final query = await _firestore
        .collection('gym_classes_catalog')
        .where('class_parent_gym_id', isEqualTo: gymId)
        .get();
    return query.docs.length;
  }

  /// Gets daily visits for a user.
  Future<List<Map<String, dynamic>>> getUserDailyVisits(String userId) async {
    final query = await _firestore
        .collection('gym_daily_visits')
        .where('daily_visit_user_uid', isEqualTo: userId)
        .orderBy('daily_visit_checkin_at', descending: true)
        .limit(50)
        .get();
    return query.docs.map((d) => d.data()).toList();
  }

  /// Gets attendance logs for a user.
  Future<List<Map<String, dynamic>>> getUserAttendanceLogs(
      String userId) async {
    final query = await _firestore
        .collection('gym_attendance_logs')
        .where('log_user_uid', isEqualTo: userId)
        .orderBy('log_recorded_at', descending: true)
        .limit(50)
        .get();
    return query.docs.map((d) => d.data()).toList();
  }

  /// Gets class subscriptions for a user.
  Future<List<Map<String, dynamic>>> getUserClassSubscriptions(
      String userId) async {
    final query = await _firestore
        .collection('gym_class_subscriptions')
        .where('sub_user_uid', isEqualTo: userId)
        .orderBy('sub_started_at', descending: true)
        .limit(50)
        .get();
    return query.docs.map((d) => d.data()).toList();
  }
}
