import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/membership/presentation/providers/active_membership_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MemberScanMembershipScreen extends ConsumerStatefulWidget {
  const MemberScanMembershipScreen({super.key});
  @override
  ConsumerState<MemberScanMembershipScreen> createState() => _State();
}

class _State extends ConsumerState<MemberScanMembershipScreen> {
  bool _processing = false;
  String? _error;
  bool _success = false;

  Future<void> _handleScan(String raw) async {
    if (_processing || _success) return;
    setState(() => _processing = true);
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (data['type'] != 'membership_activation') {
        setState(() { _error = 'Jenis QR tidak valid.'; _processing = false; });
        return;
      }
      final gymId = data['gymId'] as String? ?? '';
      final ownerId = data['ownerId'] as String? ?? '';
      final userId = ref.read(authProvider).user?.uid ?? '';
      if (userId.isEmpty || gymId.isEmpty) {
        setState(() { _error = 'Data tidak valid.'; _processing = false; });
        return;
      }
      final existing = await FirebaseFirestore.instance
          .collection('gym_members_registry')
          .where('mem_user_uid', isEqualTo: userId)
          .where('mem_gym_id', isEqualTo: gymId)
          .where('mem_membership_status', isEqualTo: 'active')
          .limit(1).get();
      if (existing.docs.isNotEmpty) {
        setState(() { _error = 'Anda sudah memiliki membership aktif.'; _processing = false; });
        return;
      }
      final docRef = FirebaseFirestore.instance.collection('gym_members_registry').doc();
      final now = DateTime.now();
      await docRef.set({
        'mem_id_key': docRef.id, 'mem_user_uid': userId, 'mem_gym_id': gymId,
        'mem_membership_type': 'monthly', 'mem_membership_status': 'active',
        'mem_current_points_balance': 0, 'mem_streak_consecutive_days': 0,
        'mem_join_timestamp': Timestamp.fromDate(now),
        'mem_membership_start_date': Timestamp.fromDate(now),
        'mem_membership_end_date': Timestamp.fromDate(now.add(const Duration(days: 30))),
        'mem_current_rank_id': '', 'mem_total_checkin_count': 0,
        'mem_last_checkin_at': null, 'mem_is_frozen': false,
        'mem_created_by_owner_uid': ownerId,
      });
      ref.invalidate(activeMembershipProvider);
      setState(() { _success = true; _processing = false; });
    } catch (e) {
      setState(() { _error = 'Gagal: $e'; _processing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Membership', style: TextStyle(fontWeight: FontWeight.bold))),
      body: _success
          ? _buildSuccess(theme)
          : _error != null ? _buildError(theme) : _buildScanner(theme),
    );
  }

  Widget _buildSuccess(ThemeData theme) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15), shape: BoxShape.circle),
        child: const Icon(Icons.check_circle, size: 64, color: AppColors.success)),
      const SizedBox(height: 24),
      Text('Membership Aktif!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('Membership berhasil diaktifkan selama 30 hari.', textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.lightSecondaryText)),
      const SizedBox(height: 32),
      FilledButton(onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.darkBackground,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('Kembali ke Beranda')),
    ])));

  Widget _buildError(ThemeData theme) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.error_outline, size: 56, color: AppColors.error.withValues(alpha: 0.7)),
      const SizedBox(height: 16),
      Text(_error!, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
      const SizedBox(height: 24),
      FilledButton(onPressed: () => setState(() => _error = null),
        style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.darkBackground),
        child: const Text('Coba Lagi')),
    ])));

  Widget _buildScanner(ThemeData theme) => Stack(children: [
    MobileScanner(onDetect: (c) {
      if (c.barcodes.isNotEmpty && c.barcodes.first.rawValue != null) {
        _handleScan(c.barcodes.first.rawValue!);
      }
    }),
    if (_processing) Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator(color: AppColors.primary))),
    Positioned(bottom: 48, left: 0, right: 0, child: Center(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
      child: const Text('Arahkan kamera ke QR Membership Gym', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500))))),
  ]);
}
