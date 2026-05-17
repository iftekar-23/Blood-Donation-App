import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/donors/screens/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/requests/screens/blood_request_screen.dart';
import '../../features/requests/screens/my_requests_screen.dart';
import '../../features/donors/screens/donate_screen.dart';

part 'app_router.g.dart';


class AppRoutes {
  static const splash = '/';
  static const signIn = '/sign-in';
  static const register = '/register';
  static const home = '/home';
  static const profile = '/profile';
  static const bloodRequest = '/blood-request';
  static const myRequests = '/my-requests';
  static const donate = '/donate';
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isAuthRoute = state.matchedLocation == AppRoutes.signIn ||
          state.matchedLocation == AppRoutes.register;

      if (isSplash) return null;

      if (isLoggedIn && isAuthRoute) return AppRoutes.home;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.bloodRequest,
        builder: (_, __) => const BloodRequestScreen(),
      ),
      GoRoute(
        path: AppRoutes.myRequests,
        builder: (_, __) => const MyRequestsScreen(),
      ),
      GoRoute(
        path: AppRoutes.donate,
        builder: (_, __) => const DonateScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
}
