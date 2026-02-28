import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/features/duel/domain/domain.dart';

/// Duel List State
sealed class DuelListState extends UiState with EffectClearable<DuelListState> {
  const DuelListState({super.effect});

  @override
  DuelListState clearEffect() => _copyWithEffect(null);

  @override
  DuelListState withEffect(UiEffect? effect) => _copyWithEffect(effect);

  DuelListState _copyWithEffect(UiEffect? effect);
}

class DuelListInitial extends DuelListState {
  const DuelListInitial({super.effect});

  @override
  List<Object?> get props => [];

  @override
  DuelListState _copyWithEffect(UiEffect? effect) =>
      DuelListInitial(effect: effect);
}

class DuelListLoading extends DuelListState {
  const DuelListLoading({super.effect});

  @override
  List<Object?> get props => [];

  @override
  DuelListState _copyWithEffect(UiEffect? effect) =>
      DuelListLoading(effect: effect);
}

class DuelListLoaded extends DuelListState {
  final List<Duel> activeDuels;
  final List<Duel> pendingDuels;
  final List<Duel> historyDuels;

  const DuelListLoaded({
    required this.activeDuels,
    required this.pendingDuels,
    required this.historyDuels,
    super.effect,
  });

  @override
  List<Object?> get props => [activeDuels, pendingDuels, historyDuels];

  @override
  DuelListState _copyWithEffect(UiEffect? effect) => DuelListLoaded(
        activeDuels: activeDuels,
        pendingDuels: pendingDuels,
        historyDuels: historyDuels,
        effect: effect,
      );

  DuelListLoaded copyWith({
    List<Duel>? activeDuels,
    List<Duel>? pendingDuels,
    List<Duel>? historyDuels,
    UiEffect? effect,
  }) {
    return DuelListLoaded(
      activeDuels: activeDuels ?? this.activeDuels,
      pendingDuels: pendingDuels ?? this.pendingDuels,
      historyDuels: historyDuels ?? this.historyDuels,
      effect: effect,
    );
  }
}

class DuelListError extends DuelListState {
  final String message;

  const DuelListError(this.message, {super.effect});

  @override
  List<Object?> get props => [message];

  @override
  DuelListState _copyWithEffect(UiEffect? effect) =>
      DuelListError(message, effect: effect);
}
