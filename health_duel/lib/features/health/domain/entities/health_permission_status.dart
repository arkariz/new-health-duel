/// Health Permission Status - Domain enum
///
/// Represents the current state of health data permissions.
/// Pure Dart, no Flutter dependencies.
enum HealthPermissionStatus {
  /// User hasn't been asked for permission yet
  notDetermined,

  /// Permission granted - can read step data
  authorized,

  /// Health platform not available (Health Connect not installed, etc.)
  unavailable,

  /// Device doesn't support health data (no sensors, simulator, etc.)
  notSupported,
}

/// Extension methods for HealthPermissionStatus
extension HealthPermissionStatusX on HealthPermissionStatus {
  /// Whether we can fetch step data
  bool get canFetchSteps => this == HealthPermissionStatus.authorized;

  /// Whether we should show the permission request UI
  bool get shouldShowPermissionPrompt =>
      this == HealthPermissionStatus.notDetermined;

  /// Whether the health platform is available but permission not granted
  bool get isPermissionIssue =>
      this == HealthPermissionStatus.notDetermined;

  /// Whether it's a platform availability issue (not permission)
  bool get isPlatformIssue =>
      this == HealthPermissionStatus.unavailable || this == HealthPermissionStatus.notSupported;

  /// Human-readable description
  String get displayName {
    return switch (this) {
      HealthPermissionStatus.notDetermined => 'Not Determined',
      HealthPermissionStatus.authorized => 'Authorized',
      HealthPermissionStatus.unavailable => 'Unavailable',
      HealthPermissionStatus.notSupported => 'Not Supported',
    };
  }
}
