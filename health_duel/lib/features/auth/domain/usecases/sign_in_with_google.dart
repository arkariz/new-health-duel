import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/session.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';

/// Sign In With Google Use Case
///
/// Business logic for Google OAuth authentication.
class SignInWithGoogle {
  // TODO: Refactor - Thin Use Case (see TECHNICAL_DEBT.md)
  final AuthRepository repository;

  const SignInWithGoogle(this.repository);

  /// Execute Google sign in flow
  ///
  /// Opens Google sign-in sheet and returns authenticated user.
  ///
  /// Possible failures:
  /// - [NetworkFailure]: No internet connection
  /// - [ServerFailure]: Firebase error
  Future<Either<Failure, UserModel>> call() async {
    // Delegate to repository
    final result = await repository.signInWithGoogle();
    return result;
  }
}
