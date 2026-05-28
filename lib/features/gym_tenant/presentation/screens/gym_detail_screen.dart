import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/gym_tenant/domain/entities/gym_tenant_entity.dart';
import 'package:gymmy/features/qr_system/presentation/screens/daily_qr_screen.dart';
import 'package:intl/intl.dart';

class GymDetailScreen extends ConsumerWidget {
  final GymTenantEntity gym;

  const GymDetailScreen({super.key, required this.gym});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Gym',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 200,
              width: double.infinity,
              color: AppColors.lightSecondaryText.withValues(alpha: 0.08),
              child: gym.gtImage.isNotEmpty
                  ? Image.network(gym.gtImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _placeholder())
                  : _placeholder(),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(gym.gtNameTitle,
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      if (gym.gtRate > 0) ...[
                        Icon(Icons.star_rounded,
                            size: 20, color: Colors.amber.shade600),
                        const SizedBox(width: 4),
                        Text(gym.gtRate.toStringAsFixed(1),
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.lightSecondaryText),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${gym.gtCityName} - ${gym.gtLocation}',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: AppColors.lightSecondaryText),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (gym.gtDescriptionText.isNotEmpty) ...[
                    Text('Deskripsi',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(gym.gtDescriptionText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            height: 1.5)),
                    const SizedBox(height: 20),
                  ],

                  // Prices
                  Text('Harga',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _PriceCard(
                              label: 'Harian',
                              value:
                                  currency.format(gym.gtDailyPriceAmount),
                              icon: Icons.today_outlined,
                              color: const Color(0xFF0891B2))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _PriceCard(
                              label: 'Membership',
                              value: currency
                                  .format(gym.gtMembershipPriceAmount),
                              icon: Icons.card_membership_outlined,
                              color: const Color(0xFF7C3AED))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Facilities
                  if (gym.gtAvailableFacilities.isNotEmpty) ...[
                    Text('Fasilitas',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: gym.gtAvailableFacilities
                          .map((f) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(f,
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w500)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Actions
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        final userId =
                            ref.read(authProvider).user?.uid ?? '';
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => DailyQrScreen(
                              gymId: gym.gtIdKey,
                              gymName: gym.gtNameTitle,
                              userId: userId),
                        ));
                      },
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Check-in Harian'),
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.darkBackground,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Scan QR Membership dari owner untuk mendaftar membership')),
                        );
                      },
                      icon: const Icon(Icons.card_membership),
                      label: const Text('Daftar Membership'),
                      style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Center(
      child: Icon(Icons.fitness_center_outlined,
          size: 56,
          color: AppColors.lightSecondaryText.withValues(alpha: 0.3)));
}

class _PriceCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _PriceCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.lightSecondaryText)),
        const SizedBox(height: 4),
        Text(value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }
}
