import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/membership/presentation/providers/active_membership_provider.dart';
import 'package:go_router/go_router.dart';

class MemberMyGymScreen extends ConsumerWidget {
  const MemberMyGymScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membershipAsync = ref.watch(activeMembershipProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('GYMMY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)), automaticallyImplyLeading: false),
      body: membershipAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _lockedState(context, theme),
        data: (mem) {
          if (mem == null || !mem.isActive) return _lockedState(context, theme);
          return _activeState(context, theme, mem.memGymId);
        },
      ),
    );
  }

  Widget _activeState(BuildContext ctx, ThemeData theme, String gymId) {
    return DefaultTabController(length: 2, child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Gym Saya', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
      ])),
      TabBar(tabs: const [Tab(text: 'Peralatan'), Tab(text: 'Kelas')],
        labelColor: theme.colorScheme.onSurface, indicatorColor: AppColors.primary),
      Expanded(child: TabBarView(children: [
        _equipList(ctx, theme, gymId),
        _classList(ctx, theme, gymId),
      ])),
    ]));
  }

  Widget _equipList(BuildContext ctx, ThemeData theme, String gymId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('gym_equipments').where('equip_parent_gym_id', isEqualTo: gymId).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return Center(child: Text('Belum ada peralatan', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.lightSecondaryText)));
        return ListView.separated(padding: const EdgeInsets.all(24), itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.08))),
              child: Row(children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.fitness_center, color: Color(0xFFD97706), size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d['equip_name_label'] ?? '', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  if ((d['equip_category_type'] ?? '').toString().isNotEmpty)
                    Text(d['equip_category_type'], style: theme.textTheme.bodySmall?.copyWith(color: AppColors.lightSecondaryText)),
                ])),
              ]));
          });
      },
    );
  }

  Widget _classList(BuildContext ctx, ThemeData theme, String gymId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('gym_classes_catalog').where('class_parent_gym_id', isEqualTo: gymId).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return Center(child: Text('Belum ada kelas', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.lightSecondaryText)));
        return ListView.separated(padding: const EdgeInsets.all(24), itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.08))),
              child: Row(children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.event_note, color: Color(0xFF059669), size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d['class_title_name'] ?? '', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  Text(d['class_schedule_text'] ?? '', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.lightSecondaryText)),
                ])),
              ]));
          });
      },
    );
  }

  Widget _lockedState(BuildContext ctx, ThemeData theme) {
    return Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
        child: Icon(Icons.lock_outline, size: 56, color: theme.colorScheme.onSurface.withValues(alpha: 0.35))),
      const SizedBox(height: 24),
      Text('Gym Saya', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Text('Ayo gabung sebagai member gym terlebih dahulu.', textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.55), height: 1.5)),
      const SizedBox(height: 32),
      FilledButton.icon(
        onPressed: () => ctx.go('/member/home'),
        icon: const Icon(Icons.search),
        label: const Text('Cari Gym'),
        style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.darkBackground,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
    ])));
  }
}
