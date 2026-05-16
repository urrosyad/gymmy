import 'package:flutter/material.dart';

class OwnerManageDataScreen extends StatelessWidget {
  const OwnerManageDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GYMMY',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kelola Data',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Atur data dan informasi gym kamu',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            _buildCategory(context, 'Harga & Paket', [
              _MenuItem(Icons.today_outlined, 'Harga Harian',
                  'Atur harga akses gym per hari', const Color(0xFF0891B2)),
              _MenuItem(Icons.card_membership_outlined, 'Harga Membership',
                  'Atur paket membership bulanan', const Color(0xFF7C3AED)),
            ]),
            const SizedBox(height: 20),
            _buildCategory(context, 'Fasilitas', [
              _MenuItem(Icons.fitness_center, 'Peralatan Gym',
                  'Daftar alat gym yang tersedia', const Color(0xFFD97706)),
              _MenuItem(Icons.event_note, 'Kelas Gym',
                  'Jadwal dan daftar kelas fitness', const Color(0xFF059669)),
            ]),
            const SizedBox(height: 20),
            _buildCategory(context, 'Benefit & Rank', [
              _MenuItem(Icons.star_outline, 'Data Benefit Rank',
                  'Atur keuntungan setiap level member', const Color(0xFFDB2777)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String title, List<_MenuItem> items) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildMenuTile(context, item),
            )),
      ],
    );
  }

  Widget _buildMenuTile(BuildContext context, _MenuItem item) {
    return InkWell(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.label} akan segera hadir')),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          )),
                  const SizedBox(height: 2),
                  Text(item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.55),
                          )),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.35)),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  const _MenuItem(this.icon, this.label, this.subtitle, this.color);
}
