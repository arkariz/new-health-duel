import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/account/domain/repositories/account_repository.dart';

/// Whether the current account needs a typed password to re-authenticate
/// before deletion (email/password accounts) or not (Google accounts).
class RequiresPasswordReauth {

  const RequiresPasswordReauth(this._repository);
  final AccountRepository _repository;

  Future<Either<Failure, bool>> call() {
    return _repository.requiresPasswordReauth();
  }
}
