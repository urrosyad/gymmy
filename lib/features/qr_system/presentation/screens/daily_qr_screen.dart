import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DailyQrScreen extends StatefulWidget {
  final String gymId;
  final String gymName;
  final String userId;

  const DailyQrScreen({
    super.key,
    required this.gymId,
    required this.gymName,
    required this.userId,
  });

  @override
  State<DailyQrScreen> createState() => _DailyQrScreenState();
}

class _DailyQrScreenState extends State<DailyQrScreen> {
  String? _qrSessionId;
  bool _isLoading = true;
  String? _error;
  DateTime? _generatedAt;

  @override
  void initState() {
    super.initState();
    _generateQr();
  }

  Future<void> _generateQr() async {
    try {
      final fs = FirebaseFirestore.instance;
      final docRef = fs.collection('qr_sessions').doc();
      final now = DateTime.now();
      final expiry = now.add(const Duration(minutes: 5));

      await docRef.set({
        'qr_session_id': docRef.id,
        'qr_type': 'daily',
        'qr_related_user_uid': widget.userId,
        'qr_related_gym_id': widget.gymId,
        'qr_related_class_id': '',
        'qr_generated_at': Timestamp.fromDate(now),
        'qr_expired_at': Timestamp.fromDate(expiry),
        'qr_is_used': false,
      });

      setState(() {
        _qrSessionId = docRef.id;
        _generatedAt = now;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal membuat QR: ${e.toString().replaceFirst('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  String _buildQrPayload() {
    return jsonEncode({
      'type': 'daily',
      'qrSessionId': _qrSessionId,
      'userId': widget.userId,
      'gymId': widget.gymId,
      'generatedAt': _generatedAt?.toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Check-in Harian',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _isLoading
              ? const CircularProgressIndicator()
              : _error != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            size: 56,
                            color: AppColors.error.withValues(alpha: 0.7)),
                        const SizedBox(height: 16),
                        Text(_error!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _error = null;
                            });
                            _generateQr();
                          },
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.darkBackground),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    )
                  : Column(
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
                            data: _buildQrPayload(),
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
                        Text(widget.gymName,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Tunjukkan QR ini ke owner untuk check-in',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.lightSecondaryText),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer_outlined,
                                  size: 16, color: AppColors.warning),
                              const SizedBox(width: 6),
                              Text(
                                'Berlaku 5 menit',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600),
                              ),
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
