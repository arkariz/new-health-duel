import 'package:health/health.dart';
import 'package:health_duel/features/health/data/models/models.dart';
import 'package:health_duel/features/health/domain/entities/entities.dart';

/// Health Platform Data Source Interface
///
/// Wraps the health plugin for platform-specific health data access.
/// Throws [HealthDataSourceException] on errors.
abstract class HealthPlatformDataSource {
  /// Check current permission status
  Future<HealthPermissionStatus> checkPermissions();

  /// Request health data permissions
  /// Returns true if granted, false if denied
  Future<bool> requestPermissions();

  /// Get step count for specific time range
  ///
  /// Returns raw data from health platform.
  /// Domain validation happens in use case layer.
  Future<StepCountRaw> getStepCount({required DateTime startTime, required DateTime endTime});

  /// Get today's step count (convenience method)
  ///
  /// Returns raw data from health platform.
  Future<StepCountRaw> getTodaySteps();

  /// Check if Health Connect is available (Android only)
  /// Always returns true on iOS
  Future<bool> isHealthConnectAvailable();

  /// Revoke all health permissions
  Future<void> revokePermissions();
}

/// Health Data Source Exception
///
/// Custom exception for health plugin errors.
/// Mapped to domain Failures in repository layer.
class HealthDataSourceException implements Exception {
  final String message;
  final String code;
  final dynamic originalError;

  const HealthDataSourceException({
    required this.message,
    required this.code,
    this.originalError,
  });

  @override
  String toString() => 'HealthDataSourceException($code): $message';
}

/// Health Platform Data Source Implementation
///
/// Uses the health plugin for HealthKit (iOS) and Health Connect (Android).
/// All platform-specific logic is encapsulated here.
class HealthPlatformDataSourceImpl implements HealthPlatformDataSource {
  final Health _health;

  /// Data types we need access to
  static const List<HealthDataType> _stepTypes = [HealthDataType.STEPS];

  /// Permission types matching the data types
  static const List<HealthDataAccess> _accessTypes = [HealthDataAccess.READ];

  HealthPlatformDataSourceImpl({Health? health}) : _health = health ?? Health();

  @override
  Future<HealthPermissionStatus> checkPermissions() async {
    try {
      // Initialize Health Connect (Android)
      // This is required before any other operations on Android
      await _health.configure();

      // Check Health Connect availability first (Android)
      final isConnectAvailable = await _health.isHealthConnectAvailable();

      // On Android, if Health Connect SDK not available, platform is unavailable
      // On iOS, isHealthConnectAvailable returns false but HealthKit is still available
      if (!isConnectAvailable) {
        // iOS path: check if HealthKit is available
        final hasPermissions = await _health.hasPermissions(_stepTypes);

        if (hasPermissions == null) {
          // iOS simulator or HealthKit not available on device
          return HealthPermissionStatus.notSupported;
        }

        // HealthKit available
        return hasPermissions
            ? HealthPermissionStatus.authorized
            : HealthPermissionStatus.notDetermined;
      }

      // Android path: Health Connect is available
      final hasPermissions = await _health.hasPermissions(_stepTypes);

      if (hasPermissions == null) {
        // Health Connect installed but SDK issue - treat as not supported
        return HealthPermissionStatus.notSupported;
      }

      // Note: hasPermissions == false could mean:
      // - Never asked (notDetermined)
      // - User denied (denied)
      // We can't distinguish, so treat as notDetermined and let user try again.
      // The requestPermissions() result will tell us if user denies.
      return hasPermissions
          ? HealthPermissionStatus.authorized
          : HealthPermissionStatus.notDetermined;
    } catch (e) {
      throw HealthDataSourceException(
        message: 'Failed to check health permissions',
        code: 'check_permissions_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      // Configure health plugin
      await _health.configure();

      // Request permissions for step data
      final granted = await _health.requestAuthorization(
        _stepTypes,
        permissions: _accessTypes,
      );

      return granted;
    } catch (e) {
      throw HealthDataSourceException(
        message: 'Failed to request health permissions',
        code: 'request_permissions_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<StepCountRaw> getStepCount({required DateTime startTime, required DateTime endTime}) async {
    try {
      // Fetch step data points
      final dataPoints = await _health.getHealthDataFromTypes(
        types: _stepTypes,
        startTime: startTime,
        endTime: endTime,
      );

      // Aggregate step count
      final totalSteps = _aggregateSteps(dataPoints);

      // Detect manual entries
      final hasManualEntries = _hasManualEntries(dataPoints);

      // Get source device info (from first data point)
      final sourceDevice = dataPoints.isNotEmpty
          ? dataPoints.first.deviceModel
          : null;

      return StepCountRaw(
        value: totalSteps,
        startTime: startTime,
        endTime: endTime,
        sourceDevice: sourceDevice,
        hasManualEntries: hasManualEntries,
      );
    } catch (e) {
      throw HealthDataSourceException(
        message: 'Failed to fetch step count data',
        code: 'fetch_steps_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<StepCountRaw> getTodaySteps() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    return getStepCount(startTime: midnight, endTime: now);
  }

  @override
  Future<bool> isHealthConnectAvailable() async {
    try {
      return await _health.isHealthConnectAvailable();
    } catch (e) {
      throw HealthDataSourceException(
        message: 'Failed to check Health Connect availability',
        code: 'health_connect_check_failed',
        originalError: e,
      );
    }
  }

  @override
  Future<void> revokePermissions() async {
    try {
      await _health.revokePermissions();
    } catch (e) {
      throw HealthDataSourceException(
        message: 'Failed to revoke health permissions',
        code: 'revoke_permissions_failed',
        originalError: e,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Aggregate step counts from data points
  int _aggregateSteps(List<HealthDataPoint> dataPoints) {
    if (dataPoints.isEmpty) return 0;

    // Remove duplicates (health plugin may return overlapping data)
    final uniquePoints = _health.removeDuplicates(dataPoints);

    // Sum all step values
    return uniquePoints.fold<int>(0, (sum, point) {
      final value = point.value;
      if (value is NumericHealthValue) {
        return sum + value.numericValue.toInt();
      }
      return sum;
    });
  }

  /// Check if any data point was manually entered
  bool _hasManualEntries(List<HealthDataPoint> dataPoints) {
    return dataPoints.any((point) => point.recordingMethod == RecordingMethod.manual);
  }
}
