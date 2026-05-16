import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_state.dart';
import 'package:gymmy/features/gym_tenant/presentation/providers/gym_tenant_provider.dart';
import 'package:gymmy/features/membership/presentation/providers/active_membership_provider.dart';

/// Represents the correct destination for the user based on all conditions.
enum AppDestination {
  loading,
  unauthenticated,
  biodataOnboarding,
  gymDiscovery,
  memberDashboard,
  ownerSetup,
  ownerDashboard,
}

/// Computes where the user should be routed. This is watched by the router
/// via a ChangeNotifier bridge so redirects happen when state settles.
final userFlowProvider = Provider<AppDestination>((ref) {
  final authState = ref.watch(authProvider);

  // Still loading auth session
  if (authState.status == AuthStatus.initial ||
      authState.status == AuthStatus.checkingSession) {
    return AppDestination.loading;
  }

  // Not authenticated
  if (authState.status != AuthStatus.authenticated || authState.user == null) {
    return AppDestination.unauthenticated;
  }

  final user = authState.user!;

  // --- OWNER FLOW ---
  if (user.isOwner) {
    final ownerGym = ref.watch(ownerGymProvider);
    return ownerGym.when(
      loading: () => AppDestination.loading,
      error: (error, stack) => AppDestination.ownerSetup,
      data: (gym) => gym != null
          ? AppDestination.ownerDashboard
          : AppDestination.ownerSetup,
    );
  }

  // --- MEMBER FLOW ---
  // Step 1: biodata check
  if (!user.hasCompletedBiodata) {
    return AppDestination.biodataOnboarding;
  }

  // Step 2: membership check
  final membership = ref.watch(activeMembershipProvider);
  return membership.when(
    loading: () => AppDestination.loading,
    error: (error, stack) => AppDestination.gymDiscovery,
    data: (mem) => (mem != null && mem.isActive)
        ? AppDestination.memberDashboard
        : AppDestination.gymDiscovery,
  );
});
