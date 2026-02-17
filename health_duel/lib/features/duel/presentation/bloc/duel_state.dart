import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/features/duel/domain/domain.dart';

/// Duel State - Represents current duel viewing/interaction status
///
/// Extends [UiState] to support one-shot side effects via [EffectClearable].
/// Effects are used for notifications and navigation.
sealed class DuelState extends UiState with EffectClearable<DuelState> {
  const DuelState({super.effect});

  @override
  DuelState clearEffect() => _copyWithEffect(null);

  @override
  DuelState withEffect(UiEffect? effect) => _copyWithEffect(effect);

  /// Internal copyWith for effect - each subclass handles its own data
  DuelState _copyWithEffect(UiEffect? effect);
}

/// Initial state before loading duel
class DuelInitial extends DuelState {
  const DuelInitial({super.effect});

  @override
  List<Object?> get props => [];

  @override
  DuelState _copyWithEffect(UiEffect? effect) => DuelInitial(effect: effect);
}

/// Loading state during async operations
class DuelLoading extends DuelState {
  final String? message;

  const DuelLoading({this.message, super.effect});

  @override
  List<Object?> get props => [message];

  @override
  DuelState _copyWithEffect(UiEffect? effect) => DuelLoading(message: message, effect: effect);
}

/// Duel loaded and being watched in real-time
class DuelLoaded extends DuelState {
  final Duel duel;
  final DateTime lastSyncTime;
  final DateTime currentTime;

  const DuelLoaded({
    required this.duel,
    required this.lastSyncTime,
    required this.currentTime,
    super.effect,
  });

  @override
  List<Object?> get props => [duel, lastSyncTime, currentTime];

  @override
  DuelState _copyWithEffect(UiEffect? effect) => DuelLoaded(
    duel: duel,
    lastSyncTime: lastSyncTime,
    currentTime: currentTime,
    effect: effect,
  );

  /// Copy with new values
  DuelLoaded copyWith({
    Duel? duel,
    DateTime? lastSyncTime,
    DateTime? currentTime,
    UiEffect? effect,
  }) {
    return DuelLoaded(
      duel: duel ?? this.duel,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      currentTime: currentTime ?? this.currentTime,
      effect: effect,
    );
  }
}

/// Error state when duel loading/watching fails
class DuelError extends DuelState {
  final String message;

  const DuelError(this.message, {super.effect});

  @override
  List<Object?> get props => [message];

  @override
  DuelState _copyWithEffect(UiEffect? effect) => DuelError(message, effect: effect);
}
