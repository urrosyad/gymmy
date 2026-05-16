import 'package:gymmy/features/membership/domain/entities/membership_entity.dart';
import 'package:gymmy/features/membership/domain/repositories/membership_repository.dart';

class GetActiveMembershipUsecase {
  final MembershipRepository _repository;

  GetActiveMembershipUsecase(this._repository);

  Future<MembershipEntity?> call(String userUid) =>
      _repository.fetchActiveMembership(userUid);
}
