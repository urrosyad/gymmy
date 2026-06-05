import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymmy/core/providers/onboarding_provider.dart';
import 'package:gymmy/core/routing/route_names.dart';
import 'package:gymmy/core/theme/app_colors.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      assetPath: 'assets/logos/gym_onboarding.png',
      accentIcon: Icons.bolt_rounded,
      imageScale: 0.9,
      titleLineOne: 'Semua Aktivitas Gym',
      titleLineTwo: 'dalam Satu Aplikasi',
      description:
          'Temukan gym, kelola membership, dan akses fasilitas dengan lebih praktis.',
    ),
    _OnboardingPageData(
      assetPath: 'assets/logos/qr_onboarding.png',
      accentIcon: Icons.qr_code_2_rounded,
      titleLineOne: 'Check-in Lebih Cepat',
      titleLineTwo: 'dengan QR',
      description:
          'Gunakan QR untuk akses harian, membership, dan aktivitas gym dengan lebih praktis.',
    ),
    _OnboardingPageData(
      assetPath: 'assets/logos/rank_onboarding.png',
      accentIcon: Icons.star_rounded,
      titleLineOne: 'Bangun Konsistensi',
      titleLineTwo: 'dan Raih Progress',
      description:
          'Pantau aktivitas, kumpulkan poin, dan tingkatkan rank dari setiap kunjungan.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }
    _finishOnboarding();
  }

  void _finishOnboarding() {
    ref.read(onboardingProvider.notifier).completeOnboarding();
    context.goNamed(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFDF9),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.lightSecondaryText,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    textStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Lewati'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(page: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  _PageIndicator(
                    length: _pages.length,
                    currentIndex: _currentPage,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _nextPage,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.lightPrimaryText,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Mulai' : 'Lanjut',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData page;

  const _OnboardingPage({required this.page});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 520;
        final titleStyle = theme.textTheme.headlineSmall?.copyWith(
          color: AppColors.lightPrimaryText,
          fontSize: compact ? 23 : 25,
          fontWeight: FontWeight.w900,
          height: 1.16,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                flex: compact ? 7 : 8,
                child: Center(
                  child: OverflowBox(
                    maxWidth: constraints.maxWidth * 1.22,
                    maxHeight: constraints.maxHeight * (compact ? 0.62 : 0.68),
                    child: Transform.scale(
                      scale: page.imageScale,
                      child: Image.asset(
                        page.assetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: compact ? 16 : 22),
              _HexagonAccentIcon(icon: page.accentIcon),
              SizedBox(height: compact ? 18 : 26),
              Text(
                '${page.titleLineOne}\n${page.titleLineTwo}',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
              SizedBox(height: compact ? 12 : 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 330),
                child: Text(
                  page.description,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightSecondaryText,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        );
      },
    );
  }
}

class _HexagonAccentIcon extends StatelessWidget {
  final IconData icon;

  const _HexagonAccentIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HexagonOutlinePainter(),
      child: SizedBox(
        width: 38,
        height: 42,
        child: Center(
          child: Icon(icon, color: AppColors.lightPrimaryText, size: 18),
        ),
      ),
    );
  }
}

class _HexagonOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.5, 1)
      ..lineTo(size.width - 2, size.height * 0.25)
      ..lineTo(size.width - 2, size.height * 0.75)
      ..lineTo(size.width * 0.5, size.height - 1)
      ..lineTo(2, size.height * 0.75)
      ..lineTo(2, size.height * 0.25)
      ..close();

    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PageIndicator extends StatelessWidget {
  final int length;
  final int currentIndex;

  const _PageIndicator({required this.length, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final active = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: active ? 28 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.26),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _OnboardingPageData {
  final String assetPath;
  final IconData accentIcon;
  final double imageScale;
  final String titleLineOne;
  final String titleLineTwo;
  final String description;

  const _OnboardingPageData({
    required this.assetPath,
    required this.accentIcon,
    this.imageScale = 1,
    required this.titleLineOne,
    required this.titleLineTwo,
    required this.description,
  });
}
