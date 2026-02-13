import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/domain/repositories/session_repository.dart';

/// Sign Out Use Case (Global)
///
/// Business logic for signing out current user.
/// Can be used by any feature that needs to log out user.
class SignOut {
  // TODO: Refactor - Thin Use Case (see TECHNICAL_DEBT.md)
  final SessionRepository repository;

  const SignOut(this.repository);

  /// Execute sign out
  ///
  /// Clears Firebase Auth session and local cache.
  ///
  /// Possible failures:
  /// - [ServerFailure]: Firebase error during sign out
  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}
