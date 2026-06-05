import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/gym_tenant/presentation/providers/gym_tenant_provider.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_edit_gym_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/widgets/owner_top_bar.dart';

class OwnerEquipmentScreen extends ConsumerStatefulWidget {
  final bool openCreateOnLoad;

  const OwnerEquipmentScreen({super.key, this.openCreateOnLoad = false});

  @override
  ConsumerState<OwnerEquipmentScreen> createState() =>
      _OwnerEquipmentScreenState();
}

class _OwnerEquipmentScreenState extends ConsumerState<OwnerEquipmentScreen> {
  bool _openedInitialForm = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gymAsync = ref.watch(ownerGymProvider);
    final ownerName = ref.watch(authProvider).user?.fullName ?? 'Owner Gym';

    return Scaffold(
      appBar: OwnerTopBar(
        ownerName: ownerName,
        onAvatarTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OwnerEditGymScreen()),
        ),
      ),
      body: gymAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (gym) {
          if (gym == null) {
            return const Center(child: Text('Data gym tidak ditemukan'));
          }
          if (widget.openCreateOnLoad && !_openedInitialForm) {
            _openedInitialForm = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _showForm(context, ref);
            });
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: Text(
                  'Peralatan Gym',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
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
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 96),
                      itemCount: docs.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.06,
                        ),
                      ),
                      itemBuilder: (context, i) {
                        final d = docs[i].data() as Map<String, dynamic>;
                        return _tile(context, ref, d, docs[i].id, theme);
                      },
                    );
                  },
                ),
              ),
            ],
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
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.fitness_center,
            size: 48,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Belum ada peralatan',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tambahkan peralatan gym Anda',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.lightSecondaryText,
          ),
        ),
      ],
    ),
  );

  Widget _tile(
    BuildContext ctx,
    WidgetRef ref,
    Map<String, dynamic> d,
    String docId,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () => _showForm(ctx, ref, existing: d, docId: docId),
      child: Container(
        color: theme.colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          children: [
            if (_equipmentImageUrl(d).isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  _equipmentImageUrl(d),
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx2, e, stackTrace) => _imageFallback(theme),
                ),
              )
            else
              _imageFallback(theme),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d['equip_name_label'] ?? '',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if ((d['equip_category_type'] ?? '').toString().isNotEmpty)
                    Text(
                      d['equip_category_type'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.lightSecondaryText,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }

  String _equipmentImageUrl(Map<String, dynamic> data) {
    final value = (data['equip_image_storage_url'] ?? '').toString().trim();
    if (value.isEmpty) return '';
    final uri = Uri.tryParse(value);
    if (uri == null) return value;
    if (uri.host.contains('drive.google.com')) {
      final segments = uri.pathSegments;
      final fileIndex = segments.indexOf('d');
      if (fileIndex != -1 && fileIndex + 1 < segments.length) {
        return 'https://drive.google.com/uc?export=view&id=${segments[fileIndex + 1]}';
      }
      final id = uri.queryParameters['id'];
      if (id != null && id.isNotEmpty) {
        return 'https://drive.google.com/uc?export=view&id=$id';
      }
    }
    if (uri.host.contains('dropbox.com')) {
      return uri
          .replace(queryParameters: {...uri.queryParameters, 'raw': '1'})
          .toString();
    }
    return value;
  }

  Widget _imageFallback(ThemeData theme) => SizedBox(
    width: 96,
    height: 96,
    child: Icon(
      Icons.image_not_supported_outlined,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.28),
      size: 30,
    ),
  );

  void _showForm(
    BuildContext context,
    WidgetRef ref, {
    Map<String, dynamic>? existing,
    String? docId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) =>
          _EquipmentForm(ref: ref, existing: existing, docId: docId),
    );
  }
}

class _EquipmentForm extends StatefulWidget {
  final WidgetRef ref;
  final Map<String, dynamic>? existing;
  final String? docId;

  const _EquipmentForm({required this.ref, this.existing, this.docId});

  @override
  State<_EquipmentForm> createState() => _EquipmentFormState();
}

class _EquipmentFormState extends State<_EquipmentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _catCtrl;
  late final TextEditingController _instrCtrl;
  late final TextEditingController _imageUrlCtrl;
  late final TextEditingController _videoUrlCtrl;

  bool _isSaving = false;
  String? _uploadStatus;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: widget.existing?['equip_name_label'] ?? '',
    );
    _catCtrl = TextEditingController(
      text: widget.existing?['equip_category_type'] ?? '',
    );
    _instrCtrl = TextEditingController(
      text: widget.existing?['equip_usage_instruction_text'] ?? '',
    );
    _imageUrlCtrl = TextEditingController(
      text: widget.existing?['equip_image_storage_url'] ?? '',
    );
    _videoUrlCtrl = TextEditingController(
      text: widget.existing?['equip_tutorial_video_link'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _catCtrl.dispose();
    _instrCtrl.dispose();
    _imageUrlCtrl.dispose();
    _videoUrlCtrl.dispose();
    super.dispose();
  }

  bool _isValidUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final nav = Navigator.of(context);

    setState(() {
      _isSaving = true;
      _uploadStatus = 'Menyimpan data peralatan...';
    });

    try {
      final gymId = widget.ref.read(ownerGymProvider).value?.gtIdKey ?? '';
      final equipId =
          widget.docId ??
          FirebaseFirestore.instance.collection('gym_equipments').doc().id;
      final imageUrl = _imageUrlCtrl.text.trim();
      final videoUrl = _videoUrlCtrl.text.trim();

      if (widget.docId != null) {
        await FirebaseFirestore.instance
            .collection('gym_equipments')
            .doc(widget.docId)
            .update({
              'equip_name_label': _nameCtrl.text.trim(),
              'equip_category_type': _catCtrl.text.trim(),
              'equip_image_storage_url': imageUrl,
              'equip_usage_instruction_text': _instrCtrl.text.trim(),
              'equip_tutorial_video_link': videoUrl,
              'equip_last_updated_at': FieldValue.serverTimestamp(),
            });
      } else {
        await FirebaseFirestore.instance
            .collection('gym_equipments')
            .doc(equipId)
            .set({
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data peralatan berhasil disimpan')),
        );
        nav.pop();
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _uploadStatus = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data peralatan')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.docId != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        32,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Ubah Peralatan' : 'Tambah Peralatan',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Nama
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Peralatan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama peralatan wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),

              // Kategori
              TextFormField(
                controller: _catCtrl,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  hintText: 'cth. Kardio, Kekuatan, Fleksibilitas',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Kategori wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _imageUrlCtrl,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'URL Gambar',
                  hintText: 'https://contoh.com/gambar.jpg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'URL gambar wajib diisi';
                  if (!_isValidUrl(value)) return 'URL gambar tidak valid';
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              _imagePreview(theme),
              const SizedBox(height: 16),

              // Instruksi
              TextFormField(
                controller: _instrCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Instruksi Penggunaan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Instruksi penggunaan wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _videoUrlCtrl,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'URL Video Tutorial (opsional)',
                  hintText: 'https://youtube.com/...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isNotEmpty && !_isValidUrl(value)) {
                    return 'URL video tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Upload status / indicator
              if (_isSaving && _uploadStatus != null) ...[
                Text(
                  _uploadStatus!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                                await FirebaseFirestore.instance
                                    .collection('gym_equipments')
                                    .doc(widget.docId)
                                    .delete();
                                if (mounted) nav.pop();
                              },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(color: AppColors.error),
                        ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.darkBackground,
                              ),
                            )
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
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 40,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 8),
          Text(
            'Ketuk untuk memilih gambar',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePreview(ThemeData theme) {
    final imageUrl = _imageUrlCtrl.text.trim();

    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: imageUrl.isEmpty
          ? _imagePlaceholder()
          : ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, e, st) => _imagePlaceholder(),
              ),
            ),
    );
  }
}
