import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/membership/presentation/providers/active_membership_provider.dart';
import 'package:intl/intl.dart';

class DashboardMemberView extends ConsumerWidget {
  final String userName;
  const DashboardMemberView({super.key, required this.userName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membershipAsync = ref.watch(activeMembershipProvider);

    return membershipAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Gagal memuat data: $e')),
      data: (membership) {
        if (membership == null) return const Center(child: CircularProgressIndicator());
        final df = DateFormat('dd MMM yyyy', 'id_ID');
        final startStr = membership.memMembershipStartDate != null ? df.format(membership.memMembershipStartDate!) : '-';
        final endStr = membership.memMembershipEndDate != null ? df.format(membership.memMembershipEndDate!) : '-';

        // Progress bar calculation
        double progress = 0;
        if (membership.memMembershipStartDate != null && membership.memMembershipEndDate != null) {
          final total = membership.memMembershipEndDate!.difference(membership.memMembershipStartDate!).inDays;
          final elapsed = DateTime.now().difference(membership.memMembershipStartDate!).inDays;
          if (total > 0) progress = (elapsed / total).clamp(0, 1);
        }
        final daysLeft = membership.memMembershipEndDate != null
            ? membership.memMembershipEndDate!.difference(DateTime.now()).inDays : 0;

        return SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Selamat datang,', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              Text(userName, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            CircleAvatar(backgroundColor: theme.colorScheme.primaryContainer, radius: 24,
              child: Icon(Icons.person, color: theme.colorScheme.primary)),
          ]),
          const SizedBox(height: 24),

          // Membership status card
          Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(
            color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text('Membership Aktif', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 12))),
                const Spacer(),
                Text(membership.memMembershipType, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.lightSecondaryText)),
              ]),
              const SizedBox(height: 16),
              Text('$startStr - $endStr', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: progress, minHeight: 6,
                  backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary))),
              const SizedBox(height: 8),
              Text('${daysLeft > 0 ? daysLeft : 0} hari tersisa', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.lightSecondaryText)),
            ])),
          const SizedBox(height: 24),

          // Stats
          Text('Progress Kamu', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(children: [
            _stat(context, 'Streak', '${membership.memStreakConsecutiveDays} Hari', Icons.local_fire_department_rounded, Colors.orange),
            const SizedBox(width: 16),
            _stat(context, 'Poin', '${membership.memCurrentPointsBalance}', Icons.star_rounded, Colors.amber),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            _stat(context, 'Total Check-in', '${membership.memTotalCheckinCount}', Icons.how_to_reg, Colors.blue),
            const SizedBox(width: 16),
            _stat(context, 'Check-in Terakhir', membership.memLastCheckinAt != null ? df.format(membership.memLastCheckinAt!) : '-',
              Icons.schedule, Colors.teal),
          ]),
        ]));
      },
    );
  }

  Widget _stat(BuildContext ctx, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(ctx);
    return Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(
      color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 28), const SizedBox(height: 12),
        Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
      ])));
  }
}
