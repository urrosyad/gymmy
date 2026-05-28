import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/gym_tenant/domain/entities/gym_tenant_entity.dart';
import 'package:gymmy/features/gym_tenant/presentation/providers/gym_tenant_provider.dart';
import 'package:gymmy/features/gym_tenant/presentation/screens/gym_detail_screen.dart';
import 'package:intl/intl.dart';

class GymDiscoveryScreen extends ConsumerStatefulWidget {
  const GymDiscoveryScreen({super.key});
  @override
  ConsumerState<GymDiscoveryScreen> createState() => _GymDiscoveryScreenState();
}

class _GymDiscoveryScreenState extends ConsumerState<GymDiscoveryScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;
    final gymsAsync = ref.watch(gymListProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('GYMMY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Halo, ${user?.fullName.split(' ').first ?? ''}',
                style: theme.textTheme.titleMedium?.copyWith(color: AppColors.lightSecondaryText)),
              const SizedBox(height: 2),
              Text('Cari gym Anda', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Cari gym...',
                  prefixIcon: const Icon(Icons.search_outlined, size: 20),
                  suffixIcon: _query.isNotEmpty ? IconButton(icon: const Icon(Icons.close, size: 18),
                    onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); }) : null,
                  filled: true, fillColor: theme.colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.15))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.15))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.secondary, width: 1.5)),
                ),
              ),
              const SizedBox(height: 24),
              Text('Gym Tersedia', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
            ]),
          ),
          Expanded(
            child: gymsAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32), itemCount: 4,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => Container(height: 200, decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)))),
              error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.wifi_off_outlined, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('Gagal memuat daftar gym.', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Periksa koneksi Anda dan coba lagi.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.lightSecondaryText), textAlign: TextAlign.center),
                ]))),
              data: (gyms) {
                final filtered = _query.isEmpty ? gyms
                    : gyms.where((g) => g.gtNameTitle.toLowerCase().contains(_query) || g.gtCityName.toLowerCase().contains(_query)).toList();
                if (filtered.isEmpty) {
                  return Center(child: Padding(padding: const EdgeInsets.all(32),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.search_off_outlined, size: 56, color: theme.colorScheme.onSurface.withValues(alpha: 0.25)),
                      const SizedBox(height: 16),
                      Text(_query.isEmpty ? 'Belum ada gym.' : 'Tidak ada hasil.',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(_query.isEmpty ? 'Kembali lagi nanti saat ada gym baru.' : 'Coba nama atau kota lain.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.lightSecondaryText), textAlign: TextAlign.center),
                    ])));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32), itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _GymCard(gym: filtered[i],
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GymDetailScreen(gym: filtered[i])))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GymCard extends StatelessWidget {
  final GymTenantEntity gym;
  final VoidCallback onTap;
  const _GymCard({required this.gym, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.08))),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 130, color: AppColors.lightSecondaryText.withValues(alpha: 0.08),
            child: gym.gtImage.isNotEmpty
                ? Image.network(gym.gtImage, width: double.infinity, height: 130, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _placeholder())
                : _placeholder()),
          Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(gym.gtNameTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (gym.gtRate > 0) ...[
                Icon(Icons.star_rounded, size: 15, color: Colors.amber.shade600),
                const SizedBox(width: 2),
                Text(gym.gtRate.toStringAsFixed(1), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 13, color: AppColors.lightSecondaryText),
              const SizedBox(width: 4),
              Expanded(child: Text('${gym.gtCityName} - ${gym.gtLocation}',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.lightSecondaryText),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _PriceTag(label: 'Harian', value: currency.format(gym.gtDailyPriceAmount)),
              const SizedBox(width: 8),
              _PriceTag(label: 'Membership', value: currency.format(gym.gtMembershipPriceAmount), highlight: true),
            ]),
            if (gym.gtAvailableFacilities.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 4, children: gym.gtAvailableFacilities.take(4).map((f) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: theme.colorScheme.onSurface.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4)),
                child: Text(f, style: theme.textTheme.labelSmall?.copyWith(color: AppColors.lightSecondaryText)),
              )).toList()),
            ],
          ])),
        ]),
      ),
    );
  }

  Widget _placeholder() => Center(child: Icon(Icons.fitness_center_outlined, size: 40,
      color: AppColors.lightSecondaryText.withValues(alpha: 0.3)));
}

class _PriceTag extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _PriceTag({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primary.withValues(alpha: 0.15) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.lightSecondaryText, fontSize: 10)),
        Text(value, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold,
          color: highlight ? const Color(0xFF4A6A00) : Theme.of(context).colorScheme.onSurface)),
      ]),
    );
  }
}
