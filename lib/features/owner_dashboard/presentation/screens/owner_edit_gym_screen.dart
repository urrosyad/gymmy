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
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() { _nameCtrl.dispose(); _descCtrl.dispose(); _cityCtrl.dispose(); _locCtrl.dispose(); super.dispose(); }

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
            _initialized = true;
          }
          return SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _field(theme, 'Nama Gym', _nameCtrl, Icons.storefront_outlined),
            const SizedBox(height: 16),
            _field(theme, 'Kota', _cityCtrl, Icons.location_city_outlined),
            const SizedBox(height: 16),
            _field(theme, 'Alamat Lengkap', _locCtrl, Icons.location_on_outlined),
            const SizedBox(height: 16),
            _field(theme, 'Deskripsi', _descCtrl, Icons.description_outlined, maxLines: 4),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: _saving ? null : () => _save(gym.gtIdKey),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.darkBackground,
                padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Simpan Perubahan'),
            )),
          ]));
        },
      ),
    );
  }

  Widget _field(ThemeData theme, String label, TextEditingController ctrl, IconData icon, {int maxLines = 1}) {
    return TextField(controller: ctrl, maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: maxLines == 1 ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.15)))));
  }

  Future<void> _save(String gymId) async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('gym_tenants').doc(gymId).update({
        'gt_name_title': _nameCtrl.text, 'gt_description_text': _descCtrl.text,
        'gt_city_name': _cityCtrl.text, 'gt_location': _locCtrl.text,
      });
      ref.invalidate(ownerGymProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil gym berhasil diperbarui')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
    setState(() => _saving = false);
  }
}
