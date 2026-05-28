import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/core/providers/theme_provider.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final current = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tampilan', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tema Aplikasi', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Pilih tema tampilan yang Anda inginkan', style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.lightSecondaryText)),
          const SizedBox(height: 24),
          _option(context, ref, 'Terang', 'Mode terang untuk penggunaan sehari-hari', Icons.light_mode_outlined, ThemeMode.light, current),
          const SizedBox(height: 12),
          _option(context, ref, 'Gelap', 'Mode gelap untuk kenyamanan mata', Icons.dark_mode_outlined, ThemeMode.dark, current),
          const SizedBox(height: 12),
          _option(context, ref, 'Ikuti Sistem', 'Menyesuaikan dengan pengaturan perangkat', Icons.settings_suggest_outlined, ThemeMode.system, current),
        ]),
      ),
    );
  }

  Widget _option(BuildContext ctx, WidgetRef ref, String title, String sub, IconData icon, ThemeMode mode, ThemeMode current) {
    final isSelected = current == mode;
    final theme = Theme.of(ctx);
    return InkWell(
      onTap: () => ref.read(themeProvider.notifier).setThemeMode(mode),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.08), width: isSelected ? 2 : 1),
        ),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(
            color: (isSelected ? AppColors.primary : theme.colorScheme.onSurface).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: isSelected ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6), size: 22)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(sub, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.55))),
          ])),
          if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
        ]),
      ),
    );
  }
}
