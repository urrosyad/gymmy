import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/gym_tenant/presentation/providers/gym_tenant_provider.dart';
import 'package:intl/intl.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final ownerGymAsync = ref.watch(ownerGymProvider);
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('GYMMY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)), automaticallyImplyLeading: false),
      body: ownerGymAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat data gym: $e')),
        data: (gym) {
          if (gym == null) return const Center(child: CircularProgressIndicator());
          final theme = Theme.of(context);
          final gymId = gym.gtIdKey;

          return SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Selamat datang,', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            Text(auth.user?.fullName ?? '', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            // Gym Summary Card
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.storefront_outlined, color: AppColors.primary, size: 32),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(gym.gtNameTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text('${gym.gtCityName} \u2022 ${gym.gtLocation}', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.lightSecondaryText)),
                  ])),
                ]),
                const SizedBox(height: 16), const Divider(), const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Status:', style: theme.textTheme.bodyMedium),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(
                    color: (gym.gtIsActive ? AppColors.success : AppColors.error).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text(gym.gtIsActive ? 'Aktif' : 'Tidak Aktif', style: theme.textTheme.labelMedium?.copyWith(
                      color: gym.gtIsActive ? AppColors.success : AppColors.error, fontWeight: FontWeight.bold))),
                ]),
              ])),
            const SizedBox(height: 24),
            Text('Ringkasan', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Real stats
            Row(children: [
              _FutureStatCard(title: 'Total Member', icon: Icons.people_outline, color: Colors.blue,
                future: FirebaseFirestore.instance.collection('gym_members_registry').where('mem_gym_id', isEqualTo: gymId).get()
                  .then((s) => s.docs.length.toString())),
              const SizedBox(width: 16),
              _FutureStatCard(title: 'Check-in Hari Ini', icon: Icons.how_to_reg, color: Colors.green,
                future: _getTodayCheckins(gymId)),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              _FutureStatCard(title: 'Total Kelas', icon: Icons.event_note, color: Colors.orange,
                future: FirebaseFirestore.instance.collection('gym_classes_catalog').where('class_parent_gym_id', isEqualTo: gymId).get()
                  .then((s) => s.docs.length.toString())),
              const SizedBox(width: 16),
              _FutureStatCard(title: 'Total Peralatan', icon: Icons.fitness_center, color: Colors.purple,
                future: FirebaseFirestore.instance.collection('gym_equipments').where('equip_parent_gym_id', isEqualTo: gymId).get()
                  .then((s) => s.docs.length.toString())),
            ]),
            const SizedBox(height: 24),
            Text('Harga Layanan', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(children: [
              _buildStatCard(context, 'Harga Harian', currency.format(gym.gtDailyPriceAmount), Icons.today_outlined, const Color(0xFF0891B2)),
              const SizedBox(width: 16),
              _buildStatCard(context, 'Harga Membership', currency.format(gym.gtMembershipPriceAmount), Icons.card_membership_outlined, const Color(0xFF7C3AED)),
            ]),
          ]));
        },
      ),
    );
  }

  Future<String> _getTodayCheckins(String gymId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final snap = await FirebaseFirestore.instance.collection('gym_daily_visits')
        .where('daily_visit_gym_id', isEqualTo: gymId)
        .where('daily_visit_checkin_at', isGreaterThanOrEqualTo: Timestamp.fromDate(start)).get();
    return snap.docs.length.toString();
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 28), const SizedBox(height: 12),
        Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
      ])));
  }
}

class _FutureStatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Future<String> future;
  const _FutureStatCard({required this.title, required this.icon, required this.color, required this.future});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(child: FutureBuilder<String>(
      future: future,
      builder: (context, snap) {
        final value = snap.data ?? '0';
        return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color, size: 28), const SizedBox(height: 12),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ]));
      },
    ));
  }
}
