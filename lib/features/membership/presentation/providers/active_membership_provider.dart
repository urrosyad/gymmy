import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/di/injection.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/membership/domain/entities/membership_entity.dart';
import 'package:gymmy/features/membership/domain/usecases/get_active_membership_usecase.dart';

/// Fetches the active membership for the currently logged-in member.
/// Returns null if no active membership exists.
final activeMembershipProvider = FutureProvider<MembershipEntity?>((ref) async {
  final auth = ref.watch(authProvider);
  final uid = auth.user?.uid;
  if (uid == null) return null;
  final usecase = sl<GetActiveMembershipUsecase>();
  return usecase(uid);
});
