
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gymmy/core/providers/onboarding_provider.dart';
import 'package:gymmy/core/providers/user_flow_provider.dart';
import 'package:gymmy/core/routing/route_names.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_state.dart';
import 'package:gymmy/features/auth/presentation/screens/login_screen.dart';
import 'package:gymmy/features/auth/presentation/screens/register_screen.dart';
import 'package:gymmy/features/biodata/presentation/screens/biodata_onboarding_screen.dart';
import 'package:gymmy/features/gym_tenant/presentation/screens/gym_discovery_screen.dart';
import 'package:gymmy/features/gym_tenant/presentation/screens/owner_gym_setup_screen.dart';
import 'package:gymmy/features/member_dashboard/presentation/screens/member_dashboard_screen.dart';
import 'package:gymmy/features/member_dashboard/presentation/screens/member_shell_screen.dart';
import 'package:gymmy/features/member_dashboard/presentation/screens/member_activity_screen.dart';
import 'package:gymmy/features/member_dashboard/presentation/screens/member_profile_screen.dart';
import 'package:gymmy/features/member_dashboard/presentation/screens/member_my_gym_screen.dart';
import 'package:gymmy/features/member_dashboard/presentation/screens/member_scan_placeholder_screen.dart';
import 'package:gymmy/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_dashboard_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_shell_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_manage_data_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_membership_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_profile_screen.dart';
import 'package:gymmy/features/owner_dashboard/presentation/screens/owner_scan_placeholder_screen.dart';
import 'package:gymmy/features/splash/presentation/screens/splash_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(WidgetRef ref) {
  final notifier = _AppStateNotifier(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, routerState) {
      final authState = ref.read(authProvider);
      final hasSeenOnboarding = ref.read(onboardingProvider);
      final flow = ref.read(userFlowProvider);
      final location = routerState.uri.toString();

      // --- Auth checking ---
      final isChecking = authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.checkingSession;

      if (isChecking) return location == '/' ? null : '/';

      // --- Unauthenticated ---
      if (flow == AppDestination.unauthenticated) {
        if (location == '/login' ||
            location == '/register' ||
            location == '/onboarding') {
          return null;
        }
        return hasSeenOnboarding ? '/login' : '/onboarding';
      }

      // --- Still loading flow data ---
      if (flow == AppDestination.loading) {
        return location == '/' ? null : '/';
      }

      // --- Authenticated: block auth/onboarding pages ---
      if (location == '/login' ||
          location == '/register' ||
          location == '/onboarding' ||
          location == '/') {
        return _destinationPath(flow);
      }

      // --- Protect specific routes ---
      if (location == '/biodata-onboarding' &&
          flow != AppDestination.biodataOnboarding) {
        return _destinationPath(flow);
      }

      if (location == '/owner-setup' && flow != AppDestination.ownerSetup) {
        return _destinationPath(flow);
      }

      if (location.startsWith('/owner')) {
        if (flow != AppDestination.ownerDashboard) {
          return _destinationPath(flow);
        }
        return null;
      }

      // Member Shell Routes
      if (location.startsWith('/member')) {
        if (flow != AppDestination.gymDiscovery && flow != AppDestination.memberDashboard) {
          return _destinationPath(flow);
        }
        return null; // Let them navigate within member shell
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
        path: '/biodata-onboarding',
        name: RouteNames.biodataOnboarding,
        builder: (context, state) => const BiodataOnboardingScreen(),
      ),
      GoRoute(
        path: '/owner-setup',
        name: RouteNames.ownerSetup,
        builder: (context, state) => const OwnerGymSetupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return OwnerShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/owner/home',
                name: RouteNames.ownerDashboard,
                builder: (context, state) => const OwnerDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/owner/manage',
                name: RouteNames.ownerManage,
                builder: (context, state) => const OwnerManageDataScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/owner/scan',
                name: RouteNames.ownerScan,
                builder: (context, state) => const OwnerScanPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/owner/membership',
                name: RouteNames.ownerMembership,
                builder: (context, state) => const OwnerMembershipScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/owner/profile',
                name: RouteNames.ownerProfile,
                builder: (context, state) => const OwnerProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MemberShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/member/home',
                name: RouteNames.memberHome,
                builder: (context, state) {
                  return Consumer(builder: (context, ref, _) {
                    final flow = ref.watch(userFlowProvider);
                    if (flow == AppDestination.memberDashboard) {
                      return const MemberDashboardScreen();
                    }
                    return const GymDiscoveryScreen();
                  });
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/member/my-gym',
                name: RouteNames.memberMyGym,
                builder: (context, state) => const MemberMyGymScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/member/scan',
                name: RouteNames.memberScan,
                builder: (context, state) => const MemberScanPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/member/activity',
                name: RouteNames.memberActivity,
                builder: (context, state) => const MemberActivityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/member/profile',
                name: RouteNames.memberProfile,
                builder: (context, state) => const MemberProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

String _destinationPath(AppDestination dest) {
  switch (dest) {
    case AppDestination.biodataOnboarding:
      return '/biodata-onboarding';
    case AppDestination.gymDiscovery:
    case AppDestination.memberDashboard:
      return '/member/home';
    case AppDestination.ownerSetup:
      return '/owner-setup';
    case AppDestination.ownerDashboard:
      return '/owner/home';
    case AppDestination.loading:
      return '/';
    case AppDestination.unauthenticated:
      return '/login';
  }
}

class _AppStateNotifier extends ChangeNotifier {
  _AppStateNotifier(WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (previous, next) => notifyListeners());
    ref.listen<bool>(onboardingProvider, (previous, next) => notifyListeners());
    ref.listen<AppDestination>(userFlowProvider, (previous, next) => notifyListeners());
  }
}
