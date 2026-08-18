import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/health/domain/repositories/repositories.dart';

/// Revoke Health Permissions Use Case
///
/// Revokes the app's Health Connect / HealthKit access. Used when the
/// user deletes their account, so no stale permission grant survives it.
class RevokeHealthPermissions {

  const RevokeHealthPermissions(this._repository);
  final HealthRepository _repository;

  Future<Either<Failure, void>> call() {
    return _repository.revokePermissions();
  }
}
