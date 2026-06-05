import 'package:flutter/material.dart';

class GymmyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const GymmyCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(12);

    return Material(
      color: isDark ? const Color(0xFF1E2228) : theme.colorScheme.surface,
      borderRadius: radius,
      elevation: isDark ? 0 : 2,
      shadowColor: isDark ? Colors.transparent : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: isDark ? Border.all(color: const Color(0xFF2D333B)) : null,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
