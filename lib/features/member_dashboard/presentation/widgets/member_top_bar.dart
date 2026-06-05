import 'package:flutter/material.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/core/widgets/gymmy_app_bar_logo.dart';

class MemberTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String memberName;
  final VoidCallback? onAvatarTap;
  final bool automaticallyImplyLeading;

  const MemberTopBar({
    super.key,
    required this.memberName,
    this.onAvatarTap,
    this.automaticallyImplyLeading = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatar = CircleAvatar(
      radius: 18,
      backgroundColor: theme.brightness == Brightness.dark
          ? AppColors.primary
          : AppColors.primary.withValues(alpha: 0.16),
      child: Text(
        _initials(memberName),
        style: const TextStyle(
          color: AppColors.darkOnLime,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      title: const GymmyAppBarLogo(),
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: theme.colorScheme.outline.withValues(alpha: 0.28),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: onAvatarTap == null
              ? avatar
              : InkWell(
                  onTap: onAvatarTap,
                  customBorder: const CircleBorder(),
                  child: avatar,
                ),
        ),
      ],
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'M';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
