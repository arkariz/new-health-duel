/// Base state with effect property
///
/// Usage: `class MyState extends UiState with EffectClearable<MyState>`
///
/// IMPORTANT: This class overrides == and hashCode to include effect
/// for bloc state emission, while subclasses should exclude effect
/// from [props] to prevent unnecessary widget rebuilds.
///
/// This allows:
/// - Bloc to emit state when only effect changes (for side effects)
/// - Widgets to NOT rebuild when only effect changes (props-based)
library;

import 'package:equatable/equatable.dart';
import 'package:health_duel/core/bloc/base/effect/ui_effect.dart';

/// Base state with optional effect
///
/// Override == and hashCode to include effect for bloc emission,
/// while keeping effect out of [props] for optimized rebuilds.
abstract class UiState extends Equatable {
  final UiEffect? effect;

  const UiState({this.effect});

  bool get hasEffect => effect != null;

  /// Override equality to include effect for bloc state comparison.
  /// This ensures bloc emits state when effect changes, even if props are same.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UiState) return false;
    // First compare Equatable props, then compare effect
    return super == other && effect == other.effect;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, effect);
}

/// Mixin for effect manipulation in copyWith
mixin EffectClearable<T extends UiState> on UiState {
  T clearEffect();
  T withEffect(UiEffect? effect);
}
