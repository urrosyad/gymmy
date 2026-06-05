import 'package:flutter/material.dart';

class GymmyAppBarLogo extends StatelessWidget {
  const GymmyAppBarLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Image.asset(
        'assets/logos/gymmy_font.png',
        height: 15,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Text(
          'GYMMY',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
