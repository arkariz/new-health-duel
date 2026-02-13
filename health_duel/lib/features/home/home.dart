/// Home Feature
///
/// This feature handles the main home screen including:
/// - User profile display
/// - Sign out functionality
/// - Pull-to-refresh
///
/// Architecture: Clean Architecture with Pattern A (Separate Renderable State)
/// - Domain: Use cases from auth feature (reused)
/// - Presentation: HomeBloc, HomePage
library;

// ========================
// Presentation Layer
// ========================

// Bloc
export 'presentation/bloc/home_bloc.dart';
export 'presentation/bloc/home_event.dart';
export 'presentation/bloc/home_state.dart';

// Pages
export 'presentation/pages/home_page.dart';
