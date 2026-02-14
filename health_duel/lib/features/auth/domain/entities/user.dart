/// Auth Credentials Re-export
///
/// Re-exports the global [AuthCredentials] entity for auth feature usage.
/// This ensures consistency and avoids duplication.
///
/// AuthCredentials validates authentication inputs (email, password, name)
/// before sending to backend. This is a write-side validation model.
///
/// For authenticated user data (read-side), use [UserModel] instead.
///
/// The global AuthCredentials entity is defined in:
/// lib/data/session/domain/entities/auth_credentials.dart
library;

export 'package:health_duel/data/session/domain/entities/auth_credentials.dart';
