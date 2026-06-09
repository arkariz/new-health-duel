import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';
import 'package:health_duel/features/duel/domain/domain.dart';

/// Create Duel State
sealed class CreateDuelState extends UiState
    with EffectClearable<CreateDuelState> {
  const CreateDuelState({super.effect});

  @override
  CreateDuelState clearEffect() => _copyWithEffect(null);

  @override
  CreateDuelState withEffect(UiEffect? effect) => _copyWithEffect(effect);

  CreateDuelState _copyWithEffect(UiEffect? effect);
}

/// Initial state — opponents not yet loaded
class CreateDuelInitial extends CreateDuelState {
  const CreateDuelInitial({super.effect});

  @override
  List<Object?> get props => [];

  @override
  CreateDuelState copyWith({UiEffect? effect}) => _copyWithEffect(effect);

  @override
  CreateDuelState _copyWithEffect(UiEffect? effect) =>
      CreateDuelInitial(effect: effect);
}

/// Loading opponents from Firestore
class CreateDuelLoadingOpponents extends CreateDuelState {
  const CreateDuelLoadingOpponents({super.effect});

  @override
  List<Object?> get props => [];

  @override
  CreateDuelState copyWith({UiEffect? effect}) => _copyWithEffect(effect);

  @override
  CreateDuelState _copyWithEffect(UiEffect? effect) =>
      CreateDuelLoadingOpponents(effect: effect);
}

/// Opponents loaded — form is ready
class CreateDuelReady extends CreateDuelState {

  const CreateDuelReady({required this.opponents, super.effect});
  final List<UserModel> opponents;

  @override
  List<Object?> get props => [opponents];

  @override
  CreateDuelState _copyWithEffect(UiEffect? effect) =>
      CreateDuelReady(opponents: opponents, effect: effect);

  @override
  CreateDuelReady copyWith({List<UserModel>? opponents, UiEffect? effect}) =>
      CreateDuelReady(opponents: opponents ?? this.opponents, effect: effect);
}

/// Submitting duel to Firestore
class CreateDuelSubmitting extends CreateDuelState {

  const CreateDuelSubmitting({required this.opponents, super.effect});
  final List<UserModel> opponents;

  @override
  List<Object?> get props => [opponents];

  @override
  CreateDuelState copyWith({UiEffect? effect}) => _copyWithEffect(effect);

  @override
  CreateDuelState _copyWithEffect(UiEffect? effect) =>
      CreateDuelSubmitting(opponents: opponents, effect: effect);
}

/// Duel created successfully
class CreateDuelSuccess extends CreateDuelState {

  const CreateDuelSuccess(this.duel, {super.effect});
  final Duel duel;

  @override
  List<Object?> get props => [duel];

  @override
  CreateDuelState copyWith({UiEffect? effect}) => _copyWithEffect(effect);

  @override
  CreateDuelState _copyWithEffect(UiEffect? effect) =>
      CreateDuelSuccess(duel, effect: effect);
}

/// Failed to load opponents or create duel
class CreateDuelFailure extends CreateDuelState {

  const CreateDuelFailure(this.message, {super.effect});
  final String message;

  @override
  List<Object?> get props => [message];

  @override
  CreateDuelState copyWith({UiEffect? effect}) => _copyWithEffect(effect);

  @override
  CreateDuelState _copyWithEffect(UiEffect? effect) =>
      CreateDuelFailure(message, effect: effect);
}
