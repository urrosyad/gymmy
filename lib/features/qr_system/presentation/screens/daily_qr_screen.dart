import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gymmy/core/widgets/gymmy_app_bar_logo.dart';
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
  DateTime? _expiresAt;
  Timer? _timer;
  Duration _remaining = const Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _generateQr();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
        _expiresAt = expiry;
        _remaining = expiry.difference(DateTime.now());
        _isLoading = false;
      });
      _startCountdown();
    } catch (e) {
      setState(() {
        _error =
            'Gagal membuat QR: ${e.toString().replaceFirst('Exception: ', '')}';
        _isLoading = false;
      });
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final expiresAt = _expiresAt;
      if (!mounted || expiresAt == null) return;
      final remaining = expiresAt.difference(DateTime.now());
      setState(() {
        _remaining = remaining.isNegative ? Duration.zero : remaining;
      });
      if (remaining <= Duration.zero) {
        _timer?.cancel();
      }
    });
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
      appBar: AppBar(title: const GymmyAppBarLogo()),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _isLoading
              ? const CircularProgressIndicator()
              : _error != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 56,
                      color: AppColors.error.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _error = null;
                          _remaining = const Duration(minutes: 5);
                        });
                        _generateQr();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.darkBackground,
                      ),
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
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.1,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
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
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.gymName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tunjukkan QR ini ke Gym untuk check in!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.68,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _remaining == Duration.zero
                                ? 'QR kedaluwarsa'
                                : 'Berlaku ${_formatRemaining(_remaining)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
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

  String _formatRemaining(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
