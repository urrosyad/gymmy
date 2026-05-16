class MembershipEntity {
  final String memIdKey;
  final String memUserUid;
  final String memGymId;
  final String memMembershipType; // monthly / yearly
  final String memMembershipStatus; // active / inactive / expired
  final int memCurrentPointsBalance;
  final int memStreakConsecutiveDays;
  final DateTime memJoinTimestamp;
  final DateTime? memMembershipStartDate;
  final DateTime? memMembershipEndDate;
  final String? memCurrentRankId;
  final int memTotalCheckinCount;
  final DateTime? memLastCheckinAt;
  final bool memIsFrozen;
  final String? memCreatedByOwnerUid;

  const MembershipEntity({
    required this.memIdKey,
    required this.memUserUid,
    required this.memGymId,
    required this.memMembershipType,
    required this.memMembershipStatus,
    required this.memCurrentPointsBalance,
    required this.memStreakConsecutiveDays,
    required this.memJoinTimestamp,
    this.memMembershipStartDate,
    this.memMembershipEndDate,
    this.memCurrentRankId,
    this.memTotalCheckinCount = 0,
    this.memLastCheckinAt,
    this.memIsFrozen = false,
    this.memCreatedByOwnerUid,
  });

  bool get isActive => memMembershipStatus == 'active';
}
