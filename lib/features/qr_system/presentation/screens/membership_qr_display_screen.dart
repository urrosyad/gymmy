import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MembershipQrDisplayScreen extends StatelessWidget {
  final String gymId;
  final String gymName;
  final String ownerId;

  const MembershipQrDisplayScreen({
    super.key,
    required this.gymId,
    required this.gymName,
    required this.ownerId,
  });

  String _buildPayload() {
    return jsonEncode({
      'type': 'membership_activation',
      'gymId': gymId,
      'ownerId': ownerId,
      'generatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Membership Gym',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(8),
                  child: QrImageView(
                    data: _buildPayload(),
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black),
                    dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(gymName,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Minta user memindai QR ini\nuntuk mengaktifkan membership.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.lightSecondaryText, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_outlined,
                        size: 16, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text('Membership 30 hari',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
