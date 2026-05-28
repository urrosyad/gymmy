import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/gym_tenant/presentation/providers/gym_tenant_provider.dart';
import 'package:intl/intl.dart';

class OwnerMembershipScreen extends ConsumerStatefulWidget {
  const OwnerMembershipScreen({super.key});
  @override
  ConsumerState<OwnerMembershipScreen> createState() => _State();
}

class _State extends ConsumerState<OwnerMembershipScreen> {
  String _filter = 'Semua';
  // Cache user display names by uid to avoid repeated fetches
  final Map<String, String> _nameCache = {};

  Future<String> _getUserDisplay(String uid) async {
    if (uid.isEmpty) return 'Pengguna tidak diketahui';
    if (_nameCache.containsKey(uid)) return _nameCache[uid]!;
    try {
      final doc = await FirebaseFirestore.instance.collection('user_accounts_global').doc(uid).get();
      if (doc.exists) {
        final d = doc.data()!;
        final name = (d['user_full_name'] ?? '').toString().trim();
        final email = (d['user_email_address'] ?? '').toString().trim();
        final display = name.isNotEmpty ? name : (email.isNotEmpty ? email : uid.substring(0, 8));
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
        title: const Text('GYMMY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        automaticallyImplyLeading: false,
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
                Text('Membership', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Kelola data member gym kamu',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _chip(context, 'Semua'), const SizedBox(width: 8),
                    _chip(context, 'Aktif'), const SizedBox(width: 8),
                    _chip(context, 'Tidak Aktif'),
                  ]),
                ),
                const SizedBox(height: 16),
              ]),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _buildQuery(gym.gtIdKey),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) return _emptyState(theme);
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    itemCount: docs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final d = docs[i].data() as Map<String, dynamic>;
                      return _memberTile(context, d, theme);
                    },
                  );
                },
              ),
            ),
          ]);
        },
      ),
    );
  }

  Stream<QuerySnapshot> _buildQuery(String gymId) {
    var q = FirebaseFirestore.instance
        .collection('gym_members_registry')
        .where('mem_gym_id', isEqualTo: gymId);
    if (_filter == 'Aktif') q = q.where('mem_membership_status', isEqualTo: 'active');
    if (_filter == 'Tidak Aktif') q = q.where('mem_membership_status', isEqualTo: 'inactive');
    return q.snapshots();
  }

  Widget _chip(BuildContext ctx, String label) {
    final sel = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary : Theme.of(ctx).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? AppColors.primary : Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.15)),
        ),
        child: Text(label, style: TextStyle(
          color: sel ? AppColors.darkBackground : Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.7),
          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13,
        )),
      ),
    );
  }

  Widget _emptyState(ThemeData theme) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.people_outline, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text('Belum ada data membership', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Data member akan muncul setelah\nmember bergabung ke gym kamu.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
          ),
        ]),
      );

  Widget _memberTile(BuildContext ctx, Map<String, dynamic> d, ThemeData theme) {
    final df = DateFormat('dd MMM yyyy', 'id_ID');
    final status = (d['mem_membership_status'] ?? 'inactive').toString();
    final isActive = status == 'active';
    final startTs = d['mem_membership_start_date'];
    final endTs = d['mem_membership_end_date'];
    final start = startTs is Timestamp ? df.format(startTs.toDate()) : '-';
    final end = endTs is Timestamp ? df.format(endTs.toDate()) : '-';
    final uid = (d['mem_user_uid'] ?? '').toString();
    final memberType = (d['mem_membership_type'] ?? 'monthly').toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Async user name lookup
              FutureBuilder<String>(
                future: _getUserDisplay(uid),
                builder: (_, snap) => Text(
                  snap.data ?? (uid.isNotEmpty ? '${uid.substring(0, uid.length.clamp(0, 8))}...' : '-'),
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(memberType, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.lightSecondaryText)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isActive ? 'Aktif' : 'Tidak Aktif',
              style: TextStyle(
                color: isActive ? AppColors.success : AppColors.error,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _stat('Poin', '${(d['mem_current_points_balance'] as num?)?.toInt() ?? 0}'),
          _stat('Streak', '${(d['mem_streak_consecutive_days'] as num?)?.toInt() ?? 0}'),
          _stat('Check-in', '${(d['mem_total_checkin_count'] as num?)?.toInt() ?? 0}'),
        ]),
        const SizedBox(height: 8),
        Text(
          'Periode: $start - $end',
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.lightSecondaryText),
        ),
      ]),
    );
  }

  Widget _stat(String label, String val) => Expanded(
        child: Column(children: [
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.lightSecondaryText)),
        ]),
      );
}
