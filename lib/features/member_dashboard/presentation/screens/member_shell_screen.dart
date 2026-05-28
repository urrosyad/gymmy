import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/membership/presentation/providers/active_membership_provider.dart';
import 'package:gymmy/features/qr_system/presentation/screens/member_scan_membership_screen.dart';
import 'package:gymmy/features/qr_system/presentation/screens/daily_qr_screen.dart';

class MemberShellScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const MemberShellScreen({super.key, required this.navigationShell});

  void _onTap(int index, BuildContext context, WidgetRef ref) {
    if (index == 2) { _showScanBS(context, ref); return; }
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  void _showScanBS(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(context: context, backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Aksi QR', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Pilih aksi yang ingin dilakukan', style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
            color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 24),
          _action(ctx, icon: Icons.qr_code_scanner, label: 'Scan QR Membership Gym', sub: 'Scan QR dari owner untuk bergabung', onTap: () {
            Navigator.pop(ctx);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MemberScanMembershipScreen()));
          }),
          const SizedBox(height: 12),
          _action(ctx, icon: Icons.qr_code, label: 'Tampilkan QR Check-in Harian', sub: 'Tunjukkan QR ini ke owner untuk check-in', onTap: () {
            Navigator.pop(ctx);
            final membership = ref.read(activeMembershipProvider).value;
            final userId = ref.read(authProvider).user?.uid ?? '';
            if (membership != null && membership.isActive) {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => DailyQrScreen(
                gymId: membership.memGymId, gymName: 'Gym Saya', userId: userId)));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anda belum memiliki membership aktif. Cari gym terlebih dahulu.')));
            }
          }),
          const SizedBox(height: 12),
          _action(ctx, icon: Icons.event_available, label: 'Tampilkan QR Kelas', sub: 'Tunjukkan QR ini untuk absensi kelas', onTap: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur QR Kelas akan segera tersedia')));
          }),
          const SizedBox(height: 16),
        ])));
  }

  Widget _action(BuildContext ctx, {required IconData icon, required String label, required String sub, required VoidCallback onTap}) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16),
      child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(
        color: Theme.of(ctx).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 24)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(sub, style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.55))),
          ])),
          Icon(Icons.chevron_right, color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.4)),
        ])));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(body: navigationShell,
      bottomNavigationBar: NavigationBar(selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => _onTap(i, context, ref),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          const NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Gym Saya'),
          NavigationDestination(icon: Container(width: 52, height: 52, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.qr_code_scanner, color: AppColors.darkBackground, size: 24)), label: ''),
          const NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Riwayat'),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ]));
  }
}
