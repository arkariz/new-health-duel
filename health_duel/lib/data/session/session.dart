/// Session Module
///
/// Provides global session management for cross-feature usage.
/// This module handles user authentication state and identity.
///
/// Structure:
/// - domain/ - Entities, repositories, use cases (no external dependencies)
/// - data/ - Data sources, models, repository implementations
/// - di/ - Dependency injection module
library;

// Domain Layer
export 'domain/domain.dart';

// Data Layer
export 'data/data.dart';

// Dependency Injection
export 'di/session_module.dart';
