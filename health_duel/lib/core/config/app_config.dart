import 'package:health_duel/core/config/env/env_variables.dart';
import 'package:health_duel/core/config/env/flavors.dart';

/// Environment Flavor Enum
enum Environment { dev, prod }

/// Main Application Configuration
///
/// Manages environment-specific settings and provides centralized access
/// to configuration values across the application.
///
/// Uses `envied` package for secure environment variable management.
///
/// Usage:
/// ```dart
/// void main() {
///   AppConfig.init(Environment.dev);
///   runApp(MyApp());
/// }
///
/// // Access configuration anywhere
/// final apiUrl = AppConfig.env.baseUrl;
/// final isDebug = AppConfig.env.isDebug;
/// ```
class AppConfig {
  AppConfig._(); // Private constructor to prevent instantiation

  static late EnvVariables _env;
  static late Environment _flavor;
  static bool _initialized = false;

  /// Initialize the application configuration with a specific flavor
  ///
  /// Must be called before accessing [env] or [flavor].
  /// Typically called in main() before runApp().
  ///
  /// Throws [StateError] if called more than once.
  static void init(Environment flavor) {
    if (_initialized) {
      throw StateError('AppConfig.init() called multiple times');
    }

    _flavor = flavor;
    switch (flavor) {
      case Environment.dev:
        _env = EnvDev();
        break;
      case Environment.prod:
        _env = Env();
        break;
    }

    _initialized = true;
  }

  /// Access to environment-specific variables
  ///
  /// Throws [StateError] if accessed before [init] is called.
  static EnvVariables get env {
    _ensureInitialized();
    return _env;
  }

  /// Current active flavor
  ///
  /// Throws [StateError] if accessed before [init] is called.
  static Environment get flavor {
    _ensureInitialized();
    return _flavor;
  }

  /// Check if configuration has been initialized
  static bool get isInitialized => _initialized;

  /// Check if running in development mode
  static bool get isDev => _initialized && _flavor == Environment.dev;

  /// Check if running in production mode
  static bool get isProd => _initialized && _flavor == Environment.prod;

  /// Reset configuration (mainly for testing)
  static void reset() {
    _initialized = false;
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'AppConfig not initialized. Call AppConfig.init(flavor) first.',
      );
    }
  }
}

