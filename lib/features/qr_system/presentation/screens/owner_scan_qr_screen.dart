import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gymmy/core/widgets/gymmy_app_bar_logo.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class OwnerScanQrScreen extends StatefulWidget {
  final String ownerUid;
  final String gymId;
  const OwnerScanQrScreen({
    super.key,
    required this.ownerUid,
    required this.gymId,
  });
  @override
  State<OwnerScanQrScreen> createState() => _OwnerScanQrScreenState();
}

class _OwnerScanQrScreenState extends State<OwnerScanQrScreen> {
  bool _processing = false;
  String? _result;
  bool _isSuccess = false;

  Future<void> _handleScan(String raw) async {
    if (_processing) return;
    setState(() => _processing = true);
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final type = data['type'] as String? ?? '';

      if (type == 'daily') {
        await _handleDaily(data);
      } else if (type == 'class_subscription' || type == 'class_attendance') {
        setState(() {
          _result = 'Jenis QR "$type" belum didukung.';
          _isSuccess = false;
          _processing = false;
        });
      } else {
        setState(() {
          _result = 'QR tidak dikenali.';
          _isSuccess = false;
          _processing = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Gagal memproses QR: $e';
        _isSuccess = false;
        _processing = false;
      });
    }
  }

  Future<void> _handleDaily(Map<String, dynamic> data) async {
    final sessionId = data['qrSessionId'] as String? ?? '';
    final userId = data['userId'] as String? ?? '';
    final gymId = data['gymId'] as String? ?? '';

    if (sessionId.isEmpty) {
      setState(() {
        _result = 'QR tidak valid.';
        _isSuccess = false;
        _processing = false;
      });
      return;
    }

    final fs = FirebaseFirestore.instance;
    final sessionDoc = await fs.collection('qr_sessions').doc(sessionId).get();
    if (!sessionDoc.exists) {
      setState(() {
        _result = 'Sesi QR tidak ditemukan.';
        _isSuccess = false;
        _processing = false;
      });
      return;
    }
    final session = sessionDoc.data()!;
    if (session['qr_is_used'] == true) {
      setState(() {
        _result = 'QR sudah digunakan.';
        _isSuccess = false;
        _processing = false;
      });
      return;
    }
    final expiredAt = session['qr_expired_at'];
    DateTime? expiry;
    if (expiredAt is Timestamp) expiry = expiredAt.toDate();
    if (expiry != null && expiry.isBefore(DateTime.now())) {
      setState(() {
        _result = 'QR sudah kedaluwarsa.';
        _isSuccess = false;
        _processing = false;
      });
      return;
    }

    // Mark as used
    await sessionDoc.reference.update({'qr_is_used': true});

    // Create daily visit
    final visitRef = fs.collection('gym_daily_visits').doc();
    await visitRef.set({
      'daily_visit_id_key': visitRef.id,
      'daily_visit_user_uid': userId,
      'daily_visit_gym_id': gymId,
      'daily_visit_checkin_at': FieldValue.serverTimestamp(),
      'daily_visit_payment_status': 'paid',
      'daily_visit_qr_session_id': sessionId,
      'daily_visit_checkout_at': null,
      'daily_visit_validated_by_owner': widget.ownerUid,
      'daily_visit_status': 'checked_in',
    });

    // Create attendance log
    final logRef = fs.collection('gym_attendance_logs').doc();
    await logRef.set({
      'log_id_key': logRef.id,
      'log_member_id': '',
      'log_gym_id': gymId,
      'log_category_type': 'daily',
      'log_reference_class_id': '',
      'log_recorded_at': FieldValue.serverTimestamp(),
      'log_user_uid': userId,
      'log_qr_session_id': sessionId,
      'log_validated_by_owner_uid': widget.ownerUid,
      'log_device_platform': 'mobile',
    });

    // Update membership registry (checkin count, last checkin, and streak)
    try {
      final registryQuery = await fs
          .collection('gym_members_registry')
          .where('mem_user_uid', isEqualTo: userId)
          .get();

      final activeDocs = registryQuery.docs.where((doc) {
        final data = doc.data();
        return data['mem_gym_id'] == gymId &&
            data['mem_membership_status'] == 'active';
      }).toList();

      if (activeDocs.isNotEmpty) {
        final regDoc = activeDocs.first;
        final regData = regDoc.data();
        final currentCount =
            (regData['mem_total_checkin_count'] as num?)?.toInt() ?? 0;
        final lastCheckin = regData['mem_last_checkin_at'] as Timestamp?;
        int currentStreak =
            (regData['mem_streak_consecutive_days'] as num?)?.toInt() ?? 0;

        final now = DateTime.now();
        if (lastCheckin != null) {
          final lastDate = lastCheckin.toDate();
          final diffDays = DateTime(now.year, now.month, now.day)
              .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
              .inDays;
          if (diffDays == 1) {
            currentStreak += 1;
          } else if (diffDays > 1) {
            currentStreak = 1;
          }
        } else {
          currentStreak = 1;
        }

        await regDoc.reference.update({
          'mem_total_checkin_count': currentCount + 1,
          'mem_last_checkin_at': FieldValue.serverTimestamp(),
          'mem_streak_consecutive_days': currentStreak,
        });
      }
    } catch (e) {
      debugPrint('Failed to update membership check-in counters: $e');
    }

    setState(() {
      _result = 'Check-in harian berhasil divalidasi!';
      _isSuccess = true;
      _processing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const GymmyAppBarLogo()),
      body: _result != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color:
                            (_isSuccess ? AppColors.success : AppColors.error)
                                .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isSuccess ? Icons.check_circle : Icons.error_outline,
                        size: 64,
                        color: _isSuccess ? AppColors.success : AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _result!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.darkBackground,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Selesai'),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                MobileScanner(
                  onDetect: (c) {
                    if (c.barcodes.isNotEmpty &&
                        c.barcodes.first.rawValue != null) {
                      _handleScan(c.barcodes.first.rawValue!);
                    }
                  },
                ),
                if (_processing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 48,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Arahkan kamera ke QR User',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
