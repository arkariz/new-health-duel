/// Widget that listens to effects and dispatches to registry
///
/// Usage: `EffectListener<YourBloc, YourState>(child: YourScreen())`
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/bloc/base/state/ui_state.dart';
import 'package:health_duel/core/bloc/effect/effect_registry.dart';

/// Listens to state changes and dispatches effects to handlers
class EffectListener<B extends BlocBase<S>, S extends UiState> extends StatelessWidget {
  final Widget child;
  final EffectRegistry? registry;

  const EffectListener({
    required this.child,
    this.registry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<B, S>(
      listenWhen: (prev, curr) => curr.hasEffect && prev.effect != curr.effect,
      listener: (context, state) {
        final effect = state.effect;
        if (effect == null) return;

        (registry ?? globalEffectRegistry).handle(context, effect);
      },
      child: child,
    );
  }
}
