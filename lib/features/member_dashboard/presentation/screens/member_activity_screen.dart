import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/biodata/presentation/screens/biodata_detail_screen.dart';
import 'package:gymmy/features/member_dashboard/presentation/widgets/member_top_bar.dart';
import 'package:intl/intl.dart';

class MemberActivityScreen extends ConsumerStatefulWidget {
  const MemberActivityScreen({super.key});
  @override
  ConsumerState<MemberActivityScreen> createState() => _State();
}

class _State extends ConsumerState<MemberActivityScreen> {
  String _tab = 'Semua';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authUser = ref.watch(authProvider).user;
    final userId = authUser?.uid ?? '';
    final memberName = authUser?.fullName ?? 'Member';

    return Scaffold(
      appBar: MemberTopBar(
        memberName: memberName,
        automaticallyImplyLeading: false,
        onAvatarTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BiodataDetailScreen()),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Riwayat',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lihat riwayat aktivitas gym kamu',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _chip(context, 'Semua'),
                      const SizedBox(width: 8),
                      _chip(context, 'Check-in'),
                      const SizedBox(width: 8),
                      _chip(context, 'Membership'),
                      const SizedBox(width: 8),
                      _chip(context, 'Kelas'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(child: _buildContent(context, theme, userId)),
        ],
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
            color: sel
                ? AppColors.primary
                : Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: sel
                ? AppColors.darkBackground
                : Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext ctx, ThemeData theme, String userId) {
    if (userId.isEmpty) return _empty(theme);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchHistory(userId),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? [];
        if (items.isEmpty) return _empty(theme);
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _historyTile(theme, items[i]),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchHistory(String userId) async {
    final List<Map<String, dynamic>> result = [];

    try {
      // --- Daily check-ins from gym_daily_visits ---
      if (_tab == 'Semua' || _tab == 'Check-in') {
        final visits = await FirebaseFirestore.instance
            .collection('gym_daily_visits')
            .where('daily_visit_user_uid', isEqualTo: userId)
            .limit(50)
            .get();
        for (final doc in visits.docs) {
          final d = doc.data();
          result.add({
            'type': 'daily',
            'date': d['daily_visit_checkin_at'],
            'status': (d['daily_visit_status'] ?? 'checked_in').toString(),
            'gymId': (d['daily_visit_gym_id'] ?? '').toString(),
          });
        }
      }

      // --- Attendance logs for membership and class types ---
      if (_tab == 'Semua' || _tab == 'Membership' || _tab == 'Kelas') {
        final logsQuery = FirebaseFirestore.instance
            .collection('gym_attendance_logs')
            .where('log_user_uid', isEqualTo: userId)
            .limit(50);

        final logs = await logsQuery.get();
        for (final doc in logs.docs) {
          final d = doc.data();
          final cat = (d['log_category_type'] ?? 'other').toString();

          // Skip daily entries already captured above when tab is Semua
          if (_tab == 'Semua' && cat == 'daily') continue;

          // Apply tab filter
          if (_tab == 'Membership' && cat != 'membership') continue;
          if (_tab == 'Kelas' && cat != 'class') continue;

          result.add({
            'type': cat,
            'date': d['log_recorded_at'],
            'status': 'logged',
            'gymId': (d['log_gym_id'] ?? '').toString(),
            'classId': (d['log_reference_class_id'] ?? '').toString(),
          });
        }
      }
    } catch (e) {
      debugPrint('Gagal memuat riwayat member: $e');
    }

    // Sort by date descending
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
    final isDark = theme.brightness == Brightness.dark;
    final df = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final ts = item['date'] as Timestamp?;
    final dateStr = ts != null ? df.format(ts.toDate()) : '-';
    final type = (item['type'] as String?) ?? 'other';

    IconData icon;
    Color color;
    String label;
    String? statusStr;

    switch (type) {
      case 'daily':
        icon = Icons.how_to_reg;
        color = isDark ? AppColors.darkPrimaryText : Colors.green;
        label = 'Check-in Harian';
        final st = (item['status'] ?? '').toString();
        statusStr = st == 'checked_in' ? 'Berhasil' : st;
        break;
      case 'membership':
        icon = Icons.card_membership_outlined;
        color = isDark ? AppColors.darkPrimaryText : const Color(0xFF7C3AED);
        label = 'Aktivasi Membership';
        statusStr = null;
        break;
      case 'class':
        icon = Icons.event_note;
        color = isDark ? AppColors.darkPrimaryText : Colors.orange;
        label = 'Hadir Kelas';
        statusStr = null;
        break;
      default:
        icon = Icons.history;
        color = isDark ? AppColors.darkPrimaryText : Colors.blue;
        label = 'Aktivitas';
        statusStr = null;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardSurface : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : theme.colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkElevatedSurface
                  : color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  dateStr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.lightSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          if (statusStr != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSuccess.withValues(alpha: 0.12)
                    : Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusStr,
                style: TextStyle(
                  color: isDark ? AppColors.darkSuccess : Colors.green.shade700,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _empty(ThemeData theme) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.history, size: 48, color: AppColors.primary),
        ),
        const SizedBox(height: 20),
        Text(
          'Belum ada riwayat',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Riwayat aktivitas gym kamu\nakan muncul di sini.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    ),
  );
}
