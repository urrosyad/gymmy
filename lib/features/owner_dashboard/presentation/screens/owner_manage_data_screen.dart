import 'package:flutter/material.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_price_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_equipment_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_class_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_rank_screen.dart';

class OwnerManageDataScreen extends StatelessWidget {
  const OwnerManageDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('GYMMY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)), automaticallyImplyLeading: false),
      body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Kelola Data', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Atur data dan informasi gym kamu', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        const SizedBox(height: 24),
        _cat(context, 'Harga & Paket', [
          _MI(Icons.today_outlined, 'Harga Paket', 'Atur harga harian dan membership', const Color(0xFF0891B2),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerPriceScreen()))),
        ]),
        const SizedBox(height: 20),
        _cat(context, 'Fasilitas', [
          _MI(Icons.fitness_center, 'Peralatan Gym', 'Daftar alat gym yang tersedia', const Color(0xFFD97706),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerEquipmentScreen()))),
          _MI(Icons.event_note, 'Kelas Gym', 'Jadwal dan daftar kelas fitness', const Color(0xFF059669),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerClassScreen()))),
        ]),
        const SizedBox(height: 20),
        _cat(context, 'Benefit & Rank', [
          _MI(Icons.star_outline, 'Data Benefit Rank', 'Atur keuntungan setiap level member', const Color(0xFFDB2777),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerRankScreen()))),
        ]),
      ])),
    );
  }

  Widget _cat(BuildContext ctx, String title, List<_MI> items) {
    final theme = Theme.of(ctx);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _tile(ctx, item))),
    ]);
  }

  Widget _tile(BuildContext ctx, _MI item) {
    return InkWell(onTap: item.onTap, borderRadius: BorderRadius.circular(14),
      child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.surface,
        borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.08))),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(item.icon, color: item.color, size: 22)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.label, style: Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(item.sub, style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.55))),
          ])),
          Icon(Icons.chevron_right, color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.35)),
        ])));
  }
}

class _MI {
  final IconData icon; final String label; final String sub; final Color color; final VoidCallback onTap;
  const _MI(this.icon, this.label, this.sub, this.color, this.onTap);
}
