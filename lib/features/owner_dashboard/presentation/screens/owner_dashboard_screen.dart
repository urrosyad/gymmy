import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/gym_tenant/domain/entities/gym_tenant_entity.dart';
import 'package:gymmy/features/gym_tenant/presentation/providers/gym_tenant_provider.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_class_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_edit_gym_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_equipment_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_history_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/widgets/owner_top_bar.dart';
import 'package:gymmy/features/qr_system/presentation/screens/membership_qr_display_screen.dart';
import 'package:gymmy/features/qr_system/presentation/screens/owner_scan_qr_screen.dart';
import 'package:intl/intl.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final ownerGymAsync = ref.watch(ownerGymProvider);

    return Scaffold(
      appBar: OwnerTopBar(
        ownerName: auth.user?.fullName ?? 'Owner Gym',
        automaticallyImplyLeading: false,
        onAvatarTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const OwnerEditGymScreen())),
      ),
      body: ownerGymAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat data gym: $e')),
        data: (gym) {
          if (gym == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return FutureBuilder<_DashboardData>(
            future: _loadDashboardData(gym.gtIdKey),
            builder: (context, snapshot) {
              final data = snapshot.data ?? _DashboardData.empty();
              return _DashboardContent(
                ownerName: auth.user?.fullName ?? 'Owner Gym',
                ownerUid: auth.user?.uid ?? '',
                gym: gym,
                data: data,
                isLoadingStats:
                    snapshot.connectionState == ConnectionState.waiting,
              );
            },
          );
        },
      ),
    );
  }

  Future<_DashboardData> _loadDashboardData(String gymId) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));

    final results = await Future.wait([
      FirebaseFirestore.instance
          .collection('gym_members_registry')
          .where('mem_gym_id', isEqualTo: gymId)
          .get(),
      FirebaseFirestore.instance
          .collection('gym_daily_visits')
          .where('daily_visit_gym_id', isEqualTo: gymId)
          .get(),
      FirebaseFirestore.instance
          .collection('gym_classes_catalog')
          .where('class_parent_gym_id', isEqualTo: gymId)
          .get(),
      FirebaseFirestore.instance
          .collection('gym_equipments')
          .where('equip_parent_gym_id', isEqualTo: gymId)
          .get(),
      FirebaseFirestore.instance
          .collection('gym_attendance_logs')
          .where('log_gym_id', isEqualTo: gymId)
          .limit(20)
          .get(),
      FirebaseFirestore.instance
          .collection('gym_class_subscriptions')
          .where('class_sub_gym_id', isEqualTo: gymId)
          .limit(20)
          .get(),
    ]);

    final members = results[0];
    final visits = results[1];
    final classes = results[2];
    final equipments = results[3];
    final logs = results[4];
    final classSubs = results[5];

    final todayCheckins = _countByTimestamp(
      visits.docs.map((doc) => doc.data()['daily_visit_checkin_at']),
      todayStart,
      tomorrowStart,
    );
    final yesterdayCheckins = _countByTimestamp(
      visits.docs.map((doc) => doc.data()['daily_visit_checkin_at']),
      yesterdayStart,
      todayStart,
    );

    final todayMembers = _countByTimestamp(
      members.docs.map((doc) => doc.data()['mem_join_timestamp']),
      todayStart,
      tomorrowStart,
    );
    final yesterdayMembers = _countByTimestamp(
      members.docs.map((doc) => doc.data()['mem_join_timestamp']),
      yesterdayStart,
      todayStart,
    );

    final todayClasses = _countByTimestamp(
      classes.docs.map((doc) => doc.data()['class_created_at']),
      todayStart,
      tomorrowStart,
    );
    final yesterdayClasses = _countByTimestamp(
      classes.docs.map((doc) => doc.data()['class_created_at']),
      yesterdayStart,
      todayStart,
    );

    final todayEquipments = _countByTimestamp(
      equipments.docs.map((doc) => doc.data()['equip_created_at']),
      todayStart,
      tomorrowStart,
    );
    final yesterdayEquipments = _countByTimestamp(
      equipments.docs.map((doc) => doc.data()['equip_created_at']),
      yesterdayStart,
      todayStart,
    );

    final activities = await _loadLatestActivities(
      members: members.docs,
      visits: visits.docs,
      logs: logs.docs,
      classSubs: classSubs.docs,
    );
    final monthlyCheckins = _buildMonthlyStats(
      now,
      visits.docs.map((doc) => doc.data()['daily_visit_checkin_at']),
    );
    final monthlyMemberships = _buildMonthlyStats(
      now,
      members.docs.map((doc) => doc.data()['mem_join_timestamp']),
    );

    return _DashboardData(
      totalMembers: members.docs.length,
      todayCheckins: todayCheckins,
      totalClasses: classes.docs.length,
      totalEquipments: equipments.docs.length,
      memberTrend: _trendText(todayMembers, yesterdayMembers),
      checkinTrend: _trendText(todayCheckins, yesterdayCheckins),
      classTrend: _trendText(todayClasses, yesterdayClasses),
      equipmentTrend: _trendText(todayEquipments, yesterdayEquipments),
      activities: activities,
      monthlyCheckins: monthlyCheckins,
      monthlyMemberships: monthlyMemberships,
    );
  }

  int _countByTimestamp(
    Iterable<dynamic> values,
    DateTime start,
    DateTime end,
  ) {
    return values.where((value) {
      if (value is! Timestamp) return false;
      final date = value.toDate();
      return !date.isBefore(start) && date.isBefore(end);
    }).length;
  }

  String _trendText(int today, int yesterday) {
    if (today == 0 && yesterday == 0) return 'Belum ada perubahan';
    final diff = today - yesterday;
    if (diff > 0) return '+$diff dari kemarin';
    if (diff < 0) return '$diff dari kemarin';
    return '0 perubahan';
  }

  List<_MonthlyStatisticItem> _buildMonthlyStats(
    DateTime now,
    Iterable<dynamic> values,
  ) {
    final firstMonth = DateTime(now.year, now.month - 5);
    final formatter = DateFormat('MMM', 'id_ID');

    return List.generate(6, (index) {
      final start = DateTime(firstMonth.year, firstMonth.month + index);
      final end = DateTime(start.year, start.month + 1);
      final label = formatter.format(start);
      return _MonthlyStatisticItem(
        label: label,
        count: _countByTimestamp(values, start, end),
      );
    });
  }

  Future<List<_ActivityItem>> _loadLatestActivities({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> members,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> visits,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> logs,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> classSubs,
  }) async {
    final raw = <_RawActivity>[];

    for (final doc in visits) {
      final data = doc.data();
      raw.add(
        _RawActivity(
          title: 'Check-in Harian',
          userId: (data['daily_visit_user_uid'] ?? '').toString(),
          timestamp: data['daily_visit_checkin_at'],
          icon: Icons.qr_code_scanner,
        ),
      );
    }

    for (final doc in members) {
      final data = doc.data();
      raw.add(
        _RawActivity(
          title: 'Membership Baru',
          userId: (data['mem_user_uid'] ?? '').toString(),
          timestamp: data['mem_join_timestamp'],
          icon: Icons.person_outline,
        ),
      );
    }

    for (final doc in logs) {
      final data = doc.data();
      final category = (data['log_category_type'] ?? '').toString();
      raw.add(
        _RawActivity(
          title: switch (category) {
            'class' => 'Check-in Kelas',
            'membership' => 'Check-in Membership',
            _ => 'Check-in Harian',
          },
          userId: (data['log_user_uid'] ?? '').toString(),
          timestamp: data['log_recorded_at'],
          icon: category == 'class'
              ? Icons.event_available_outlined
              : Icons.qr_code_scanner,
        ),
      );
    }

    for (final doc in classSubs) {
      final data = doc.data();
      raw.add(
        _RawActivity(
          title: 'Member Kelas Baru',
          userId: (data['class_sub_user_uid'] ?? '').toString(),
          timestamp: data['class_sub_created_at'],
          icon: Icons.event_note_outlined,
        ),
      );
    }

    raw.removeWhere((item) => item.date == null);
    raw.sort((a, b) => b.date!.compareTo(a.date!));
    final newest = raw.take(5).toList();

    final names = <String, String>{};
    for (final item in newest) {
      if (item.userId.isEmpty || names.containsKey(item.userId)) continue;
      names[item.userId] = await _resolveUserName(item.userId);
    }

    return newest
        .map(
          (item) => _ActivityItem(
            title: item.title,
            name: names[item.userId] ?? 'Pengguna',
            date: item.date!,
            icon: item.icon,
          ),
        )
        .toList();
  }

  Future<String> _resolveUserName(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_accounts_global')
          .doc(userId)
          .get();
      final data = doc.data();
      if (data == null) return 'Pengguna';
      final name = (data['user_full_name'] ?? '').toString().trim();
      if (name.isNotEmpty) return name;
      final email = (data['user_email_address'] ?? '').toString().trim();
      if (email.isNotEmpty) return email;
    } catch (_) {}
    return 'Pengguna';
  }
}

class _DashboardContent extends StatelessWidget {
  final String ownerName;
  final String ownerUid;
  final GymTenantEntity gym;
  final _DashboardData data;
  final bool isLoadingStats;

  const _DashboardContent({
    required this.ownerName,
    required this.ownerUid,
    required this.gym,
    required this.data,
    required this.isLoadingStats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang,',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ownerName,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _GymIdentityCard(gym: gym),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Ringkasan Hari Ini',
                actionLabel: isLoadingStats ? 'Memuat' : null,
              ),
              const SizedBox(height: 12),
              _SummaryGrid(data: data),
              const SizedBox(height: 24),
              Text(
                'Aksi Cepat',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _QuickActions(ownerUid: ownerUid, gym: gym),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Aktivitas Terbaru',
                actionLabel: 'Lihat semua',
                onAction: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OwnerHistoryScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _ActivityList(activities: data.activities),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Statistik Bulanan'),
              const SizedBox(height: 12),
              _MonthlyStatsSection(
                checkins: data.monthlyCheckins,
                memberships: data.monthlyMemberships,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GymIdentityCard extends StatelessWidget {
  final GymTenantEntity gym;

  const _GymIdentityCard({required this.gym});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111315),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: gym.gtImage.isNotEmpty
                    ? Image.network(
                        gym.gtImage,
                        width: 112,
                        height: 112,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const _GymImagePlaceholder(),
                      )
                    : const _GymImagePlaceholder(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gym.gtNameTitle.isEmpty
                          ? 'Nama gym belum diisi'
                          : gym.gtNameTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFFC7CCD1),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _locationText(gym),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: const Color(0xFFC7CCD1),
                                  height: 1.35,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.72),
                        ),
                      ),
                      child: Text(
                        gym.gtIsActive ? 'Aktif' : 'Tidak Aktif',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.14), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PriceInfo(
                  icon: Icons.calendar_today_outlined,
                  label: 'Harian',
                  value: currency.format(gym.gtDailyPriceAmount),
                ),
              ),
              Container(
                width: 1,
                height: 42,
                color: Colors.white.withValues(alpha: 0.14),
              ),
              Expanded(
                child: _PriceInfo(
                  icon: Icons.card_membership_outlined,
                  label: 'Membership',
                  value:
                      '${currency.format(gym.gtMembershipPriceAmount)} / bln',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _locationText(GymTenantEntity gym) {
    final values = [
      gym.gtLocation,
      gym.gtCityName,
    ].map((value) => value.trim()).where((value) => value.isNotEmpty).toList();
    return values.isEmpty ? 'Lokasi belum diisi' : values.join(', ');
  }
}

class _GymImagePlaceholder extends StatelessWidget {
  const _GymImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      color: Colors.white.withValues(alpha: 0.08),
      child: const Icon(
        Icons.storefront_outlined,
        color: Colors.white70,
        size: 36,
      ),
    );
  }
}

class _PriceInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PriceInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFFC7CCD1)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(actionLabel!),
                if (onAction != null) const SizedBox(width: 4),
                if (onAction != null) const Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final _DashboardData data;

  const _SummaryGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.people_outline,
                label: 'Total Member',
                value: data.totalMembers.toString(),
                trend: data.memberTrend,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MetricCard(
                icon: Icons.qr_code_scanner,
                label: 'Check-in Hari Ini',
                value: data.todayCheckins.toString(),
                trend: data.checkinTrend,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.calendar_month_outlined,
                label: 'Total Kelas',
                value: data.totalClasses.toString(),
                trend: data.classTrend,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MetricCard(
                icon: Icons.fitness_center_outlined,
                label: 'Total Peralatan',
                value: data.totalEquipments.toString(),
                trend: data.equipmentTrend,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String trend;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: theme.colorScheme.onSurface, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  trend,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: trend.startsWith('+')
                        ? AppColors.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.54),
                    fontWeight: trend.startsWith('+')
                        ? FontWeight.w700
                        : FontWeight.normal,
                    fontSize: 10,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final String ownerUid;
  final GymTenantEntity gym;

  const _QuickActions({required this.ownerUid, required this.gym});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ShortcutCard(
            icon: Icons.qr_code_scanner,
            label: 'Scan QR User',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    OwnerScanQrScreen(ownerUid: ownerUid, gymId: gym.gtIdKey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _ShortcutCard(
            icon: Icons.qr_code_2,
            label: 'QR Membership',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MembershipQrDisplayScreen(
                  gymId: gym.gtIdKey,
                  gymName: gym.gtNameTitle,
                  ownerId: ownerUid,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _ShortcutCard(
            icon: Icons.fitness_center_outlined,
            label: 'Tambah Peralatan',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    const OwnerEquipmentScreen(openCreateOnLoad: true),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _ShortcutCard(
            icon: Icons.calendar_month_outlined,
            label: 'Tambah Kelas',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const OwnerClassScreen(openCreateOnLoad: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 126,
        height: 104,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.onSurface, size: 30),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  final List<_ActivityItem> activities;

  const _ActivityList({required this.activities});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (activities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          'Belum ada aktivitas terbaru.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < activities.length; i++) ...[
            _ActivityRow(item: activities[i]),
            if (i != activities.length - 1)
              Divider(
                height: 1,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              ),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final _ActivityItem item;

  const _ActivityRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('dd MMM, HH:mm', 'id_ID');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: theme.colorScheme.onSurface,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            df.format(item.date),
            textAlign: TextAlign.right,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.54),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyStatsSection extends StatelessWidget {
  final List<_MonthlyStatisticItem> checkins;
  final List<_MonthlyStatisticItem> memberships;

  const _MonthlyStatsSection({
    required this.checkins,
    required this.memberships,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MonthlyStatisticCard(
          icon: Icons.qr_code_scanner,
          title: 'Check-in',
          subtitle: 'Jumlah check-in per bulan',
          items: checkins,
        ),
        const SizedBox(height: 12),
        _MonthlyStatisticCard(
          icon: Icons.card_membership_outlined,
          title: 'Membership',
          subtitle: 'Membership baru per bulan',
          items: memberships,
        ),
      ],
    );
  }
}

class _MonthlyStatisticCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<_MonthlyStatisticItem> items;

  const _MonthlyStatisticCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = items.fold<int>(0, (totalCount, item) {
      return totalCount + item.count;
    });
    final maxValue = items.fold<int>(
      0,
      (max, item) => item.count > max ? item.count : max,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: theme.colorScheme.onSurface, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.58,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                total.toString(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (items.isEmpty)
            Text(
              'Memuat statistik bulanan...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
              ),
            )
          else
            SizedBox(
              height: 122,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    Expanded(
                      child: _MonthlyBar(item: items[i], maxValue: maxValue),
                    ),
                    if (i != items.length - 1) const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthlyBar extends StatelessWidget {
  final _MonthlyStatisticItem item;
  final int maxValue;

  const _MonthlyBar({required this.item, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = maxValue <= 0 ? 0.0 : item.count / maxValue;
    final barHeight = 12 + (74 * percent);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          item.count.toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: item.count > 0
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          width: double.infinity,
          height: barHeight,
          decoration: BoxDecoration(
            color: item.count > 0
                ? AppColors.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DashboardData {
  final int totalMembers;
  final int todayCheckins;
  final int totalClasses;
  final int totalEquipments;
  final String memberTrend;
  final String checkinTrend;
  final String classTrend;
  final String equipmentTrend;
  final List<_ActivityItem> activities;
  final List<_MonthlyStatisticItem> monthlyCheckins;
  final List<_MonthlyStatisticItem> monthlyMemberships;

  const _DashboardData({
    required this.totalMembers,
    required this.todayCheckins,
    required this.totalClasses,
    required this.totalEquipments,
    required this.memberTrend,
    required this.checkinTrend,
    required this.classTrend,
    required this.equipmentTrend,
    required this.activities,
    required this.monthlyCheckins,
    required this.monthlyMemberships,
  });

  factory _DashboardData.empty() {
    return const _DashboardData(
      totalMembers: 0,
      todayCheckins: 0,
      totalClasses: 0,
      totalEquipments: 0,
      memberTrend: 'Data hari ini',
      checkinTrend: 'Data hari ini',
      classTrend: 'Data hari ini',
      equipmentTrend: 'Data hari ini',
      activities: [],
      monthlyCheckins: [],
      monthlyMemberships: [],
    );
  }
}

class _MonthlyStatisticItem {
  final String label;
  final int count;

  const _MonthlyStatisticItem({required this.label, required this.count});
}

class _RawActivity {
  final String title;
  final String userId;
  final dynamic timestamp;
  final IconData icon;

  const _RawActivity({
    required this.title,
    required this.userId,
    required this.timestamp,
    required this.icon,
  });

  DateTime? get date =>
      timestamp is Timestamp ? (timestamp as Timestamp).toDate() : null;
}

class _ActivityItem {
  final String title;
  final String name;
  final DateTime date;
  final IconData icon;

  const _ActivityItem({
    required this.title,
    required this.name,
    required this.date,
    required this.icon,
  });
}
