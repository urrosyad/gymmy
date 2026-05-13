import 'package:go_router/go_router.dart';
import 'package:gymmy/core/routing/route_names.dart';
import 'package:gymmy/features/splash/presentation/screens/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
  ],
);
