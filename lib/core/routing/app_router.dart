import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymmy/core/routing/route_names.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_state.dart';
import 'package:gymmy/core/providers/onboarding_provider.dart';
import 'package:gymmy/features/auth/presentation/screens/login_screen.dart';
import 'package:gymmy/features/auth/presentation/screens/register_screen.dart';
import 'package:gymmy/features/member_dashboard/presentation/screens/member_dashboard_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_dashboard_screen.dart';
import 'package:gymmy/features/splash/presentation/screens/splash_screen.dart';
import 'package:gymmy/features/onboarding/presentation/screens/onboarding_screen.dart';

/// Creates a [GoRouter] that listens to Riverpod [authProvider] for redirects.
GoRouter createRouter(WidgetRef ref) {
  final authListenable = _AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authListenable,
    redirect: (context, routerState) {
      final authState = ref.read(authProvider);
      final hasSeenOnboarding = ref.read(onboardingProvider);
      final location = routerState.uri.toString();

      final isCheckingSession = authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.checkingSession;
      final isAuthenticated = authState.status == AuthStatus.authenticated;

      final isOnSplash = location == '/';
      final isOnOnboarding = location == '/onboarding';
      final isOnAuth = location == '/login' || location == '/register';

      // Stay on splash while resolving session
      if (isCheckingSession) return isOnSplash ? null : '/';

      // Once resolved: route from splash
      if (isOnSplash) {
        if (isAuthenticated) {
          return authState.user?.isOwner == true
              ? '/owner-dashboard'
              : '/member-dashboard';
        }
        return hasSeenOnboarding ? '/login' : '/onboarding';
      }

      // Redirect authenticated users away from auth and onboarding screens
      if (isAuthenticated && (isOnAuth || isOnOnboarding)) {
        return authState.user?.isOwner == true
            ? '/owner-dashboard'
            : '/member-dashboard';
      }

      // If unauthenticated and on onboarding, but already saw it, go to login
      if (!isAuthenticated && isOnOnboarding && hasSeenOnboarding) {
        return '/login';
      }

      // Redirect unauthenticated from protected screens to onboarding or login
      if (!isAuthenticated && !isOnAuth && !isOnSplash && !isOnOnboarding) {
        return hasSeenOnboarding ? '/login' : '/onboarding';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/owner-dashboard',
        name: RouteNames.ownerDashboard,
        builder: (context, state) => const OwnerDashboardScreen(),
      ),
      GoRoute(
        path: '/member-dashboard',
        name: RouteNames.memberDashboard,
        builder: (context, state) => const MemberDashboardScreen(),
      ),
    ],
  );
}

/// Bridges Riverpod auth state into a [Listenable] for [GoRouter.refreshListenable].
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (prev, next) => notifyListeners());
    // Also listen to onboarding changes to trigger redirects
    ref.listen<bool>(onboardingProvider, (prev, next) => notifyListeners());
  }
}
