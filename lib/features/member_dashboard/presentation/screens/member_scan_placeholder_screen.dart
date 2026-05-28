import 'package:flutter/material.dart';
import 'package:gymmy/core/theme/app_colors.dart';

class MemberScanPlaceholderScreen extends StatelessWidget {
  const MemberScanPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Aksi scan ditangani oleh bottom sheet di MemberShellScreen.
    // Tampilan ini sebagai fallback jika rute diakses langsung.
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code_scanner, size: 56, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'Aksi QR',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Gunakan tombol QR di navigasi bawah\nuntuk melakukan aksi scan.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
