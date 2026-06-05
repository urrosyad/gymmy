import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/biodata/presentation/screens/biodata_detail_screen.dart';
import 'package:gymmy/features/membership/presentation/providers/active_membership_provider.dart';
import 'package:gymmy/features/member_dashboard/presentation/widgets/dashboard_member_view.dart';
import 'package:gymmy/features/member_dashboard/presentation/widgets/member_top_bar.dart';
import 'package:gymmy/features/gym_tenant/presentation/screens/gym_discovery_screen.dart';
import 'package:gymmy/core/providers/user_flow_provider.dart';

class MemberDashboardScreen extends ConsumerWidget {
  const MemberDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final userName = auth.user?.fullName ?? 'User';
    final membershipAsync = ref.watch(activeMembershipProvider);
    final flow = ref.watch(userFlowProvider);

    return Scaffold(
      appBar: MemberTopBar(
        memberName: userName,
        automaticallyImplyLeading: false,
        onAvatarTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BiodataDetailScreen()),
        ),
      ),
      body: membershipAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Gagal memuat data membership: $e')),
        data: (membership) {
          if (flow == AppDestination.gymDiscovery) {
            return const GymDiscoveryScreen();
          }
          if (membership == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return DashboardMemberView(userName: userName);
        },
      ),
    );
  }
}
