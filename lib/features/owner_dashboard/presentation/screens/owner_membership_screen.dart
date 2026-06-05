import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/gym_tenant/presentation/providers/gym_tenant_provider.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_edit_gym_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/widgets/owner_top_bar.dart';
import 'package:intl/intl.dart';

class OwnerMembershipScreen extends ConsumerStatefulWidget {
  const OwnerMembershipScreen({super.key});
  @override
  ConsumerState<OwnerMembershipScreen> createState() => _State();
}

class _State extends ConsumerState<OwnerMembershipScreen> {
  String _filter = 'Semua';
  String _query = '';
  final _searchCtrl = TextEditingController();
  final Map<String, Future<_MemberCardData>> _memberDataCache = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<_MemberCardData> _getMemberCardData(Map<String, dynamic> member) {
    final uid = (member['mem_user_uid'] ?? '').toString();
    final gymId = (member['mem_gym_id'] ?? '').toString();
    final rankId = (member['mem_current_rank_id'] ?? '').toString();
    final points = (member['mem_current_points_balance'] as num?)?.toInt() ?? 0;
    final cacheKey = '$uid|$gymId|$rankId|$points';
    return _memberDataCache.putIfAbsent(
      cacheKey,
      () => _fetchMemberCardData(
        uid: uid,
        gymId: gymId,
        rankId: rankId,
        points: points,
      ),
    );
  }

  Future<_MemberCardData> _fetchMemberCardData({
    required String uid,
    required String gymId,
    required String rankId,
    required int points,
  }) async {
    var name = 'Pengguna tidak diketahui';
    var email = '';
    try {
      if (uid.isNotEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('user_accounts_global')
            .doc(uid)
            .get();
        final data = doc.data();
        if (data != null) {
          name = (data['user_full_name'] ?? '').toString().trim();
          email = (data['user_email_address'] ?? '').toString().trim();
          if (name.isEmpty) {
            name = email.isNotEmpty
                ? email
                : uid.substring(0, uid.length.clamp(0, 8));
          }
        }
      }
    } catch (_) {}

    final rankName = await _resolveRankName(
      gymId: gymId,
      rankId: rankId,
      points: points,
    );
    return _MemberCardData(name: name, email: email, rankName: rankName);
  }

  Future<String> _resolveRankName({
    required String gymId,
    required String rankId,
    required int points,
  }) async {
    try {
      if (rankId.isNotEmpty) {
        final rankDoc = await FirebaseFirestore.instance
            .collection('gym_master_ranks')
            .doc(rankId)
            .get();
        final title = (rankDoc.data()?['rank_title_name'] ?? '')
            .toString()
            .trim();
        if (title.isNotEmpty) return title;
      }

      if (gymId.isEmpty) return 'Belum ada rank';
      final snap = await FirebaseFirestore.instance
          .collection('gym_master_ranks')
          .where('rank_parent_gym_id', isEqualTo: gymId)
          .get();
      final ranks =
          snap.docs
              .map((doc) => doc.data())
              .where((data) => data['rank_is_active'] != false)
              .toList()
            ..sort((a, b) {
              final aMin =
                  (a['rank_min_points_threshold'] as num?)?.toInt() ?? 0;
              final bMin =
                  (b['rank_min_points_threshold'] as num?)?.toInt() ?? 0;
              return bMin.compareTo(aMin);
            });
      for (final rank in ranks) {
        final minPoints =
            (rank['rank_min_points_threshold'] as num?)?.toInt() ?? 0;
        if (points >= minPoints) {
          final title = (rank['rank_title_name'] ?? '').toString().trim();
          if (title.isNotEmpty) return title;
        }
      }
    } catch (_) {}
    return 'Belum ada rank';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gymAsync = ref.watch(ownerGymProvider);
    final ownerName = ref.watch(authProvider).user?.fullName ?? 'Owner Gym';

    return Scaffold(
      appBar: OwnerTopBar(
        ownerName: ownerName,
        automaticallyImplyLeading: false,
        onAvatarTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OwnerEditGymScreen()),
        ),
      ),
      body: gymAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (gym) {
          if (gym == null) {
            return const Center(child: Text('Data gym tidak ditemukan'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Membership',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kelola data member gym kamu',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (value) =>
                          setState(() => _query = value.trim().toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Cari nama member...',
                        prefixIcon: const Icon(Icons.search_outlined),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _query = '');
                                },
                              ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.12,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.12,
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _chip(context, 'Semua'),
                          const SizedBox(width: 8),
                          _chip(context, 'Aktif'),
                          const SizedBox(width: 8),
                          _chip(context, 'Tidak Aktif'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _buildQuery(gym.gtIdKey),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Gagal memuat data: ${snapshot.error}'),
                      );
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) return _emptyState(theme);
                    return FutureBuilder<List<_MemberListItem>>(
                      future: _buildMemberItems(docs),
                      builder: (context, memberSnap) {
                        if (memberSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final items = _filterItems(memberSnap.data ?? []);
                        if (items.isEmpty) {
                          return Center(
                            child: Text(
                              _query.isEmpty
                                  ? 'Belum ada data membership'
                                  : 'Member tidak ditemukan',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.lightSecondaryText,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                          itemCount: items.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, i) =>
                              _memberTile(context, items[i], theme),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _buildQuery(String gymId) {
    var q = FirebaseFirestore.instance
        .collection('gym_members_registry')
        .where('mem_gym_id', isEqualTo: gymId);
    if (_filter == 'Aktif') {
      q = q.where('mem_membership_status', isEqualTo: 'active');
    }
    if (_filter == 'Tidak Aktif') {
      q = q.where('mem_membership_status', isEqualTo: 'inactive');
    }
    return q.snapshots();
  }

  Future<List<_MemberListItem>> _buildMemberItems(
    List<QueryDocumentSnapshot> docs,
  ) async {
    final items = <_MemberListItem>[];
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final cardData = await _getMemberCardData(data);
      items.add(_MemberListItem(member: data, cardData: cardData));
    }
    return items;
  }

  List<_MemberListItem> _filterItems(List<_MemberListItem> items) {
    if (_query.isEmpty) return items;
    return items.where((item) {
      final haystack = '${item.cardData.name} ${item.cardData.email}'
          .toLowerCase();
      return haystack.contains(_query);
    }).toList();
  }

  Widget _chip(BuildContext ctx, String label) {
    final sel = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary : Theme.of(ctx).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sel
                ? AppColors.primary
                : Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: sel
                ? AppColors.darkBackground
                : Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _emptyState(ThemeData theme) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.people_outline,
            size: 48,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Belum ada data membership',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Data member akan muncul setelah\nmember bergabung ke gym kamu.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    ),
  );

  Widget _memberTile(BuildContext ctx, _MemberListItem item, ThemeData theme) {
    final d = item.member;
    final df = DateFormat('dd MMM yyyy', 'id_ID');
    final startTs = d['mem_membership_start_date'];
    final endTs = d['mem_membership_end_date'];
    final start = startTs is Timestamp ? df.format(startTs.toDate()) : '-';
    final end = endTs is Timestamp ? df.format(endTs.toDate()) : '-';
    final checkins = (d['mem_total_checkin_count'] as num?)?.toInt() ?? 0;

    return InkWell(
      onTap: () => _showMemberDetail(ctx, item, theme),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.cardData.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.cardData.email.isEmpty ? '-' : item.cardData.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.lightSecondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Check-in $checkins kali - $start - $end',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.72,
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberDetail(
    BuildContext context,
    _MemberListItem item,
    ThemeData theme,
  ) {
    final d = item.member;
    final df = DateFormat('dd MMM yyyy', 'id_ID');
    final joinTs = d['mem_join_timestamp'];
    final startTs = d['mem_membership_start_date'];
    final endTs = d['mem_membership_end_date'];
    final lastTs = d['mem_last_checkin_at'];
    final join = joinTs is Timestamp ? df.format(joinTs.toDate()) : '-';
    final start = startTs is Timestamp ? df.format(startTs.toDate()) : '-';
    final end = endTs is Timestamp ? df.format(endTs.toDate()) : '-';
    final lastCheckin = lastTs is Timestamp ? df.format(lastTs.toDate()) : '-';
    final uid = (d['mem_user_uid'] ?? '').toString();
    final memberType = _membershipTypeLabel(
      (d['mem_membership_type'] ?? 'monthly').toString(),
    );
    final points = (d['mem_current_points_balance'] as num?)?.toInt() ?? 0;
    final streak = (d['mem_streak_consecutive_days'] as num?)?.toInt() ?? 0;
    final checkins = (d['mem_total_checkin_count'] as num?)?.toInt() ?? 0;
    final memberId = (d['mem_id_key'] ?? '').toString();
    final isFrozen = d['mem_is_frozen'] == true;
    final createdBy = (d['mem_created_by_owner_uid'] ?? '').toString();
    final statusInfo = _membershipStatusInfo(d);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.18,
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.15,
                      ),
                      child: Icon(
                        isFrozen ? Icons.pause : Icons.person,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.cardData.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            item.cardData.email.isEmpty
                                ? '-'
                                : item.cardData.email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.lightSecondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusInfo.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusInfo.label,
                        style: TextStyle(
                          color: statusInfo.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _stat('Poin', '$points'),
                    _stat('Streak', '$streak hari'),
                    _stat('Check-in', '$checkins'),
                  ],
                ),
                const SizedBox(height: 18),
                _infoRow(theme, 'Jenis membership', memberType),
                _infoRow(theme, 'Rank aktif', item.cardData.rankName),
                _infoRow(theme, 'Tanggal bergabung', join),
                _infoRow(theme, 'Periode', '$start - $end'),
                _infoRow(theme, 'Check-in terakhir', lastCheckin),
                _infoRow(theme, 'Status freeze', isFrozen ? 'Ya' : 'Tidak'),
                if (memberId.isNotEmpty) _infoRow(theme, 'ID member', memberId),
                if (uid.isNotEmpty) _infoRow(theme, 'UID user', uid),
                if (createdBy.isNotEmpty)
                  _infoRow(theme, 'Validator owner', createdBy),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String val) => Expanded(
    child: Column(
      children: [
        Text(
          val,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.lightSecondaryText,
          ),
        ),
      ],
    ),
  );

  Widget _infoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 122,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.lightSecondaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _membershipTypeLabel(String value) {
    switch (value.toLowerCase()) {
      case 'yearly':
        return 'Tahunan';
      case 'monthly':
        return 'Bulanan';
      case 'daily':
        return 'Harian';
      default:
        return value.isEmpty ? '-' : value;
    }
  }

  _MembershipStatusInfo _membershipStatusInfo(Map<String, dynamic> data) {
    if (data['mem_is_frozen'] == true) {
      return const _MembershipStatusInfo('Dibekukan', AppColors.warning);
    }

    final status = (data['mem_membership_status'] ?? 'inactive').toString();
    final endTs = data['mem_membership_end_date'];
    if (endTs is Timestamp && endTs.toDate().isBefore(DateTime.now())) {
      return const _MembershipStatusInfo('Expired', AppColors.error);
    }

    if (status == 'active') {
      return const _MembershipStatusInfo('Aktif', AppColors.success);
    }
    if (status == 'expired') {
      return const _MembershipStatusInfo('Expired', AppColors.error);
    }
    return const _MembershipStatusInfo('Tidak Aktif', AppColors.error);
  }
}

class _MemberCardData {
  final String name;
  final String email;
  final String rankName;

  const _MemberCardData({
    required this.name,
    required this.email,
    required this.rankName,
  });
}

class _MemberListItem {
  final Map<String, dynamic> member;
  final _MemberCardData cardData;

  const _MemberListItem({required this.member, required this.cardData});
}

class _MembershipStatusInfo {
  final String label;
  final Color color;

  const _MembershipStatusInfo(this.label, this.color);
}
