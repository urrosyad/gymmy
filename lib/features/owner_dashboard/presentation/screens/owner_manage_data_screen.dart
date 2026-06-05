import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_edit_gym_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_price_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_equipment_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_class_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_rank_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/widgets/owner_top_bar.dart';

class OwnerManageDataScreen extends ConsumerWidget {
  const OwnerManageDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerName = ref.watch(authProvider).user?.fullName ?? 'Owner Gym';
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: OwnerTopBar(
        ownerName: ownerName,
        automaticallyImplyLeading: false,
        onAvatarTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OwnerEditGymScreen()),
        ),
      ),
      body: SizedBox.expand(
        child: ColoredBox(
          color: theme.scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 16.0;
                final cardWidth = (constraints.maxWidth - spacing) / 2;
                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: cardWidth / 156,
                  children: [
                    _ManageCard(
                      icon: Icons.today_outlined,
                      title: 'Harga Paket',
                      subtitle: 'Atur harga harian dan membership',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OwnerPriceScreen(),
                        ),
                      ),
                    ),
                    _ManageCard(
                      icon: Icons.fitness_center,
                      title: 'Peralatan Gym',
                      subtitle: 'Kelola daftar alat gym',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OwnerEquipmentScreen(),
                        ),
                      ),
                    ),
                    _ManageCard(
                      icon: Icons.event_note,
                      title: 'Kelas Gym',
                      subtitle: 'Atur jadwal dan detail kelas fitness',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OwnerClassScreen(),
                        ),
                      ),
                    ),
                    _ManageCard(
                      icon: Icons.star_outline,
                      title: 'Data Benefit Rank',
                      subtitle: 'Atur keuntungan setiap level member',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OwnerRankScreen(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ManageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ManageCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.darkPrimaryText
        : const Color(0xFF121417);
    final secondaryText = isDark
        ? AppColors.darkSecondaryText
        : const Color(0xFF6B7280);
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB);
    final cardColor = isDark
        ? AppColors.darkCardSurface
        : AppColors.lightSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: primaryText, size: 30),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: secondaryText,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
