/// Base Bloc with effect emission
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'effect/ui_effect.dart';
import 'state/ui_state.dart';

/// Bloc that supports one-shot side effects
abstract class EffectBloc<E, S extends UiState> extends Bloc<E, S> {
  EffectBloc(super.initialState);

  /// Emit state with side effect
  void emitWithEffect(Emitter<S> emit, S newState, UiEffect effect) {
    if (newState is EffectClearable) {
      emit((newState as EffectClearable).withEffect(effect) as S);
    } else {
      emit(newState);
    }
  }
}
