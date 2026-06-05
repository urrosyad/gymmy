import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/biodata/presentation/screens/biodata_detail_screen.dart';
import 'package:gymmy/features/member_dashboard/presentation/widgets/member_top_bar.dart';
import 'package:gymmy/features/membership/presentation/providers/active_membership_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MemberMyGymScreen extends ConsumerWidget {
  const MemberMyGymScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final membershipAsync = ref.watch(activeMembershipProvider);
    final memberName = ref.watch(authProvider).user?.fullName ?? 'Member';

    return Scaffold(
      appBar: MemberTopBar(
        memberName: memberName,
        automaticallyImplyLeading: false,
        onAvatarTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BiodataDetailScreen()),
        ),
      ),
      body: membershipAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _lockedState(context, theme),
        data: (mem) {
          if (mem == null || !mem.isActive) return _lockedState(context, theme);
          return _activeState(context, ref, theme, mem.memGymId);
        },
      ),
    );
  }

  Widget _activeState(
    BuildContext ctx,
    WidgetRef ref,
    ThemeData theme,
    String gymId,
  ) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gym Saya',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          TabBar(
            tabs: const [
              Tab(text: 'Peralatan'),
              Tab(text: 'Kelas'),
            ],
            labelColor: theme.colorScheme.onSurface,
            indicatorColor: AppColors.primary,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _equipList(ctx, theme, gymId),
                _classList(ctx, ref, theme, gymId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _equipList(BuildContext ctx, ThemeData theme, String gymId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('gym_equipments')
          .where('equip_parent_gym_id', isEqualTo: gymId)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text(
              'Belum ada peralatan',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightSecondaryText,
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
          itemCount: docs.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
          ),
          itemBuilder: (context, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            final imageUrl = _equipmentImageUrl(d);
            return InkWell(
              onTap: () => _showEquipmentDetail(context, theme, d),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _equipmentImageFallback(theme),
                        ),
                      )
                    else
                      _equipmentImageFallback(theme),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d['equip_name_label'] ?? '',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if ((d['equip_category_type'] ?? '')
                              .toString()
                              .isNotEmpty)
                            Text(
                              d['equip_category_type'],
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.lightSecondaryText,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _equipmentImageUrl(Map<String, dynamic> data) {
    const keys = [
      'equip_image_storage_url',
      'equip_image_url',
      'equip_photo_url',
      'equip_image_link',
      'image_url',
    ];
    for (final key in keys) {
      final value = (data[key] ?? '').toString().trim();
      if (value.isNotEmpty) return _normalizeEquipmentImageUrl(value);
    }
    return '';
  }

  String _normalizeEquipmentImageUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return value;

    if (uri.host.contains('drive.google.com')) {
      final segments = uri.pathSegments;
      final fileIndex = segments.indexOf('d');
      if (fileIndex != -1 && fileIndex + 1 < segments.length) {
        return 'https://drive.google.com/uc?export=view&id=${segments[fileIndex + 1]}';
      }
      final id = uri.queryParameters['id'];
      if (id != null && id.isNotEmpty) {
        return 'https://drive.google.com/uc?export=view&id=$id';
      }
    }

    if (uri.host.contains('dropbox.com')) {
      return uri
          .replace(queryParameters: {...uri.queryParameters, 'raw': '1'})
          .toString();
    }

    return value;
  }

  Widget _equipmentImageFallback(ThemeData theme) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.28),
        size: 28,
      ),
    );
  }

  Widget _classList(
    BuildContext ctx,
    WidgetRef ref,
    ThemeData theme,
    String gymId,
  ) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('gym_classes_catalog')
          .where('class_parent_gym_id', isEqualTo: gymId)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text(
              'Belum ada kelas',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightSecondaryText,
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
          itemCount: docs.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
          ),
          itemBuilder: (context, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            return InkWell(
              onTap: () => _showClassDetail(ctx, ref, theme, d, docs[i].id),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_note,
                      color: Color(0xFF059669),
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d['class_title_name'] ?? '',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            d['class_schedule_text'] ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.lightSecondaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currency.format(
                              (d['class_pricing_amount'] as num?)?.toDouble() ??
                                  0,
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEquipmentDetail(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> data,
  ) {
    final imageUrl = _equipmentImageUrl(data);
    final videoUrl = (data['equip_tutorial_video_link'] ?? '').toString();
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
                if (imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => SizedBox(
                        height: 160,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.28,
                          ),
                          size: 40,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 160,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.28,
                      ),
                      size: 40,
                    ),
                  ),
                const SizedBox(height: 18),
                Text(
                  (data['equip_name_label'] ?? '').toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  (data['equip_category_type'] ?? '').toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightSecondaryText,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Instruksi Penggunaan',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  (data['equip_usage_instruction_text'] ?? '-').toString(),
                  style: theme.textTheme.bodyMedium,
                ),
                if (videoUrl.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Video Tutorial',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    videoUrl,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showClassDetail(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Map<String, dynamic> data,
    String docId,
  ) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final userId = ref.read(authProvider).user?.uid ?? '';
    final classId = (data['class_id_key'] ?? docId).toString();
    var saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBS) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (data['class_title_name'] ?? '').toString(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (data['class_schedule_text'] ?? '').toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightSecondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _detailPill(
                        theme,
                        Icons.payments_outlined,
                        currency.format(
                          (data['class_pricing_amount'] as num?)?.toDouble() ??
                              0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _detailPill(
                        theme,
                        Icons.confirmation_number_outlined,
                        '${(data['class_session_count'] as num?)?.toInt() ?? 0} sesi',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Deskripsi',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (data['class_description_text'] ?? '-').toString(),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: saving
                          ? null
                          : () async {
                              setBS(() => saving = true);
                              try {
                                await _subscribeClass(
                                  userId: userId,
                                  gymId: (data['class_parent_gym_id'] ?? '')
                                      .toString(),
                                  classId: classId,
                                  classDocId: docId,
                                  sessionCount:
                                      (data['class_session_count'] as num?)
                                          ?.toInt() ??
                                      0,
                                );
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Berhasil berlangganan kelas',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                setBS(() => saving = false);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Gagal berlangganan kelas: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.darkBackground,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Langganan Kelas'),
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

  Widget _detailPill(ThemeData theme, IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _subscribeClass({
    required String userId,
    required String gymId,
    required String classId,
    required String classDocId,
    required int sessionCount,
  }) async {
    if (userId.isEmpty || gymId.isEmpty || classId.isEmpty) {
      throw Exception('Data kelas tidak lengkap');
    }
    final fs = FirebaseFirestore.instance;
    final existing = await fs
        .collection('gym_class_subscriptions')
        .where('class_sub_user_uid', isEqualTo: userId)
        .get();
    final alreadyActive = existing.docs.any((doc) {
      final data = doc.data();
      return data['class_sub_class_id'] == classId &&
          data['class_sub_status'] == 'active';
    });
    if (alreadyActive) {
      throw Exception('Kamu sudah berlangganan kelas ini');
    }

    final subRef = fs.collection('gym_class_subscriptions').doc();
    await fs.runTransaction((transaction) async {
      transaction.set(subRef, {
        'class_sub_id_key': subRef.id,
        'class_sub_user_uid': userId,
        'class_sub_gym_id': gymId,
        'class_sub_class_id': classId,
        'class_sub_status': 'active',
        'class_sub_created_at': FieldValue.serverTimestamp(),
        'class_sub_remaining_sessions': sessionCount,
      });
      transaction.update(fs.collection('gym_classes_catalog').doc(classDocId), {
        'class_current_subscribers': FieldValue.increment(1),
      });
    });
  }

  Widget _lockedState(BuildContext ctx, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 56,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gym Saya',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ayo gabung sebagai member gym terlebih dahulu.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => ctx.go('/member/home'),
              icon: const Icon(Icons.search),
              label: const Text('Cari Gym'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.darkBackground,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
