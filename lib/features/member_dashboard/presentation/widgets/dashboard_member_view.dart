import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/membership/domain/entities/membership_entity.dart';
import 'package:gymmy/features/membership/presentation/providers/active_membership_provider.dart';
import 'package:gymmy/features/qr_system/presentation/screens/daily_qr_screen.dart';
import 'package:intl/intl.dart';

class DashboardMemberView extends ConsumerWidget {
  final String userName;
  const DashboardMemberView({super.key, required this.userName});

  Future<_DashboardData> _loadDashboardData(MembershipEntity membership) async {
    final fs = FirebaseFirestore.instance;
    Map<String, dynamic> gymData = {};

    if (membership.memGymId.isNotEmpty) {
      try {
        final gymDoc = await fs
            .collection('gym_tenants')
            .doc(membership.memGymId)
            .get();
        gymData = gymDoc.data() ?? {};
      } catch (_) {}
    }

    final activeClass = await _loadActiveClass(fs, membership);
    final activities = await _loadActivities(fs, membership);
    final lastCheckinAt = _latestCheckinDate(
      membership.memLastCheckinAt,
      activities,
    );

    return _DashboardData(
      gymName: _readString(gymData, const ['gt_name_title'], 'Gym Saya'),
      gymImageUrl: _readString(gymData, const ['gt_image'], ''),
      activeClass: activeClass,
      activities: activities.take(3).toList(),
      lastCheckinAt: lastCheckinAt,
    );
  }

  Future<_ActiveClass?> _loadActiveClass(
    FirebaseFirestore fs,
    MembershipEntity membership,
  ) async {
    if (membership.memUserUid.isEmpty) return null;

    try {
      final subSnap = await fs
          .collection('gym_class_subscriptions')
          .where('class_sub_user_uid', isEqualTo: membership.memUserUid)
          .limit(50)
          .get();

      final subscriptions =
          subSnap.docs.where((doc) {
            final data = doc.data();
            final gymId = (data['class_sub_gym_id'] ?? '').toString();
            final status = (data['class_sub_status'] ?? '').toString();
            return gymId == membership.memGymId && status == 'active';
          }).toList()..sort(
            (a, b) => _compareTimestampDesc(
              a.data()['class_sub_created_at'],
              b.data()['class_sub_created_at'],
            ),
          );

      if (subscriptions.isEmpty) return null;

      final sub = subscriptions.first.data();
      final classId = (sub['class_sub_class_id'] ?? '').toString();
      final remainingSessions = (sub['class_sub_remaining_sessions'] as num?)
          ?.toInt();
      Map<String, dynamic> classData = {};

      if (classId.isNotEmpty) {
        final classDoc = await fs
            .collection('gym_classes_catalog')
            .doc(classId)
            .get();
        classData = classDoc.data() ?? {};

        if (classData.isEmpty) {
          final classQuery = await fs
              .collection('gym_classes_catalog')
              .where('class_id_key', isEqualTo: classId)
              .limit(1)
              .get();
          if (classQuery.docs.isNotEmpty) {
            classData = classQuery.docs.first.data();
          }
        }
      }

      return _ActiveClass(
        name: _readString(classData, const ['class_title_name'], 'Kelas Gym'),
        schedule: _readString(classData, const [
          'class_schedule_text',
        ], 'Jadwal belum tersedia'),
        imageUrl: _readString(classData, const [
          'class_thumbnail_image_url',
        ], ''),
        remainingSessions: remainingSessions,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<_ActivityItem>> _loadActivities(
    FirebaseFirestore fs,
    MembershipEntity membership,
  ) async {
    if (membership.memUserUid.isEmpty) return [];

    final activities = <_ActivityItem>[];

    try {
      final visits = await fs
          .collection('gym_daily_visits')
          .where('daily_visit_user_uid', isEqualTo: membership.memUserUid)
          .limit(50)
          .get();

      for (final doc in visits.docs) {
        final data = doc.data();
        if ((data['daily_visit_gym_id'] ?? '').toString() !=
            membership.memGymId) {
          continue;
        }
        activities.add(
          _ActivityItem(
            title: 'Check-in membership',
            timestamp: _asDate(data['daily_visit_checkin_at']),
            icon: Icons.qr_code_scanner_rounded,
            value: _pointsValue(data),
            isCheckin: true,
          ),
        );
      }

      final logs = await fs
          .collection('gym_attendance_logs')
          .where('log_user_uid', isEqualTo: membership.memUserUid)
          .limit(50)
          .get();

      for (final doc in logs.docs) {
        final data = doc.data();
        if ((data['log_gym_id'] ?? '').toString() != membership.memGymId) {
          continue;
        }
        final type = (data['log_category_type'] ?? '').toString();
        if (type == 'class') {
          activities.add(
            _ActivityItem(
              title: 'Check-in kelas',
              timestamp: _asDate(data['log_recorded_at']),
              icon: Icons.event_available_outlined,
              value: _pointsValue(data),
              isCheckin: true,
            ),
          );
        } else if (type == 'membership' || type == 'daily') {
          activities.add(
            _ActivityItem(
              title: 'Check-in membership',
              timestamp: _asDate(data['log_recorded_at']),
              icon: Icons.qr_code_scanner_rounded,
              value: _pointsValue(data),
              isCheckin: true,
            ),
          );
        }
      }

      final subscriptions = await fs
          .collection('gym_class_subscriptions')
          .where('class_sub_user_uid', isEqualTo: membership.memUserUid)
          .limit(50)
          .get();

      for (final doc in subscriptions.docs) {
        final data = doc.data();
        if ((data['class_sub_gym_id'] ?? '').toString() !=
            membership.memGymId) {
          continue;
        }
        if ((data['class_sub_status'] ?? '').toString() != 'active') {
          continue;
        }
        activities.add(
          _ActivityItem(
            title: 'Kelas aktif',
            timestamp: _asDate(data['class_sub_created_at']),
            icon: Icons.star_rounded,
            value: null,
          ),
        );
      }
    } catch (_) {}

    activities.sort((a, b) {
      if (a.timestamp == null && b.timestamp == null) return 0;
      if (a.timestamp == null) return 1;
      if (b.timestamp == null) return -1;
      return b.timestamp!.compareTo(a.timestamp!);
    });

    final seen = <String>{};
    return activities.where((item) {
      final key = '${item.title}|${item.timestamp?.millisecondsSinceEpoch}';
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipAsync = ref.watch(activeMembershipProvider);
    final userId = ref.watch(authProvider).user?.uid ?? '';

    return membershipAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Gagal memuat data: $e')),
      data: (membership) {
        if (membership == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return FutureBuilder<_DashboardData>(
          future: _loadDashboardData(membership),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data ?? _DashboardData.empty();
            return _DashboardContent(
              userName: userName,
              userId: userId.isNotEmpty ? userId : membership.memUserUid,
              membership: membership,
              data: data,
            );
          },
        );
      },
    );
  }

  static String _readString(
    Map<String, dynamic> data,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return fallback;
  }

  static DateTime? _asDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static int _compareTimestampDesc(dynamic a, dynamic b) {
    final aDate = _asDate(a);
    final bDate = _asDate(b);
    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return bDate.compareTo(aDate);
  }

  static DateTime? _latestCheckinDate(
    DateTime? membershipDate,
    List<_ActivityItem> activities,
  ) {
    DateTime? latest = membershipDate;
    for (final activity in activities.where((item) => item.isCheckin)) {
      final date = activity.timestamp;
      if (date == null) continue;
      if (latest == null || date.isAfter(latest)) latest = date;
    }
    return latest;
  }

  static String? _pointsValue(Map<String, dynamic> data) {
    final value =
        data['points_delta'] ??
        data['point_delta'] ??
        data['points_earned'] ??
        data['poin_diperoleh'];
    final points = (value as num?)?.toInt() ?? 0;
    if (points <= 0) return null;
    return '+$points poin';
  }
}

class _DashboardContent extends StatelessWidget {
  final String userName;
  final String userId;
  final MembershipEntity membership;
  final _DashboardData data;

  const _DashboardContent({
    required this.userName,
    required this.userId,
    required this.membership,
    required this.data,
  });

  static const _mainText = Color(0xFF121417);
  static const _secondaryText = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static const _hero = Color(0xFF15191D);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.scaffoldBackgroundColor;

    return SafeArea(
      top: false,
      child: ColoredBox(
        color: background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(userName: userName),
              const SizedBox(height: 24),
              _MembershipHero(
                membership: membership,
                data: data,
                userId: userId,
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, 'Progress Kamu'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ProgressCard(
                    icon: Icons.local_fire_department_rounded,
                    value: '${membership.memStreakConsecutiveDays} Hari',
                    label: 'Streak',
                  ),
                  const SizedBox(width: 12),
                  _ProgressCard(
                    icon: Icons.star_rounded,
                    value: '${membership.memCurrentPointsBalance}',
                    label: 'Poin',
                  ),
                  const SizedBox(width: 12),
                  _ProgressCard(
                    icon: Icons.qr_code_scanner_rounded,
                    value: '${membership.memTotalCheckinCount}',
                    label: 'Total Check-in',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _LastCheckinCard(lastCheckinAt: data.lastCheckinAt),
              if (data.activeClass != null) ...[
                const SizedBox(height: 24),
                _sectionTitle(context, 'Kelas Aktif'),
                const SizedBox(height: 12),
                _ActiveClassCard(activeClass: data.activeClass),
              ],
              const SizedBox(height: 24),
              _sectionTitle(context, 'Aktivitas Terbaru'),
              const SizedBox(height: 12),
              _ActivityList(activities: data.activities),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: _adaptiveText(context, _mainText),
        fontWeight: FontWeight.w800,
      ),
    );
  }

  static Color _adaptiveText(BuildContext context, Color lightColor) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Theme.of(context).colorScheme.onSurface;
    }
    return lightColor;
  }

  static Color _adaptiveSecondary(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.68);
    }
    return _secondaryText;
  }

  static Color _cardColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.darkCardSurface;
    }
    return Colors.white;
  }

  static Color _cardBorder(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.darkBorder;
    }
    return _border;
  }

  static Color _cardText(BuildContext context) {
    return _adaptiveText(context, _mainText);
  }

  static Color _cardSecondary(BuildContext context) {
    return _adaptiveSecondary(context);
  }
}

class _Header extends StatelessWidget {
  final String userName;

  const _Header({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat datang,',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: _DashboardContent._adaptiveSecondary(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: _DashboardContent._adaptiveText(
              context,
              _DashboardContent._mainText,
            ),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _MembershipHero extends StatelessWidget {
  final MembershipEntity membership;
  final _DashboardData data;
  final String userId;

  const _MembershipHero({
    required this.membership,
    required this.data,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final start = membership.memMembershipStartDate;
    final end = membership.memMembershipEndDate;
    final period = '${_formatDate(start)} - ${_formatDate(end)}';
    final daysLeft = end == null ? 0 : end.difference(DateTime.now()).inDays;
    final safeDaysLeft = daysLeft < 0 ? 0 : daysLeft;
    final progress = _progressValue(start, end);
    final isActive = membership.memMembershipStatus == 'active';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heroColor = isDark
        ? AppColors.darkElevatedSurface
        : _DashboardContent._hero;
    final heroText = Colors.white;
    final heroSecondary = Colors.white.withValues(alpha: isDark ? 0.76 : 0.9);
    final imageOpacity = isDark ? 0.16 : 0.24;
    final overlayColor = Colors.black.withValues(alpha: isDark ? 0.58 : 0.32);
    final progressTrack = Colors.white.withValues(alpha: isDark ? 0.16 : 0.18);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: heroColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Stack(
        children: [
          if (data.gymImageUrl.isNotEmpty)
            Positioned.fill(
              child: Opacity(
                opacity: imageOpacity,
                child: Image.network(
                  data.gymImageUrl,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(decoration: BoxDecoration(color: overlayColor)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary),
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isActive
                            ? 'Membership Aktif'
                            : 'Membership Tidak Aktif',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  data.gymName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: heroText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Periode: $period',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: heroSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                FractionallySizedBox(
                  widthFactor: 0.78,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: progressTrack,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 360;
                    final remaining = Text(
                      '$safeDaysLeft hari tersisa',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: heroText,
                        fontWeight: FontWeight.w800,
                      ),
                    );
                    final button = _QrButton(
                      enabled:
                          isActive &&
                          userId.isNotEmpty &&
                          membership.memGymId.isNotEmpty,
                      gymId: membership.memGymId,
                      gymName: data.gymName,
                      userId: userId,
                    );

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          remaining,
                          const SizedBox(height: 16),
                          SizedBox(width: double.infinity, child: button),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: remaining),
                        const SizedBox(width: 16),
                        button,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static double _progressValue(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 0;
    final total = end.difference(start).inSeconds;
    if (total <= 0) return 0;
    final elapsed = DateTime.now().difference(start).inSeconds;
    return (elapsed / total).clamp(0, 1).toDouble();
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }
}

class _QrButton extends StatelessWidget {
  final bool enabled;
  final String gymId;
  final String gymName;
  final String userId;

  const _QrButton({
    required this.enabled,
    required this.gymId,
    required this.gymName,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: enabled
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DailyQrScreen(
                    gymId: gymId,
                    gymName: gymName,
                    userId: userId,
                  ),
                ),
              );
            }
          : null,
      icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
      label: const Text('Tampilkan QR Check-in'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.lightPrimaryText,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.38),
        disabledForegroundColor: AppColors.lightPrimaryText.withValues(
          alpha: 0.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ProgressCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 96;
          final iconSize = compact ? 34.0 : 38.0;
          final innerPadding = compact ? 10.0 : 12.0;
          final valueSize = compact ? 19.0 : 22.0;
          final labelSize = compact ? 10.5 : 11.5;

          return SizedBox(
            height: 116,
            child: Container(
              padding: EdgeInsets.all(innerPadding),
              decoration: BoxDecoration(
                color: _DashboardContent._cardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _DashboardContent._cardBorder(context),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: _DashboardContent._cardText(context),
                      size: compact ? 18 : 20,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _DashboardContent._cardText(context),
                          fontSize: valueSize,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _DashboardContent._cardSecondary(context),
                          fontSize: labelSize,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LastCheckinCard extends StatelessWidget {
  final DateTime? lastCheckinAt;

  const _LastCheckinCard({required this.lastCheckinAt});

  @override
  Widget build(BuildContext context) {
    final value = lastCheckinAt == null
        ? 'Belum ada check-in'
        : _formatActivityTime(lastCheckinAt!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DashboardContent._cardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _DashboardContent._cardBorder(context)),
      ),
      child: Row(
        children: [
          _LimeIcon(icon: Icons.schedule_rounded),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check-in Terakhir',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _DashboardContent._cardSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _DashboardContent._cardText(context),
                    fontWeight: FontWeight.w800,
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

class _ActiveClassCard extends StatelessWidget {
  final _ActiveClass? activeClass;

  const _ActiveClassCard({required this.activeClass});

  @override
  Widget build(BuildContext context) {
    final item = activeClass;
    if (item == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _DashboardContent._cardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _DashboardContent._cardBorder(context)),
        ),
        child: Text(
          'Belum ada kelas aktif.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: _DashboardContent._cardSecondary(context),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _DashboardContent._cardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _DashboardContent._cardBorder(context)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 92,
              height: 72,
              child: item.imageUrl.isEmpty
                  ? Container(
                      color: AppColors.primary.withValues(alpha: 0.16),
                      child: const Icon(
                        Icons.event_note_rounded,
                        color: _DashboardContent._mainText,
                        size: 30,
                      ),
                    )
                  : Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primary.withValues(alpha: 0.16),
                          child: const Icon(
                            Icons.event_note_rounded,
                            color: _DashboardContent._mainText,
                            size: 30,
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _DashboardContent._cardText(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 16,
                      color: _DashboardContent._cardSecondary(context),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.schedule,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _DashboardContent._cardSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => _showClassDetail(context, item),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            child: const Text('Lihat Detail'),
          ),
        ],
      ),
    );
  }

  void _showClassDetail(BuildContext context, _ActiveClass item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(
                    ctx,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(
                  item.schedule,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: _DashboardContent._adaptiveSecondary(ctx),
                  ),
                ),
                if (item.remainingSessions != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${item.remainingSessions} sesi tersisa',
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActivityList extends StatelessWidget {
  final List<_ActivityItem> activities;

  const _ActivityList({required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _DashboardContent._cardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _DashboardContent._cardBorder(context)),
        ),
        child: Text(
          'Belum ada aktivitas terbaru.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: _DashboardContent._cardSecondary(context),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _DashboardContent._cardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _DashboardContent._cardBorder(context)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < activities.length; i++) ...[
            _ActivityRow(activity: activities[i]),
            if (i != activities.length - 1)
              Divider(
                height: 1,
                indent: 72,
                color: _DashboardContent._cardBorder(context),
              ),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final _ActivityItem activity;

  const _ActivityRow({required this.activity});

  @override
  Widget build(BuildContext context) {
    final time = activity.timestamp == null
        ? '-'
        : _formatActivityTime(activity.timestamp!);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _LimeIcon(icon: activity.icon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _DashboardContent._cardText(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _DashboardContent._cardSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          if (activity.value != null) ...[
            const SizedBox(width: 12),
            Text(
              activity.value!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LimeIcon extends StatelessWidget {
  final IconData icon;

  const _LimeIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.22),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: _DashboardContent._cardText(context), size: 22),
    );
  }
}

String _formatActivityTime(DateTime date) {
  final now = DateTime.now();
  final time = DateFormat('HH.mm', 'id_ID').format(date);
  final isToday =
      now.year == date.year && now.month == date.month && now.day == date.day;
  if (isToday) return 'Hari ini, $time';
  return DateFormat('dd MMM yyyy, HH.mm', 'id_ID').format(date);
}

class _DashboardData {
  final String gymName;
  final String gymImageUrl;
  final _ActiveClass? activeClass;
  final List<_ActivityItem> activities;
  final DateTime? lastCheckinAt;

  const _DashboardData({
    required this.gymName,
    required this.gymImageUrl,
    required this.activeClass,
    required this.activities,
    required this.lastCheckinAt,
  });

  factory _DashboardData.empty() {
    return const _DashboardData(
      gymName: 'Gym Saya',
      gymImageUrl: '',
      activeClass: null,
      activities: [],
      lastCheckinAt: null,
    );
  }
}

class _ActiveClass {
  final String name;
  final String schedule;
  final String imageUrl;
  final int? remainingSessions;

  const _ActiveClass({
    required this.name,
    required this.schedule,
    required this.imageUrl,
    required this.remainingSessions,
  });
}

class _ActivityItem {
  final String title;
  final DateTime? timestamp;
  final IconData icon;
  final String? value;
  final bool isCheckin;

  const _ActivityItem({
    required this.title,
    required this.timestamp,
    required this.icon,
    required this.value,
    this.isCheckin = false,
  });
}
