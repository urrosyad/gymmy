import 'package:flutter/material.dart';

class OwnerScanPlaceholderScreen extends StatelessWidget {
  const OwnerScanPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scan is handled via bottom sheet in OwnerShellScreen.
    // This route is kept for router branch compatibility.
    return const SizedBox.shrink();
  }
}
