/// Effect-based BLoC architecture
///
/// Setup: Call `setupEffectHandlers()` in main.dart
/// Usage: Wrap screens with `EffectListener<YourBloc, YourState>`
library;

export 'base/effect_bloc.dart';
export 'base/state/ui_state.dart';

export 'base/effect/autodismiss/autodismiss_effect.dart';
export 'base/effect/interactive/interactive_effect.dart';
export 'base/effect/ui_effect.dart';

export 'effect/dialog/config/dialog_action_config.dart';
export 'effect/dialog/dialog_effect.dart';

export 'effect/snackbar/snackbar_effect.dart';
export 'base/effect/autodismiss/feedback_effect.dart';

export 'base/effect/navigation/navigation_effect.dart';
export 'effect/navigation/navigate_go_effect.dart';
export 'effect/navigation/navigate_pop_effect.dart';
export 'effect/navigation/navigate_push_effect.dart';
export 'effect/navigation/navigate_replace_effect.dart';

export 'effect/effect_handlers.dart';
export 'effect/effect_registry.dart';

export 'observer/app_bloc_observer.dart';
