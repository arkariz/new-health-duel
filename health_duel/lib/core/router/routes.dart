/// Type-safe route definitions
///
/// Usage: `context.go(AppRoutes.home)`
/// With params: `context.go(AppRoutes.duelPath('duel-123'))`
library;

abstract final class AppRoutes {
  // ═══════════════════════════════════════════════════════════════════════════
  // Auth Routes (Public)
  // ═══════════════════════════════════════════════════════════════════════════

  static const login = '/login';
  static const register = '/register';

  // ═══════════════════════════════════════════════════════════════════════════
  // Main Routes (Protected)
  // ═══════════════════════════════════════════════════════════════════════════

  static const home = '/home';
  static const health = '/health';
  static const settings = '/settings';
  static const profile = '/profile';

  // ═══════════════════════════════════════════════════════════════════════════
  // Duel Routes (Protected)
  // ═══════════════════════════════════════════════════════════════════════════

  static const duels = '/duels';
  static const duel = '/duel/:id';

  /// Build duel path with ID
  static String duelPath(String id) => '/duel/$id';

  // ═══════════════════════════════════════════════════════════════════════════
  // Deep Link Routes
  // ═══════════════════════════════════════════════════════════════════════════

  static const invite = '/invite/:code';

  /// Build invite path with code
  static String invitePath(String code) => '/invite/$code';

  // ═══════════════════════════════════════════════════════════════════════════
  // Route Sets (for redirect logic)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Routes that don't require authentication
  static const publicRoutes = {login, register};

  /// Check if route is public
  static bool isPublicRoute(String path) {
    return publicRoutes.any((route) => path.startsWith(route));
  }
}
