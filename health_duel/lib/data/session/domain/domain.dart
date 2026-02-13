/// Session Domain Layer Exports
///
/// Provides shared domain contracts for cross-feature usage:
/// - [User] entity for user identity
/// - [SessionRepository] interface for session management
/// - [SignOut] use case
library;

// Entities
export 'entities/user.dart';

// Repositories
export 'repositories/session_repository.dart';

// Use Cases
export 'usecases/sign_out.dart';

// Value Objects
export 'value_objects/value_objects.dart';
