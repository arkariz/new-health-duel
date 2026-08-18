import 'package:health_duel/core/bloc/bloc.dart';
import 'package:health_duel/features/challenge/domain/entities/solo_challenge.dart';

sealed class ChallengeState extends UiState with EffectClearable<ChallengeState> {
  const ChallengeState({super.effect});

  @override
  ChallengeState clearEffect() => _copyWithEffect(null);

  @override
  ChallengeState withEffect(UiEffect? effect) => _copyWithEffect(effect);

  ChallengeState _copyWithEffect(UiEffect? effect);
}

class ChallengeInitial extends ChallengeState {
  const ChallengeInitial({super.effect});

  @override
  ChallengeState copyWith({UiEffect? effect}) => _copyWithEffect(effect);

  @override
  List<Object?> get props => [];

  @override
  ChallengeState _copyWithEffect(UiEffect? effect) => ChallengeInitial(effect: effect);
}

class ChallengeLoading extends ChallengeState {
  const ChallengeLoading({super.effect});

  @override
  ChallengeState copyWith({UiEffect? effect}) => _copyWithEffect(effect);

  @override
  List<Object?> get props => [];

  @override
  ChallengeState _copyWithEffect(UiEffect? effect) => ChallengeLoading(effect: effect);
}

/// [challenge] is `null` when the user has no active challenge — the UI
/// renders the "set a target" form in that case, or the live progress
/// view otherwise.
class ChallengeLoaded extends ChallengeState {
  const ChallengeLoaded({
    required this.currentTime,
    this.challenge,
    this.lastSyncTime,
    this.isStarting = false,
    super.effect,
  });

  final SoloChallenge? challenge;
  final DateTime currentTime;
  final DateTime? lastSyncTime;
  final bool isStarting;

  @override
  List<Object?> get props => [challenge, currentTime, lastSyncTime, isStarting];

  @override
  ChallengeState _copyWithEffect(UiEffect? effect) => ChallengeLoaded(
        challenge: challenge,
        currentTime: currentTime,
        lastSyncTime: lastSyncTime,
        isStarting: isStarting,
        effect: effect,
      );

  @override
  ChallengeLoaded copyWith({
    SoloChallenge? challenge,
    bool clearChallenge = false,
    DateTime? currentTime,
    DateTime? lastSyncTime,
    bool? isStarting,
    UiEffect? effect,
  }) {
    return ChallengeLoaded(
      challenge: clearChallenge ? null : (challenge ?? this.challenge),
      currentTime: currentTime ?? this.currentTime,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isStarting: isStarting ?? this.isStarting,
      effect: effect,
    );
  }
}

class ChallengeError extends ChallengeState {
  const ChallengeError(this.message, {super.effect});
  final String message;

  @override
  ChallengeState copyWith({UiEffect? effect}) => _copyWithEffect(effect);

  @override
  List<Object?> get props => [message];

  @override
  ChallengeState _copyWithEffect(UiEffect? effect) => ChallengeError(message, effect: effect);
}
