import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/session.dart';
import 'package:health_duel/features/auth/domain/repositories/auth_repository.dart';

/// Register With Email Use Case
///
/// Business logic for creating new user account with email/password.
class RegisterWithEmail {

  const RegisterWithEmail(this.repository);
  final AuthRepository repository;

  /// Execute registration with email, password, and display name
  ///
  /// Creates Firebase Auth account and Firestore user document.
  ///
  /// Validation is performed by AuthCredentials value objects (Email, DisplayName).
  /// This use case catches [Exception] and converts to [ValidationFailure].
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
      // Create auth credentials - validation happens here via value objects
      // Throws Exception if validation fails
      final credentials = AuthCredentials.forRegister(
        email: email,
        password: password,
        name: name,
      );

      // Delegate to repository with validated values
      final result = await repository.registerWithEmail(
        email: credentials.email.value, // Extract string from Email value object
        password: credentials.password.value, // Extract string from Password value object
        name: credentials.name.value, // Extract string from DisplayName value object
      );

      // Manual entity creation from DTO (ADR-006)
      return result;
    } on Exception catch (e) {
      // Convert domain validation exception to Failure
      return Left(ValidationFailure(message: e.toString()));
    }
  }
}
