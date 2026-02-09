/// Connectivity state enum
///
/// Represents the device's network connectivity status.
enum ConnectivityStatus {
  /// Device is online (wifi, mobile, ethernet, etc.)
  online,

  /// Device is offline
  offline,

  /// Initial state before first check
  unknown;

  /// Check if this status represents online connectivity
  bool get isOnline => this == ConnectivityStatus.online;

  /// Check if this status represents offline state
  bool get isOffline => this == ConnectivityStatus.offline;

  /// Check if this is the initial unknown state
  bool get isUnknown => this == ConnectivityStatus.unknown;
}
