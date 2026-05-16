import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/features/member_dashboard/presentation/providers/membership_provider.dart';

class DashboardOnboardingView extends ConsumerWidget {
  final String userName;

  const DashboardOnboardingView({super.key, required this.userName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, $userName',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your fitness journey today.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 48),

          // Discover Gym CTA
          _buildActionCard(
            context: context,
            title: 'Find a Gym',
            description: 'Discover premium fitness centers near you.',
            icon: Icons.search_rounded,
            onTap: () {
              // Placeholder for Gym Discovery
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gym Discovery coming soon!')),
              );
            },
            isPrimary: false,
          ),

          const SizedBox(height: 24),

          // Membership CTA
          _buildActionCard(
            context: context,
            title: 'Join Membership',
            description: 'Unlock unlimited access and track your progress.',
            icon: Icons.card_membership_rounded,
            onTap: () {
              ref.read(membershipProvider.notifier).joinMembership();
            },
            isPrimary: true,
          ),

          const SizedBox(height: 24),

          // Daily Pass CTA
          _buildActionCard(
            context: context,
            title: 'Daily Access',
            description: 'Drop-in for a quick session without commitment.',
            icon: Icons.timer_outlined,
            onTap: () {
              ref.read(membershipProvider.notifier).buyDailyPass();
            },
            isPrimary: false,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    final theme = Theme.of(context);
    final bgColor = isPrimary
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surface;
    final iconColor = isPrimary
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.primary;
    final textColor = isPrimary
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;

    return Material(
      color: bgColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPrimary
              ? Colors.transparent
              : theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.1)
                      : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: textColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
