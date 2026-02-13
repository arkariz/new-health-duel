import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/health/domain/repositories/repositories.dart';

/// Request Health Permissions Use Case
///
/// Opens the system permission dialog to request step data access.
/// Should be called when user taps "Grant Permission" button.
class RequestHealthPermissions {
  // TODO: Refactor - Thin Use Case (see TECHNICAL_DEBT.md)
  final HealthRepository _repository;

  const RequestHealthPermissions(this._repository);

  /// Execute the use case
  ///
  /// Returns true if permission was granted, false if denied.
  Future<Either<Failure, bool>> call() {
    return _repository.requestPermissions();
  }
}
