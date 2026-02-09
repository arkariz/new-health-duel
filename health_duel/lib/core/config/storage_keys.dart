/// Storage Keys Configuration
///
/// Follows [ADR-003 Hybrid Storage Key Strategy].
/// Only truly global/shared keys are defined here.
/// Feature-specific keys must be defined in their respective data sources
/// using the format: `feature_{feature_name}_{box_type}`.
class StorageKeys {
  StorageKeys._();

  /// Key for storing application preferences (Theme, Locale, etc.)
  static const String appPreferences = 'app_preferences';

  /// Key for secure storage of authentication tokens
  static const String authToken = 'auth_token';

  /// Key for encryption keys used by Hive
  static const String secureKeyStorage = 'secure_keys';
}
