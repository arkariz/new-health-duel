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

// Widgets
export 'presentation/widgets/states/authenticated_view.dart';
export 'presentation/widgets/states/error_view.dart';
export 'presentation/widgets/states/loading_view.dart';
export 'presentation/widgets/active_duels_section.dart';
export 'presentation/widgets//greeting_header_section.dart';
export 'presentation/widgets//quick_action_card_section.dart';
export 'presentation/widgets/steps_hero_card_section.dart';

export 'presentation/dummy/home_dummy.dart';
