import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/gym_tenant/presentation/providers/gym_tenant_provider.dart';

class OwnerEditGymScreen extends ConsumerStatefulWidget {
  const OwnerEditGymScreen({super.key});
  @override
  ConsumerState<OwnerEditGymScreen> createState() => _State();
}

class _State extends ConsumerState<OwnerEditGymScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();
  final _dailyPriceCtrl = TextEditingController();
  final _memberPriceCtrl = TextEditingController();
  final _facilityCtrl = TextEditingController();

  final List<String> _facilities = [];
  bool _isActive = true;
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _cityCtrl.dispose();
    _locCtrl.dispose();
    _imageCtrl.dispose();
    _hoursCtrl.dispose();
    _dailyPriceCtrl.dispose();
    _memberPriceCtrl.dispose();
    _facilityCtrl.dispose();
    super.dispose();
  }

  void _addFacility() {
    final val = _facilityCtrl.text.trim();
    if (val.isEmpty) return;
    setState(() {
      _facilities.add(val);
      _facilityCtrl.clear();
    });
  }

  void _removeFacility(int index) {
    setState(() => _facilities.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gymAsync = ref.watch(ownerGymProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil Gym', style: TextStyle(fontWeight: FontWeight.bold))),
      body: gymAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (gym) {
          if (gym == null) return const Center(child: Text('Data gym tidak ditemukan'));
          if (!_initialized) {
            _nameCtrl.text = gym.gtNameTitle;
            _descCtrl.text = gym.gtDescriptionText;
            _cityCtrl.text = gym.gtCityName;
            _locCtrl.text = gym.gtLocation;
            _imageCtrl.text = gym.gtImage;
            _hoursCtrl.text = (gym.gtOperationalHours['info'] ?? '').toString();
            _dailyPriceCtrl.text = gym.gtDailyPriceAmount.toInt().toString();
            _memberPriceCtrl.text = gym.gtMembershipPriceAmount.toInt().toString();
            _facilities.clear();
            _facilities.addAll(gym.gtAvailableFacilities);
            _isActive = gym.gtIsActive;
            _initialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // --- Header ---
                Text('Informasi Gym', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _field(theme, 'Nama Gym*', _nameCtrl, Icons.storefront_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama gym wajib diisi' : null),
                const SizedBox(height: 16),
                _field(theme, 'URL Gambar Gym', _imageCtrl, Icons.image_outlined,
                    hint: 'https://...'),
                const SizedBox(height: 16),
                _field(theme, 'Kota', _cityCtrl, Icons.location_city_outlined),
                const SizedBox(height: 16),
                _field(theme, 'Alamat Lengkap', _locCtrl, Icons.location_on_outlined),
                const SizedBox(height: 16),
                _field(theme, 'Deskripsi', _descCtrl, Icons.description_outlined, maxLines: 4),
                const SizedBox(height: 16),
                _field(theme, 'Jam Operasional', _hoursCtrl, Icons.access_time_outlined,
                    hint: 'cth. 06:00 - 22:00'),

                const SizedBox(height: 24),
                Text('Harga Layanan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _numField(theme, 'Harga Harian (Rp)', _dailyPriceCtrl, Icons.today_outlined, validator: (v) {
                  if (v == null || v.trim().isEmpty) return null; // optional
                  if (double.tryParse(v.trim()) == null) return 'Harus berupa angka';
                  return null;
                }),
                const SizedBox(height: 16),
                _numField(theme, 'Harga Membership (Rp)', _memberPriceCtrl, Icons.card_membership_outlined, validator: (v) {
                  if (v == null || v.trim().isEmpty) return null; // optional
                  if (double.tryParse(v.trim()) == null) return 'Harus berupa angka';
                  return null;
                }),

                const SizedBox(height: 24),
                Text('Fasilitas', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _facilityCtrl,
                      decoration: InputDecoration(
                        hintText: 'cth. Kolam Renang, Sauna',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.15)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onSubmitted: (_) => _addFacility(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addFacility,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.darkBackground,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ]),
                if (_facilities.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _facilities.asMap().entries.map((entry) {
                      return Chip(
                        label: Text(entry.value),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _removeFacility(entry.key),
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Status Aktif Gym', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Gym akan muncul di pencarian member jika aktif'),
                  value: _isActive,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isActive = val),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : () => _save(gym.gtIdKey),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.darkBackground,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _saving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Simpan Perubahan'),
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _field(
    ThemeData theme,
    String label,
    TextEditingController ctrl,
    IconData icon, {
    int maxLines = 1,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: maxLines == 1 ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.15)),
        ),
        errorMaxLines: 2,
      ),
      validator: validator,
    );
  }

  Widget _numField(
    ThemeData theme,
    String label,
    TextEditingController ctrl,
    IconData icon, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        errorMaxLines: 2,
      ),
      validator: validator,
    );
  }

  Future<void> _save(String gymId) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final updateData = <String, dynamic>{
        'gt_name_title': _nameCtrl.text.trim(),
        'gt_description_text': _descCtrl.text.trim(),
        'gt_city_name': _cityCtrl.text.trim(),
        'gt_location': _locCtrl.text.trim(),
        'gt_image': _imageCtrl.text.trim(),
        'gt_operational_hours': {'info': _hoursCtrl.text.trim()},
        'gt_available_facilities': _facilities,
        'gt_is_active': _isActive,
      };
      final dailyPrice = double.tryParse(_dailyPriceCtrl.text.trim());
      if (dailyPrice != null) updateData['gt_daily_price_amount'] = dailyPrice;
      final memberPrice = double.tryParse(_memberPriceCtrl.text.trim());
      if (memberPrice != null) updateData['gt_membership_price_amount'] = memberPrice;

      await FirebaseFirestore.instance.collection('gym_tenants').doc(gymId).update(updateData);
      ref.invalidate(ownerGymProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil gym berhasil diperbarui')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
      }
    }
    setState(() => _saving = false);
  }
}
