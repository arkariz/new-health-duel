import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/session.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';

/// Sign In With Email Use Case
///
/// Business logic for email/password authentication.
/// Validates inputs and delegates to repository.
class SignInWithEmail {
  final AuthRepository repository;

  const SignInWithEmail(this.repository);

  /// Execute sign in with email and password
  ///
  /// Returns [User] on success or [Failure] on error.
  ///
  /// Validation is performed by User entity value objects (Email, DisplayName).
  /// This use case catches [ArgumentError] and converts to [ValidationFailure].
  ///
  /// Possible failures:
  /// - [ValidationFailure]: Invalid email format, empty/short password (from domain validation)
  /// - [NetworkFailure]: No internet connection
  /// - [ServerFailure]: Firebase error
  Future<Either<Failure, UserModel>> call({
    required String email,
    required String password,
  }) async {
    try {
      // Create user entity - validation happens here via value objects
      // Throws ArgumentError if validation fails
      final user = User.login(email: email, password: password);

      // Delegate to repository with validated values
      final result = await repository.signInWithEmail(
        email: user.email.value, // Extract string from Email value object
        password: user.password.value, // Extract string from Password value object
      );
      return result;
    } on ArgumentError catch (e) {
      // Convert domain validation exception to Failure
      return Left(ValidationFailure(message: e.message));
    }
  }
}
