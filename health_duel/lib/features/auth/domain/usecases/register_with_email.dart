import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/session.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';

/// Register With Email Use Case
///
/// Business logic for creating new user account with email/password.
class RegisterWithEmail {
  final AuthRepository repository;

  const RegisterWithEmail(this.repository);

  /// Execute registration with email, password, and display name
  ///
  /// Creates Firebase Auth account and Firestore user document.
  ///
  /// Validation is performed by User entity value objects (Email, DisplayName).
  /// This use case catches [ArgumentError] and converts to [ValidationFailure].
  ///
  /// Returns [UserModel] on success or [Failure] on error.
  ///
  /// Possible failures:
  /// - [ValidationFailure]: Invalid email, password, or name (from domain validation)
  /// - [ValidationFailure]: Email already in use
  /// - [NetworkFailure]: No internet connection
  /// - [ServerFailure]: Firebase error
  Future<Either<Failure, UserModel>> call({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user entity - validation happens here via value objects
      // Throws ArgumentError if validation fails
      final user = User.register(email: email, password: password, name: name);

      // Delegate to repository with validated values
      final result = await repository.registerWithEmail(
        email: user.email.value, // Extract string from Email value object
        password: user.password.value, // Extract string from Password value object
        name: user.name.value, // Extract string from DisplayName value object
      );

      // Manual entity creation from DTO (ADR-006)
      return result;
    } on ArgumentError catch (e) {
      // Convert domain validation exception to Failure
      return Left(ValidationFailure(message: e.message));
    }
  }
}
