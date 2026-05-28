import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/gym_tenant/presentation/providers/gym_tenant_provider.dart';
import 'package:image_picker/image_picker.dart';

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
            stream: FirebaseFirestore.instance
                .collection('gym_equipments')
                .where('equip_parent_gym_id', isEqualTo: gym.gtIdKey)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) return _emptyState(theme);
              return ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: docs.length,
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
        onPressed: () => _showForm(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.darkBackground,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _emptyState(ThemeData theme) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.fitness_center, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text('Belum ada peralatan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Tambahkan peralatan gym Anda', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.lightSecondaryText)),
        ]),
      );

  Widget _tile(BuildContext ctx, WidgetRef ref, Map<String, dynamic> d, String docId, ThemeData theme) {
    return InkWell(
      onTap: () => _showForm(ctx, ref, existing: d, docId: docId),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
        ),
        child: Row(children: [
          if ((d['equip_image_storage_url'] ?? '').toString().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                d['equip_image_storage_url'],
                width: 48, height: 48, fit: BoxFit.cover,
                errorBuilder: (ctx2, e, stackTrace) => _equipIcon(),
              ),
            )
          else
            _equipIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d['equip_name_label'] ?? '', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              if ((d['equip_category_type'] ?? '').toString().isNotEmpty)
                Text(d['equip_category_type'], style: theme.textTheme.bodySmall?.copyWith(color: AppColors.lightSecondaryText)),
            ]),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.35)),
        ]),
      ),
    );
  }

  Widget _equipIcon() => Container(
    width: 48, height: 48,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: const Color(0xFFD97706).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
    child: const Icon(Icons.fitness_center, color: Color(0xFFD97706), size: 22),
  );

  void _showForm(BuildContext context, WidgetRef ref, {Map<String, dynamic>? existing, String? docId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _EquipmentForm(
        ref: ref,
        existing: existing,
        docId: docId,
      ),
    );
  }
}

class _EquipmentForm extends StatefulWidget {
  final WidgetRef ref;
  final Map<String, dynamic>? existing;
  final String? docId;

  const _EquipmentForm({
    required this.ref,
    this.existing,
    this.docId,
  });

  @override
  State<_EquipmentForm> createState() => _EquipmentFormState();
}

class _EquipmentFormState extends State<_EquipmentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _catCtrl;
  late final TextEditingController _instrCtrl;

  File? _pickedImage;
  File? _pickedVideo;
  String? _existingImageUrl;
  String? _existingVideoUrl;

  bool _isSaving = false;
  String? _uploadStatus;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?['equip_name_label'] ?? '');
    _catCtrl = TextEditingController(text: widget.existing?['equip_category_type'] ?? '');
    _instrCtrl = TextEditingController(text: widget.existing?['equip_usage_instruction_text'] ?? '');
    _existingImageUrl = widget.existing?['equip_image_storage_url'];
    _existingVideoUrl = widget.existing?['equip_tutorial_video_link'];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _catCtrl.dispose();
    _instrCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (pickedFile != null) {
        setState(() {
          _pickedVideo = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih video: $e')),
        );
      }
    }
  }

  Future<String> _uploadFile(File file, String storagePath) async {
    final ref = FirebaseStorage.instance.ref().child(storagePath);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final nav = Navigator.of(context);

    if (widget.docId == null && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gambar peralatan wajib dipilih')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _uploadStatus = 'Menyiapkan...';
    });

    try {
      final gymId = widget.ref.read(ownerGymProvider).value?.gtIdKey ?? '';
      final equipId = widget.docId ?? FirebaseFirestore.instance.collection('gym_equipments').doc().id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      String imageUrl = _existingImageUrl ?? '';
      String videoUrl = _existingVideoUrl ?? '';

      // Upload image
      if (_pickedImage != null) {
        setState(() {
          _uploadStatus = 'Mengunggah gambar ke Cloud Storage...';
        });
        final ext = _pickedImage!.path.split('.').last;
        final path = 'gym_equipments/$gymId/$equipId/image_$timestamp.$ext';
        imageUrl = await _uploadFile(_pickedImage!, path);
      }

      // Upload video
      if (_pickedVideo != null) {
        setState(() {
          _uploadStatus = 'Mengunggah video ke Cloud Storage...';
        });
        final ext = _pickedVideo!.path.split('.').last;
        final path = 'gym_equipments/$gymId/$equipId/video_$timestamp.$ext';
        videoUrl = await _uploadFile(_pickedVideo!, path);
      }

      setState(() {
        _uploadStatus = 'Menyimpan data peralatan...';
      });

      if (widget.docId != null) {
        await FirebaseFirestore.instance.collection('gym_equipments').doc(widget.docId).update({
          'equip_name_label': _nameCtrl.text.trim(),
          'equip_category_type': _catCtrl.text.trim(),
          'equip_image_storage_url': imageUrl,
          'equip_usage_instruction_text': _instrCtrl.text.trim(),
          'equip_tutorial_video_link': videoUrl,
          'equip_last_updated_at': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseFirestore.instance.collection('gym_equipments').doc(equipId).set({
          'equip_id_key': equipId,
          'equip_parent_gym_id': gymId,
          'equip_name_label': _nameCtrl.text.trim(),
          'equip_image_storage_url': imageUrl,
          'equip_usage_instruction_text': _instrCtrl.text.trim(),
          'equip_tutorial_video_link': videoUrl,
          'equip_is_active_status': true,
          'equip_created_at': FieldValue.serverTimestamp(),
          'equip_last_updated_at': FieldValue.serverTimestamp(),
          'equip_category_type': _catCtrl.text.trim(),
          'equip_total_usage_count': 0,
        });
      }

      if (mounted) nav.pop();
    } catch (e) {
      setState(() {
        _isSaving = false;
        _uploadStatus = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.docId != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 32, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Ubah Peralatan' : 'Tambah Peralatan',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Nama
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Peralatan*',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama peralatan wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Kategori
              TextFormField(
                controller: _catCtrl,
                decoration: InputDecoration(
                  labelText: 'Kategori*',
                  hintText: 'cth. Kardio, Kekuatan, Fleksibilitas',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Kategori wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Image Picker
              Text('Gambar Peralatan*', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _isSaving ? null : _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.15), width: 1.5),
                  ),
                  child: _pickedImage != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.file(_pickedImage!, width: double.infinity, height: 160, fit: BoxFit.cover),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
                                child: const Row(
                                  children: [
                                    Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text('Ganti', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.network(_existingImageUrl!, width: double.infinity, height: 160, fit: BoxFit.cover, errorBuilder: (_, e, st) => _imagePlaceholder()),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                        SizedBox(width: 4),
                                        Text('Ganti', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : _imagePlaceholder()),
                ),
              ),
              const SizedBox(height: 16),

              // Instruksi
              TextFormField(
                controller: _instrCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Instruksi Penggunaan*',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Instruksi penggunaan wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Video Picker
              Text('Video Tutorial (opsional)', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _isSaving ? null : _pickVideo,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.15), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                        child: Icon(_pickedVideo != null || (_existingVideoUrl != null && _existingVideoUrl!.isNotEmpty) ? Icons.videocam : Icons.videocam_outlined, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _pickedVideo != null
                              ? _pickedVideo!.path.split('/').last
                              : (_existingVideoUrl != null && _existingVideoUrl!.isNotEmpty ? 'Video tersimpan' : 'Ketuk untuk memilih video'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _pickedVideo != null || (_existingVideoUrl != null && _existingVideoUrl!.isNotEmpty) ? null : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        _pickedVideo != null || (_existingVideoUrl != null && _existingVideoUrl!.isNotEmpty) ? Icons.check_circle : Icons.upload_file,
                        color: _pickedVideo != null || (_existingVideoUrl != null && _existingVideoUrl!.isNotEmpty) ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Upload status / indicator
              if (_isSaving && _uploadStatus != null) ...[
                Text(_uploadStatus!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const LinearProgressIndicator(
                  backgroundColor: Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 16),
              ],

              // Buttons
              Row(
                children: [
                  if (isEdit) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () async {
                                final nav = Navigator.of(context);
                                try {
                                  if (_existingImageUrl != null && _existingImageUrl!.contains('firebasestorage')) {
                                    await FirebaseStorage.instance.refFromURL(_existingImageUrl!).delete();
                                  }
                                  if (_existingVideoUrl != null && _existingVideoUrl!.contains('firebasestorage')) {
                                    await FirebaseStorage.instance.refFromURL(_existingVideoUrl!).delete();
                                  }
                                } catch (_) {}
                                await FirebaseFirestore.instance.collection('gym_equipments').doc(widget.docId).delete();
                                if (mounted) nav.pop();
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
                      onPressed: _isSaving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.darkBackground,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkBackground))
                          : Text(isEdit ? 'Simpan' : 'Tambah'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: 40, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
          const SizedBox(height: 8),
          Text(
            'Ketuk untuk memilih gambar',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}
