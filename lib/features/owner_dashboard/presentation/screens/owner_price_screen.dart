import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/gym_tenant/presentation/providers/gym_tenant_provider.dart';

class OwnerPriceScreen extends ConsumerStatefulWidget {
  const OwnerPriceScreen({super.key});
  @override
  ConsumerState<OwnerPriceScreen> createState() => _State();
}

class _State extends ConsumerState<OwnerPriceScreen> {
  final _dailyCtrl = TextEditingController();
  final _memberCtrl = TextEditingController();
  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() { _dailyCtrl.dispose(); _memberCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gymAsync = ref.watch(ownerGymProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Harga Paket', style: TextStyle(fontWeight: FontWeight.bold))),
      body: gymAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (gym) {
          if (gym == null) return const Center(child: Text('Data gym tidak ditemukan'));
          if (!_initialized) {
            _dailyCtrl.text = gym.gtDailyPriceAmount.toInt().toString();
            _memberCtrl.text = gym.gtMembershipPriceAmount.toInt().toString();
            _initialized = true;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Atur Harga Layanan', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Perbarui harga harian dan membership gym', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.lightSecondaryText)),
              const SizedBox(height: 32),
              _field(theme, 'Harga Harian (Rp)', _dailyCtrl, Icons.today_outlined),
              const SizedBox(height: 20),
              _field(theme, 'Harga Membership Bulanan (Rp)', _memberCtrl, Icons.card_membership_outlined),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, child: FilledButton(
                onPressed: _loading ? null : () => _save(gym.gtIdKey),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.darkBackground,
                  padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Simpan Harga'),
              )),
            ]),
          );
        },
      ),
    );
  }

  Widget _field(ThemeData theme, String label, TextEditingController ctrl, IconData icon) {
    return TextField(
      controller: ctrl, keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.15))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5))),
    );
  }

  Future<void> _save(String gymId) async {
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('gym_tenants').doc(gymId).update({
        'gt_daily_price_amount': double.tryParse(_dailyCtrl.text) ?? 0,
        'gt_membership_price_amount': double.tryParse(_memberCtrl.text) ?? 0,
      });
      ref.invalidate(ownerGymProvider);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harga berhasil diperbarui')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
    setState(() => _loading = false);
  }
}
