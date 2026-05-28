import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/gym_tenant/presentation/providers/gym_tenant_provider.dart';
import 'package:intl/intl.dart';

class OwnerClassScreen extends ConsumerWidget {
  const OwnerClassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gymAsync = ref.watch(ownerGymProvider);
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelas Gym', style: TextStyle(fontWeight: FontWeight.bold))),
      body: gymAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (gym) {
          if (gym == null) return const Center(child: Text('Data gym tidak ditemukan'));
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('gym_classes_catalog')
                .where('class_parent_gym_id', isEqualTo: gym.gtIdKey)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.event_note, size: 48, color: AppColors.primary),
                    ),
                    const SizedBox(height: 20),
                    Text('Belum ada kelas', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('Tambahkan kelas gym Anda', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.lightSecondaryText)),
                  ]),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: docs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  return InkWell(
                    onTap: () => _showForm(context, ref, existing: d, docId: docs[i].id),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
                      ),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFF059669).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.event_note, color: Color(0xFF059669), size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: Text(d['class_title_name'] ?? '', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
                              if (d['class_is_personal_trainer'] == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('PT', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                            ]),
                            Text(
                              currency.format((d['class_pricing_amount'] as num?)?.toDouble() ?? 0),
                              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.lightSecondaryText),
                            ),
                          ]),
                        ),
                        Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.35)),
                      ]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.darkBackground,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, {Map<String, dynamic>? existing, String? docId}) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: existing?['class_title_name'] ?? '');
    final priceCtrl = TextEditingController(text: ((existing?['class_pricing_amount'] as num?)?.toInt() ?? '').toString());
    final schedCtrl = TextEditingController(text: existing?['class_schedule_text'] ?? '');
    final sessCtrl = TextEditingController(text: ((existing?['class_session_count'] as num?)?.toInt() ?? '').toString());
    final descCtrl = TextEditingController(text: existing?['class_description_text'] ?? '');
    final capCtrl = TextEditingController(text: ((existing?['class_max_capacity'] as num?)?.toInt() ?? 20).toString());
    bool isPT = existing?['class_is_personal_trainer'] ?? false;
    final isEdit = docId != null;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBS) => Padding(
          padding: EdgeInsets.fromLTRB(24, 32, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  isEdit ? 'Ubah Kelas' : 'Tambah Kelas',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _field(ctx, 'Nama Kelas*', titleCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama kelas wajib diisi' : null),
                const SizedBox(height: 12),
                _field(ctx, 'Harga (Rp)*', priceCtrl, num: true, validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Harga wajib diisi';
                  final n = double.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Harga harus lebih dari 0';
                  return null;
                }),
                const SizedBox(height: 12),
                _field(ctx, 'Jadwal*', schedCtrl, hint: 'cth. Senin & Rabu, 07:00-09:00',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Jadwal wajib diisi' : null),
                const SizedBox(height: 12),
                _field(ctx, 'Jumlah Sesi*', sessCtrl, num: true, validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Jumlah sesi wajib diisi';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Jumlah sesi harus lebih dari 0';
                  return null;
                }),
                const SizedBox(height: 12),
                _field(ctx, 'Deskripsi*', descCtrl, maxLines: 3,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Deskripsi wajib diisi' : null),
                const SizedBox(height: 12),
                _field(ctx, 'Kapasitas Maks*', capCtrl, num: true, validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Kapasitas wajib diisi';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Kapasitas harus lebih dari 0';
                  return null;
                }),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Personal Trainer'),
                  value: isPT,
                  onChanged: (v) => setBS(() => isPT = v),
                  activeThumbColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                Row(children: [
                  if (isEdit) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSaving ? null : () async {
                          await FirebaseFirestore.instance.collection('gym_classes_catalog').doc(docId).delete();
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: isSaving ? null : () async {
                        if (!formKey.currentState!.validate()) return;
                        setBS(() => isSaving = true);
                        try {
                          final gymId = ref.read(ownerGymProvider).value?.gtIdKey ?? '';
                          final map = <String, dynamic>{
                            'class_title_name': titleCtrl.text.trim(),
                            'class_pricing_amount': double.tryParse(priceCtrl.text.trim()) ?? 0,
                            'class_schedule_text': schedCtrl.text.trim(),
                            'class_session_count': int.tryParse(sessCtrl.text.trim()) ?? 0,
                            'class_description_text': descCtrl.text.trim(),
                            'class_max_capacity': int.tryParse(capCtrl.text.trim()) ?? 20,
                            'class_is_personal_trainer': isPT,
                          };
                          if (isEdit) {
                            await FirebaseFirestore.instance.collection('gym_classes_catalog').doc(docId).update(map);
                          } else {
                            final r = FirebaseFirestore.instance.collection('gym_classes_catalog').doc();
                            map['class_id_key'] = r.id;
                            map['class_parent_gym_id'] = gymId;
                            map['class_thumbnail_image_url'] = '';
                            map['class_current_subscribers'] = 0;
                            map['class_is_active'] = true;
                            await r.set(map);
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          setBS(() => isSaving = false);
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
                          }
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.darkBackground,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(isEdit ? 'Simpan' : 'Tambah'),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    BuildContext ctx,
    String label,
    TextEditingController ctrl, {
    String? hint,
    int maxLines = 1,
    bool num = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: num ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.15)),
        ),
        errorMaxLines: 2,
      ),
      validator: validator,
    );
  }
}
