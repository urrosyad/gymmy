import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/biodata/presentation/screens/biodata_detail_screen.dart';
import 'package:gymmy/features/settings/presentation/screens/theme_settings_screen.dart';

class MemberProfileScreen extends ConsumerWidget {
  const MemberProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('GYMMY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)), automaticallyImplyLeading: false),
      body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Profil', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Center(child: Column(children: [
          CircleAvatar(radius: 48, backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: const Icon(Icons.person, size: 48, color: AppColors.primary)),
          const SizedBox(height: 16),
          Text(auth.user?.fullName ?? 'Member', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(auth.user?.email ?? '', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 4),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
            child: const Text('Member', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12))),
        ])),
        const SizedBox(height: 32),
        _menu(context, icon: Icons.person_outline, label: 'Biodata Saya', subtitle: 'Lihat dan edit informasi diri',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BiodataDetailScreen()))),
        const SizedBox(height: 12),
        _menu(context, icon: Icons.palette_outlined, label: 'Tampilan', subtitle: 'Atur tema aplikasi',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()))),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(
          onPressed: () => ref.read(authProvider.notifier).logout(),
          icon: const Icon(Icons.logout, color: AppColors.error),
          label: const Text('Keluar', style: TextStyle(color: AppColors.error)),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
      ])),
    );
  }

  Widget _menu(BuildContext ctx, {required IconData icon, required String label, required String subtitle, required VoidCallback onTap}) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14),
      child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.surface,
        borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.08))),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 22)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.55))),
          ])),
          Icon(Icons.chevron_right, color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.35)),
        ])));
  }
}
