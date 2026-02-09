import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_duel/core/di/injection.dart';
import 'package:health_duel/core/router/go_router_refresh.dart';
import 'package:health_duel/core/router/routes.dart';
import 'package:health_duel/features/auth/auth.dart';
import 'package:health_duel/features/health/health.dart';
import 'package:health_duel/features/home/home.dart';

/// Creates GoRouter with auth-aware redirects
///
/// Uses [AuthBloc] state to determine redirect behavior:
/// - Unauthenticated users on protected routes → `/login`
/// - Authenticated users on auth routes → `/home`
GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) => _authRedirect(authBloc, state),
    routes: [
      // ═══════════════════════════════════════════════════════════════════════
      // Auth Routes (Public)
      // ═══════════════════════════════════════════════════════════════════════
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (_, __) => const RegisterPage(),
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // Protected Routes
      // ═══════════════════════════════════════════════════════════════════════
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (_, __) => BlocProvider(create: (_) => getIt<HomeBloc>(), child: const HomePage()),
      ),
      GoRoute(
        path: AppRoutes.health,
        name: 'health',
        builder: (_, __) => BlocProvider(create: (_) => getIt<HealthBloc>(), child: const HealthPage()),
      ),
    ],
  );
}

/// Centralized auth redirect logic
///
/// Returns redirect path or null if no redirect needed.
String? _authRedirect(AuthBloc authBloc, GoRouterState state) {
  final authState = authBloc.state;
  final isLoading = authState is AuthLoading || authState is AuthInitial;
  final isAuthenticated = authState is AuthAuthenticated;
  final currentPath = state.matchedLocation;
  final isPublicRoute = AppRoutes.isPublicRoute(currentPath);

  // Still loading auth state → no redirect yet
  if (isLoading) {
    return null;
  }

  // Not authenticated → go to login (preserve intended destination)
  if (!isAuthenticated && !isPublicRoute) {
    final encodedPath = Uri.encodeComponent(currentPath);
    return '${AppRoutes.login}?redirect=$encodedPath';
  }

  // Authenticated but on auth route → go to home (or redirect param)
  if (isAuthenticated && isPublicRoute) {
    final redirectParam = state.uri.queryParameters['redirect'];
    if (redirectParam != null) {
      return Uri.decodeComponent(redirectParam);
    }
    return AppRoutes.home;
  }

  // No redirect needed
  return null;
}
