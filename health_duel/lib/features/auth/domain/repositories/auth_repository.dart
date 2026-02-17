import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';

/// Authentication Repository Interface (Domain Layer)
///
/// Defines contracts for authentication operations.
/// This interface lives in the domain layer and is implemented by the data layer.
///
/// All methods return Either<Failure, T> for functional error handling (ADR-002).
abstract class AuthRepository {
  /// Sign in with email and password
  ///
  /// Returns UserModel (DTO) on success. Entity creation happens in use case.
  Future<Either<Failure, UserModel>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with Google account
  ///
  /// Opens Google sign-in flow and returns UserModel (DTO).
  Future<Either<Failure, UserModel>> signInWithGoogle();

  /// Sign in with Apple account (iOS only)
  ///
  /// Opens Apple sign-in flow and returns UserModel (DTO).
  /// On Android, this will return an UnsupportedFailure.
  Future<Either<Failure, UserModel>> signInWithApple();

  /// Register new user with email and password
  ///
  /// Creates new Firebase Auth account and Firestore user document.
  /// Returns UserModel (DTO). Entity creation happens in use case.
  Future<Either<Failure, UserModel>> registerWithEmail({
    required String email,
    required String password,
    required String name,
  });

  /// Stream of authentication state changes
  ///
  /// Emits UserModel on sign in, null on sign out.
  /// Useful for reactive UI updates.
  Stream<UserModel?> authStateChanges();
}
