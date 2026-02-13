import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/health/domain/repositories/repositories.dart';

/// Check Health Connect Availability Use Case
///
/// Checks if Health Connect app is installed on Android.
/// On iOS, HealthKit is always available (built-in).
class CheckHealthConnectAvailable {
  // TODO: Refactor - Thin Use Case (see TECHNICAL_DEBT.md)
  final HealthRepository _repository;

  const CheckHealthConnectAvailable(this._repository);

  /// Execute the use case
  ///
  /// Returns true if Health Connect is installed (Android) or always true (iOS).
  Future<Either<Failure, bool>> call() {
    return _repository.isHealthConnectAvailable();
  }
}
