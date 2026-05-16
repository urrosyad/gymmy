import 'package:gymmy/features/membership/domain/entities/membership_entity.dart';

abstract class MembershipRepository {
  /// Returns the active membership for [userUid], or null if none.
  Future<MembershipEntity?> fetchActiveMembership(String userUid);
}
