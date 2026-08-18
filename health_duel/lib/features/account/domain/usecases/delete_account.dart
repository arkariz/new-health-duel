import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/account/domain/repositories/account_repository.dart';

/// Permanently delete the current user's account and all of their data.
///
/// See [AccountRepository.deleteAccount] for exactly what this removes.
class DeleteAccount {

  const DeleteAccount(this._repository);
  final AccountRepository _repository;

  Future<Either<Failure, void>> call({String? password}) {
    return _repository.deleteAccount(password: password);
  }
}
