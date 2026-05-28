import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/gym_tenant/presentation/providers/gym_tenant_provider.dart';
import 'package:intl/intl.dart';

class OwnerHistoryScreen extends ConsumerStatefulWidget {
  const OwnerHistoryScreen({super.key});
  @override
  ConsumerState<OwnerHistoryScreen> createState() => _State();
}

class _State extends ConsumerState<OwnerHistoryScreen> {
  String _tab = 'Semua';
  final Map<String, String> _nameCache = {};

  Future<String> _getUserDisplay(String uid) async {
    if (uid.isEmpty) return '-';
    if (_nameCache.containsKey(uid)) return _nameCache[uid]!;
    try {
      final doc = await FirebaseFirestore.instance.collection('user_accounts_global').doc(uid).get();
      if (doc.exists) {
        final d = doc.data()!;
        final name = (d['user_full_name'] ?? '').toString().trim();
        final email = (d['user_email_address'] ?? '').toString().trim();
        final display = name.isNotEmpty ? name : (email.isNotEmpty ? email : '${uid.substring(0, uid.length.clamp(0, 8))}...');
        _nameCache[uid] = display;
        return display;
      }
    } catch (_) {}
    _nameCache[uid] = uid.length > 8 ? '${uid.substring(0, 8)}...' : uid;
    return _nameCache[uid]!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gymAsync = ref.watch(ownerGymProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Check-in', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: gymAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (gym) {
          if (gym == null) return const Center(child: Text('Data gym tidak ditemukan'));
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Riwayat', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Semua aktivitas check-in di gym kamu',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _chip(context, 'Semua'), const SizedBox(width: 8),
                    _chip(context, 'Harian'), const SizedBox(width: 8),
                    _chip(context, 'Membership'), const SizedBox(width: 8),
                    _chip(context, 'Kelas'),
                  ]),
                ),
                const SizedBox(height: 16),
              ]),
            ),
            Expanded(child: _buildList(context, theme, gym.gtIdKey)),
          ]);
        },
      ),
    );
  }

  Widget _chip(BuildContext ctx, String label) {
    final sel = _tab == label;
    return GestureDetector(
      onTap: () => setState(() => _tab = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary : Theme.of(ctx).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sel ? AppColors.primary : Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: sel ? AppColors.darkBackground : Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext ctx, ThemeData theme, String gymId) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchHistory(gymId),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? [];
        if (items.isEmpty) return _emptyState(theme);
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _historyTile(theme, items[i]),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchHistory(String gymId) async {
    final List<Map<String, dynamic>> result = [];
    try {
      // Daily visits
      if (_tab == 'Semua' || _tab == 'Harian') {
        final visits = await FirebaseFirestore.instance
            .collection('gym_daily_visits')
            .where('daily_visit_gym_id', isEqualTo: gymId)
            .orderBy('daily_visit_checkin_at', descending: true)
            .limit(50)
            .get();
        for (final doc in visits.docs) {
          final d = doc.data();
          result.add({
            'type': 'daily',
            'date': d['daily_visit_checkin_at'],
            'uid': (d['daily_visit_user_uid'] ?? '').toString(),
            'status': (d['daily_visit_status'] ?? 'checked_in').toString(),
          });
        }
      }

      // Attendance logs
      if (_tab == 'Semua' || _tab == 'Membership' || _tab == 'Kelas') {
        final logs = await FirebaseFirestore.instance
            .collection('gym_attendance_logs')
            .where('log_gym_id', isEqualTo: gymId)
            .orderBy('log_recorded_at', descending: true)
            .limit(50)
            .get();
        for (final doc in logs.docs) {
          final d = doc.data();
          final cat = (d['log_category_type'] ?? 'other').toString();
          if (_tab == 'Semua' && cat == 'daily') continue;
          if (_tab == 'Membership' && cat != 'membership') continue;
          if (_tab == 'Kelas' && cat != 'class') continue;
          result.add({
            'type': cat,
            'date': d['log_recorded_at'],
            'uid': (d['log_user_uid'] ?? '').toString(),
            'status': 'logged',
          });
        }
      }
    } catch (_) {}

    result.sort((a, b) {
      final aTs = a['date'] as Timestamp?;
      final bTs = b['date'] as Timestamp?;
      if (aTs == null && bTs == null) return 0;
      if (aTs == null) return 1;
      if (bTs == null) return -1;
      return bTs.compareTo(aTs);
    });

    return result;
  }

  Widget _historyTile(ThemeData theme, Map<String, dynamic> item) {
    final df = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final ts = item['date'] as Timestamp?;
    final dateStr = ts != null ? df.format(ts.toDate()) : '-';
    final type = (item['type'] as String?) ?? 'other';
    final uid = (item['uid'] as String?) ?? '';

    IconData icon;
    Color color;
    String label;

    switch (type) {
      case 'daily':
        icon = Icons.how_to_reg;
        color = Colors.green;
        label = 'Check-in Harian';
        break;
      case 'membership':
        icon = Icons.card_membership_outlined;
        color = const Color(0xFF7C3AED);
        label = 'Aktivasi Membership';
        break;
      case 'class':
        icon = Icons.event_note;
        color = Colors.orange;
        label = 'Hadir Kelas';
        break;
      default:
        icon = Icons.history;
        color = Colors.blue;
        label = 'Aktivitas';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            Text(dateStr, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.lightSecondaryText)),
            const SizedBox(height: 2),
            FutureBuilder<String>(
              future: _getUserDisplay(uid),
              builder: (context, snap) => Text(
                snap.data ?? uid,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _emptyState(ThemeData theme) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.history, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text('Belum ada riwayat', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Riwayat check-in akan muncul\nsetelah ada member yang scan QR.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
          ),
        ]),
      );
}
