import 'package:health_duel/data/session/data/models/user_model.dart';

/// Session Data Source Interface (Global)
///
/// Defines the contract for session-related operations.
/// These operations are needed across the application.
///
/// Auth feature's [AuthRemoteDataSource] implements this interface.
abstract class SessionDataSource {
  /// Sign out current user
  Future<void> signOut();

  /// Get currently authenticated user (null if not signed in)
  Future<UserModel?> getCurrentUser();

  /// Stream of auth state changes
  Stream<UserModel?> authStateChanges();
}
