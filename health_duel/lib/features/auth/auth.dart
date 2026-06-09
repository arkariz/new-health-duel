/// Auth Feature
///
/// This feature handles user authentication including:
/// - Email/password sign in
/// - Google sign in
/// - Apple sign in (iOS)
/// - Sign out
/// - User session management
///
/// Architecture: Clean Architecture
/// - Domain: Entities, Repository interfaces, Use cases
/// - Data: Models, Data sources, Repository implementations
/// - Presentation: Bloc, Pages, Widgets
library;

// Data Sources
export 'data/datasources/auth_remote_data_source.dart';
// NOTE: GetCurrentUser and SignOut are global use cases
// Export from 'package:health_duel/data/domain/domain.dart'

// ========================
// Data Layer
// ========================

// Models
export 'data/models/user_model.dart';
// Repository Implementation
export 'data/repositories/auth_repository_impl.dart';
// ========================
// Dependency Injection
// ========================
export 'di/auth_module.dart';
export 'di/get_auth_usecases.dart';
// ========================
// Domain Layer
// ========================

// Entities
export 'domain/entities/user.dart';
// Repository Interface
export 'domain/repositories/auth_repository.dart';
export 'domain/usecases/register_with_email.dart';
export 'domain/usecases/sign_in_with_apple.dart';
// Use Cases
export 'domain/usecases/sign_in_with_email.dart';
export 'domain/usecases/sign_in_with_google.dart';
// ========================
// Presentation Layer
// ========================

// Bloc
export 'presentation/bloc/auth_bloc.dart';
export 'presentation/bloc/auth_event.dart';
export 'presentation/bloc/auth_state.dart';
// Pages
export 'presentation/pages/login/login.dart';
export 'presentation/pages/register/register.dart';
