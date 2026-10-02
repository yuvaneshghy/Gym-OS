import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/members/presentation/member_home_screen.dart';

/// The global GoRouter configuration as a Riverpod provider.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // If we are still loading the auth state, don't redirect yet.
      if (authState.isLoading) return null;

      final isAuth = authState.value != null;
      final isLoggingIn = state.uri.path == '/login';

      if (!isAuth) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        // If logged in, check role for home page routing
        final role = ref.read(authRepositoryProvider).currentRole;
        if (role == 'MEMBER') {
          return '/member';
        }
        return '/dashboard'; // Admin and Staff go to dashboard
      }

      // Root path redirect
      if (state.uri.path == '/') {
        final role = ref.read(authRepositoryProvider).currentRole;
        return role == 'MEMBER' ? '/member' : '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/member',
        builder: (context, state) => const MemberHomeScreen(),
      ),
    ],
  );
});
