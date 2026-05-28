import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/gym_tenant/presentation/providers/gym_tenant_provider.dart';

class OwnerEquipmentScreen extends ConsumerWidget {
  const OwnerEquipmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gymAsync = ref.watch(ownerGymProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Peralatan Gym', style: TextStyle(fontWeight: FontWeight.bold))),
      body: gymAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (gym) {
          if (gym == null) return const Center(child: Text('Data gym tidak ditemukan'));
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('gym_equipments')
                .where('equip_parent_gym_id', isEqualTo: gym.gtIdKey).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) return _emptyState(theme);
              return ListView.separated(
                padding: const EdgeInsets.all(24), itemCount: docs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  return _tile(context, ref, d, docs[i].id, theme);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref), backgroundColor: AppColors.primary,
        foregroundColor: AppColors.darkBackground, child: const Icon(Icons.add)),
    );
  }

  Widget _emptyState(ThemeData theme) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: const Icon(Icons.fitness_center, size: 48, color: AppColors.primary)),
    const SizedBox(height: 20),
    Text('Belum ada peralatan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
    const SizedBox(height: 8),
    Text('Tambahkan peralatan gym Anda', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.lightSecondaryText)),
  ]));

  Widget _tile(BuildContext ctx, WidgetRef ref, Map<String, dynamic> d, String docId, ThemeData theme) {
    return InkWell(
      onTap: () => _showForm(ctx, ref, existing: d, docId: docId),
      borderRadius: BorderRadius.circular(14),
      child: Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.08))),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(
            color: const Color(0xFFD97706).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.fitness_center, color: Color(0xFFD97706), size: 22)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d['equip_name_label'] ?? '', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            if ((d['equip_category_type'] ?? '').toString().isNotEmpty)
              Text(d['equip_category_type'], style: theme.textTheme.bodySmall?.copyWith(color: AppColors.lightSecondaryText)),
          ])),
          Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.35)),
        ])),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, {Map<String, dynamic>? existing, String? docId}) {
    final nameCtrl = TextEditingController(text: existing?['equip_name_label'] ?? '');
    final catCtrl = TextEditingController(text: existing?['equip_category_type'] ?? '');
    final instrCtrl = TextEditingController(text: existing?['equip_usage_instruction_text'] ?? '');
    final linkCtrl = TextEditingController(text: existing?['equip_tutorial_video_link'] ?? '');
    final isEdit = docId != null;

    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 32, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isEdit ? 'Edit Peralatan' : 'Tambah Peralatan', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _input(ctx, 'Nama Peralatan', nameCtrl),
          const SizedBox(height: 12),
          _input(ctx, 'Kategori', catCtrl),
          const SizedBox(height: 12),
          _input(ctx, 'Instruksi Penggunaan', instrCtrl, maxLines: 3),
          const SizedBox(height: 12),
          _input(ctx, 'Link Tutorial (opsional)', linkCtrl),
          const SizedBox(height: 24),
          Row(children: [
            if (isEdit) ...[
              Expanded(child: OutlinedButton(onPressed: () async {
                await FirebaseFirestore.instance.collection('gym_equipments').doc(docId).delete();
                if (ctx.mounted) Navigator.pop(ctx);
              }, style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Hapus', style: TextStyle(color: AppColors.error)))),
              const SizedBox(width: 12),
            ],
            Expanded(child: FilledButton(onPressed: () async {
              final gymId = ref.read(ownerGymProvider).value?.gtIdKey ?? '';
              if (isEdit) {
                await FirebaseFirestore.instance.collection('gym_equipments').doc(docId).update({
                  'equip_name_label': nameCtrl.text, 'equip_category_type': catCtrl.text,
                  'equip_usage_instruction_text': instrCtrl.text, 'equip_tutorial_video_link': linkCtrl.text,
                  'equip_last_updated_at': FieldValue.serverTimestamp()});
              } else {
                final r = FirebaseFirestore.instance.collection('gym_equipments').doc();
                await r.set({'equip_id_key': r.id, 'equip_parent_gym_id': gymId, 'equip_name_label': nameCtrl.text,
                  'equip_image_storage_url': '', 'equip_usage_instruction_text': instrCtrl.text,
                  'equip_tutorial_video_link': linkCtrl.text, 'equip_is_active_status': true,
                  'equip_created_at': FieldValue.serverTimestamp(), 'equip_last_updated_at': FieldValue.serverTimestamp(),
                  'equip_category_type': catCtrl.text, 'equip_total_usage_count': 0});
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

  Widget _input(BuildContext ctx, String label, TextEditingController ctrl, {int maxLines = 1}) {
    return TextField(controller: ctrl, maxLines: maxLines,
      decoration: InputDecoration(labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.15)))));
  }
}
