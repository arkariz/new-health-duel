/// Session Domain Layer Exports
///
/// Provides shared domain contracts for cross-feature usage:
/// - [AuthCredentials] entity for authentication input validation
/// - [SessionRepository] interface for session management
/// - [SignOut] use case
library;

// Entities
export 'entities/auth_credentials.dart';

// Repositories
export 'repositories/session_repository.dart';

// Use Cases
export 'usecases/sign_out.dart';

// Value Objects
export 'value_objects/value_objects.dart';
