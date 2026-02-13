import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/session.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';

/// Sign In With Apple Use Case
///
/// Business logic for Apple Sign In authentication (iOS only).
class SignInWithApple {
  // TODO: Refactor - Thin Use Case (see TECHNICAL_DEBT.md)
  final AuthRepository repository;

  const SignInWithApple(this.repository);

  /// Execute Apple sign in flow
  ///
  /// Opens Apple sign-in sheet and returns authenticated user.
  /// Only works on iOS 13+ and macOS 10.15+.
  ///
  /// Possible failures:
  /// - [NetworkFailure]: No internet connection
  /// - [ServerFailure]: Firebase error
  Future<Either<Failure, UserModel>> call() async {
    // Delegate to repository
    final result = await repository.signInWithApple();
    return result;
  }
}
