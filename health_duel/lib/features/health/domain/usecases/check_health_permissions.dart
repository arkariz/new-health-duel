import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/health/domain/entities/entities.dart';
import 'package:health_duel/features/health/domain/repositories/repositories.dart';

/// Check Health Permissions Use Case
///
/// Checks the current permission status without prompting user.
/// Use this to determine which UI to show (permission prompt vs step counter).
class CheckHealthPermissions {
  // TODO: Refactor - Thin Use Case (see TECHNICAL_DEBT.md)
  final HealthRepository _repository;

  const CheckHealthPermissions(this._repository);

  /// Execute the use case
  ///
  /// Returns current permission status.
  Future<Either<Failure, HealthPermissionStatus>> call() {
    return _repository.checkPermissions();
  }
}
