import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';

/// Session Repository Interface (Global Domain Layer)
///
/// Defines contracts for session management operations.
/// These operations are shared across the entire application.
///
/// Auth feature implements this interface via its data sources.
/// Other features depend on this interface for user session access.
///
/// All methods return Either<Failure, T> for functional error handling (ADR-002).
abstract class SessionRepository {
  /// Get current authenticated user
  ///
  /// Returns [UserModel] if session is valid, null if unauthenticated.
  /// Entity creation happens in use case layer.
  Future<Either<Failure, UserModel?>> getCurrentUser();

  /// Sign out current user
  ///
  /// Clears Firebase Auth session and local cache.
  Future<Either<Failure, void>> signOut();

  /// Stream of authentication state changes
  ///
  /// Emits [UserModel] on sign in, null on sign out.
  /// Useful for reactive UI updates across the app.
  Stream<UserModel?> authStateChanges();
}
