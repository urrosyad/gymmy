import 'package:gymmy/features/membership/data/datasources/membership_remote_datasource.dart';
import 'package:gymmy/features/membership/domain/entities/membership_entity.dart';
import 'package:gymmy/features/membership/domain/repositories/membership_repository.dart';

class MembershipRepositoryImpl implements MembershipRepository {
  final MembershipRemoteDatasource _datasource;

  MembershipRepositoryImpl(this._datasource);

  @override
  Future<MembershipEntity?> fetchActiveMembership(String userUid) =>
      _datasource.fetchActiveMembership(userUid);
}