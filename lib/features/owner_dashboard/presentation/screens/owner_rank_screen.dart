import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/gym_tenant/presentation/providers/gym_tenant_provider.dart';

class OwnerRankScreen extends ConsumerWidget {
  const OwnerRankScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gymAsync = ref.watch(ownerGymProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Benefit Rank', style: TextStyle(fontWeight: FontWeight.bold))),
      body: gymAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (gym) {
          if (gym == null) return const Center(child: Text('Data gym tidak ditemukan'));
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('gym_master_ranks')
                .where('rank_parent_gym_id', isEqualTo: gym.gtIdKey).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.star_outline, size: 48, color: AppColors.primary)),
                  const SizedBox(height: 20),
                  Text('Belum ada rank', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Tambahkan benefit rank untuk member', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.lightSecondaryText)),
                ]));
              }
              return ListView.separated(padding: const EdgeInsets.all(24), itemCount: docs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  return InkWell(
                    onTap: () => _showForm(context, ref, existing: d, docId: docs[i].id),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.08))),
                      child: Row(children: [
                        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(
                          color: const Color(0xFFDB2777).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.star_outline, color: Color(0xFFDB2777), size: 22)),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(d['rank_title_name'] ?? '', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          Text('Min. ${d['rank_min_points_threshold'] ?? 0} poin', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.lightSecondaryText)),
                        ])),
                        Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.35)),
                      ])),
                  );
                });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showForm(context, ref),
        backgroundColor: AppColors.primary, foregroundColor: AppColors.darkBackground, child: const Icon(Icons.add)),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, {Map<String, dynamic>? existing, String? docId}) {
    final titleCtrl = TextEditingController(text: existing?['rank_title_name'] ?? '');
    final pointsCtrl = TextEditingController(text: ((existing?['rank_min_points_threshold'] as num?)?.toInt() ?? '').toString());
    final benefitCtrl = TextEditingController(text: (existing?['rank_benefit_description_list'] as List?)?.join(', ') ?? '');
    final orderCtrl = TextEditingController(text: ((existing?['rank_priority_order'] as num?)?.toInt() ?? '').toString());
    final isEdit = docId != null;

    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 32, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isEdit ? 'Edit Rank' : 'Tambah Rank', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _inp(ctx, 'Nama Rank', titleCtrl), const SizedBox(height: 12),
          _inp(ctx, 'Min. Poin', pointsCtrl, num: true), const SizedBox(height: 12),
          _inp(ctx, 'Benefit (pisahkan dengan koma)', benefitCtrl, maxLines: 3), const SizedBox(height: 12),
          _inp(ctx, 'Urutan Prioritas', orderCtrl, num: true), const SizedBox(height: 24),
          Row(children: [
            if (isEdit) ...[
              Expanded(child: OutlinedButton(onPressed: () async {
                await FirebaseFirestore.instance.collection('gym_master_ranks').doc(docId).delete();
                if (ctx.mounted) Navigator.pop(ctx);
              }, style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Hapus', style: TextStyle(color: AppColors.error)))),
              const SizedBox(width: 12),
            ],
            Expanded(child: FilledButton(onPressed: () async {
              final gymId = ref.read(ownerGymProvider).value?.gtIdKey ?? '';
              final benefits = benefitCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
              if (isEdit) {
                await FirebaseFirestore.instance.collection('gym_master_ranks').doc(docId).update({
                  'rank_title_name': titleCtrl.text, 'rank_min_points_threshold': int.tryParse(pointsCtrl.text) ?? 0,
                  'rank_benefit_description_list': benefits, 'rank_priority_order': int.tryParse(orderCtrl.text) ?? 0,
                });
              } else {
                final r = FirebaseFirestore.instance.collection('gym_master_ranks').doc();
                await r.set({'rank_id_key': r.id, 'rank_parent_gym_id': gymId, 'rank_title_name': titleCtrl.text,
                  'rank_min_points_threshold': int.tryParse(pointsCtrl.text) ?? 0, 'rank_benefit_description_list': benefits,
                  'rank_badge_image_url': '', 'rank_priority_order': int.tryParse(orderCtrl.text) ?? 0, 'rank_is_active': true});
              }
              if (ctx.mounted) Navigator.pop(ctx);
            }, style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.darkBackground,
              padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(isEdit ? 'Simpan' : 'Tambah'))),
          ]),
        ])),
      ),
    );
  }

  Widget _inp(BuildContext ctx, String label, TextEditingController ctrl, {int maxLines = 1, bool num = false}) {
    return TextField(controller: ctrl, maxLines: maxLines, keyboardType: num ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.15)))));
  }
}
