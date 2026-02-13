import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/health/domain/entities/entities.dart';

/// Raw step data record (domain boundary type).
///
/// Keeps domain pure without data layer imports.
/// Use case converts to [StepCount] entity with validation.
typedef StepDataRaw = ({int value, DateTime startTime, DateTime endTime, String? sourceDevice, bool hasManualEntries});

/// Health data operations contract.
///
/// Returns Either<Failure, T> for error handling (ADR-002).
/// No caching - always fresh data (ADR-001).
/// Returns raw data for use case to create entities (ADR-006).
abstract class HealthRepository {
  /// Check permission status without prompting user.
  Future<Either<Failure, HealthPermissionStatus>> checkPermissions();

  /// Request step data access permission.
  Future<Either<Failure, bool>> requestPermissions();

  /// Get raw step data for time range (use case creates entity).
  Future<Either<Failure, StepDataRaw>> getStepCount({required DateTime startTime, required DateTime endTime});

  /// Get today's raw step data (midnight to now).
  Future<Either<Failure, StepDataRaw>> getTodaySteps();

  /// Check if Health Connect is installed (Android) or HealthKit available (iOS).
  Future<Either<Failure, bool>> isHealthConnectAvailable();

  /// Revoke health permissions.
  Future<Either<Failure, void>> revokePermissions();
}
