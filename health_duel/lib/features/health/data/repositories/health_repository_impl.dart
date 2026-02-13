import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/health/data/datasources/datasources.dart';
import 'package:health_duel/features/health/domain/entities/entities.dart';
import 'package:health_duel/features/health/domain/repositories/repositories.dart';

/// Health Repository Implementation
///
/// Implements [HealthRepository] interface from domain layer.
/// Maps [HealthDataSourceException] to domain [Failure] types.
///
/// Follows [ADR-002 Exception Isolation Strategy]:
/// - Data source throws HealthDataSourceException
/// - Repository catches and maps to Failure types
/// - Domain layer never sees exceptions
///
/// Follows [ADR-006 DTO to Domain Boundary]:
/// - Data source returns [StepCountRaw] DTO
/// - Repository converts to [StepDataRaw] record for domain
/// - Use case creates [StepCount] entity with business validation
class HealthRepositoryImpl implements HealthRepository {
  final HealthPlatformDataSource _dataSource;

  const HealthRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, HealthPermissionStatus>> checkPermissions() async {
    try {
      final status = await _dataSource.checkPermissions();
      return Right(status);
    } on HealthDataSourceException catch (e) {
      return Left(_mapException(e));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Failed to check health permissions',
          errorCode: 'health_check_failed',
          originalException: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermissions() async {
    try {
      final granted = await _dataSource.requestPermissions();
      return Right(granted);
    } on HealthDataSourceException catch (e) {
      return Left(_mapException(e));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Failed to request health permissions',
          errorCode: 'health_request_failed',
          originalException: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, StepDataRaw>> getStepCount({required DateTime startTime, required DateTime endTime}) async {
    try {
      final raw = await _dataSource.getStepCount(startTime: startTime, endTime: endTime);
      // Convert DTO to domain record type
      return Right((
        value: raw.value,
        startTime: raw.startTime,
        endTime: raw.endTime,
        sourceDevice: raw.sourceDevice,
        hasManualEntries: raw.hasManualEntries,
      ));
    } on HealthDataSourceException catch (e) {
      return Left(_mapException(e));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Failed to fetch step count',
          errorCode: 'health_fetch_failed',
          originalException: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, StepDataRaw>> getTodaySteps() async {
    try {
      final raw = await _dataSource.getTodaySteps();
      // Convert DTO to domain record type
      return Right((
        value: raw.value,
        startTime: raw.startTime,
        endTime: raw.endTime,
        sourceDevice: raw.sourceDevice,
        hasManualEntries: raw.hasManualEntries,
      ));
    } on HealthDataSourceException catch (e) {
      return Left(_mapException(e));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Failed to fetch today steps',
          errorCode: 'health_fetch_today_failed',
          originalException: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isHealthConnectAvailable() async {
    try {
      final available = await _dataSource.isHealthConnectAvailable();
      return Right(available);
    } on HealthDataSourceException catch (e) {
      return Left(_mapException(e));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Failed to check Health Connect availability',
          errorCode: 'health_connect_check_failed',
          originalException: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> revokePermissions() async {
    try {
      await _dataSource.revokePermissions();
      return const Right(null);
    } on HealthDataSourceException catch (e) {
      return Left(_mapException(e));
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Failed to revoke health permissions',
          errorCode: 'health_revoke_failed',
          originalException: e.toString(),
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXCEPTION MAPPING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Map HealthDataSourceException to domain Failure
  Failure _mapException(HealthDataSourceException e) {
    return switch (e.code) {
      // Permission related errors
      'check_permissions_failed' ||
      'request_permissions_failed' ||
      'revoke_permissions_failed' => HealthPermissionFailure(message: e.message, errorCode: e.code),

      // Health Connect/HealthKit availability errors
      'health_connect_check_failed' => HealthUnavailableFailure(message: e.message, errorCode: e.code),

      // Data fetch errors (could be permission or platform issue)
      'fetch_steps_failed' => HealthPermissionFailure(message: e.message, errorCode: e.code),

      // Fallback
      _ => UnexpectedFailure(message: e.message, errorCode: e.code, originalException: e.originalError?.toString()),
    };
  }
}
