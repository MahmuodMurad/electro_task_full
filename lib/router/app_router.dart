import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/projects/presentation/screens/projects_screen.dart';
import '../features/projects/presentation/screens/project_detail_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';

import '../features/auth/presentation/screens/splash_screen.dart';

class AppRouter {
  static GoRouter router(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final authState = authCubit.state;
        final loc = state.matchedLocation;
        final isOnSplash = loc == '/splash';
        final isOnAuth = loc == '/login' || loc == '/register';

        if (authState is AuthInitial || authState is AuthLoading) {
          if (!isOnSplash) return '/splash';
          return null;
        }

        if (authState is AuthAuthenticated) {
          if (isOnSplash || isOnAuth) return '/projects';
          return null;
        }

        if (authState is AuthUnauthenticated) {
          if (!isOnAuth) return '/login';
          return null;
        }

        return null;
      },
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      routes: [
        GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
        GoRoute(
          path: '/projects',
          builder: (_, _) => const ProjectsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) => ProjectDetailScreen(
                projectId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      ],
    );
  }
}

/// Helper to bridge BLoC stream with GoRouter's Listenable-based refresh
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _subscription;

  GoRouterRefreshStream(Stream stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
