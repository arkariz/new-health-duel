/// Duel Feature - Presentation Layer
///
/// Export barrel for the entire duel presentation layer.
///
/// Includes:
/// - BLoC (states, events, effects)
/// - Pages (screens)
/// - Widgets (reusable components)
library;

// BLoC — Active Duel
export 'bloc/duel_bloc.dart';
export 'bloc/duel_event.dart';
export 'bloc/duel_state.dart';

// BLoC — Duel List
export 'bloc/duel_list_bloc.dart';
export 'bloc/duel_list_event.dart';
export 'bloc/duel_list_state.dart';

// BLoC — Create Duel
export 'bloc/create_duel_bloc.dart';
export 'bloc/create_duel_event.dart';
export 'bloc/create_duel_state.dart';

// Pages
export 'pages/pages.dart';

// Widgets
export 'widgets/widgets.dart';
