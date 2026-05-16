import 'package:flutter/material.dart';

class MemberScanPlaceholderScreen extends StatelessWidget {
  const MemberScanPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scan is handled via bottom sheet in MemberShellScreen.
    // This route is kept for router branch compatibility.
    return const SizedBox.shrink();
  }
}
