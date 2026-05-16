import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymmy/features/membership/domain/entities/membership_entity.dart';

class MembershipModel extends MembershipEntity {
  const MembershipModel({
    required super.memIdKey,
    required super.memUserUid,
    required super.memGymId,
    required super.memMembershipType,
    required super.memMembershipStatus,
    required super.memCurrentPointsBalance,
    required super.memStreakConsecutiveDays,
    required super.memJoinTimestamp,
    super.memMembershipStartDate,
    super.memMembershipEndDate,
    super.memCurrentRankId,
    super.memTotalCheckinCount,
    super.memLastCheckinAt,
    super.memIsFrozen,
    super.memCreatedByOwnerUid,
  });

  factory MembershipModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime? parseTimestamp(dynamic v) =>
        v is Timestamp ? v.toDate() : null;

    return MembershipModel(
      memIdKey: map['mem_id_key'] as String? ?? id,
      memUserUid: map['mem_user_uid'] as String? ?? '',
      memGymId: map['mem_gym_id'] as String? ?? '',
      memMembershipType: map['mem_membership_type'] as String? ?? 'monthly',
      memMembershipStatus:
          map['mem_membership_status'] as String? ?? 'inactive',
      memCurrentPointsBalance:
          (map['mem_current_points_balance'] as num?)?.toInt() ?? 0,
      memStreakConsecutiveDays:
          (map['mem_streak_consecutive_days'] as num?)?.toInt() ?? 0,
      memJoinTimestamp:
          parseTimestamp(map['mem_join_timestamp']) ?? DateTime.now(),
      memMembershipStartDate: parseTimestamp(map['mem_membership_start_date']),
      memMembershipEndDate: parseTimestamp(map['mem_membership_end_date']),
      memCurrentRankId: map['mem_current_rank_id'] as String?,
      memTotalCheckinCount:
          (map['mem_total_checkin_count'] as num?)?.toInt() ?? 0,
      memLastCheckinAt: parseTimestamp(map['mem_last_checkin_at']),
      memIsFrozen: map['mem_is_frozen'] as bool? ?? false,
      memCreatedByOwnerUid: map['mem_created_by_owner_uid'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mem_id_key': memIdKey,
      'mem_user_uid': memUserUid,
      'mem_gym_id': memGymId,
      'mem_membership_type': memMembershipType,
      'mem_membership_status': memMembershipStatus,
      'mem_current_points_balance': memCurrentPointsBalance,
      'mem_streak_consecutive_days': memStreakConsecutiveDays,
      'mem_join_timestamp': Timestamp.fromDate(memJoinTimestamp),
      'mem_total_checkin_count': memTotalCheckinCount,
      'mem_is_frozen': memIsFrozen,
    };
  }
}
