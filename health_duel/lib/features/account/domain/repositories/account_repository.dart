import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';

/// Account Repository (Domain Layer)
///
/// Defines contracts for permanent account deletion — the hard Play
/// Store requirement covered by M2.4 in the MVP launch plan.
abstract class AccountRepository {
  /// Whether deleting the account will require a password to
  /// re-authenticate first.
  ///
  /// True for email/password accounts. False for Google accounts, where
  /// re-authentication (if Firebase asks for it) happens via a native
  /// Google sign-in prompt instead — no typed input needed.
  Future<Either<Failure, bool>> requiresPasswordReauth();

  /// Permanently delete the current user's account and all of their data.
  ///
  /// Pass [password] when [requiresPasswordReauth] returned true; Firebase
  /// requires a recent sign-in for this operation, and this is the only
  /// way to obtain one for a password-based account.
  ///
  /// Deletes, in order (see ACCOUNT_DATA_SOURCE for exactly what each step
  /// touches): the user's own display fields on any duel they took part
  /// in are anonymized (not deleted — the other participant's history
  /// stays intact), their friends list and `users/{uid}` doc are deleted,
  /// their Health Connect permission grant is revoked, then their Firebase
  /// Auth account itself is deleted.
  ///
  /// Possible failures:
  /// - [AuthFailure]: re-authentication failed (wrong password, cancelled
  ///   Google prompt, or session too stale and no credential supplied)
  Future<Either<Failure, void>> deleteAccount({String? password});
}
