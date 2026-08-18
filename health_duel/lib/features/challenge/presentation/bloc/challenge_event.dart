import 'package:equatable/equatable.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/challenge/domain/entities/solo_challenge.dart';

sealed class ChallengeEvent extends Equatable {
  const ChallengeEvent();

  @override
  List<Object?> get props => [];
}

/// Load the current user's active challenge (or find there is none).
class ChallengeLoadRequested extends ChallengeEvent {
  const ChallengeLoadRequested();
}

/// Start a new 24h challenge with the given target.
class ChallengeStartRequested extends ChallengeEvent {
  const ChallengeStartRequested(this.target);
  final int target;

  @override
  List<Object?> get props => [target];
}

class ChallengeUpdateSucceeded extends ChallengeEvent {
  const ChallengeUpdateSucceeded(this.challenge);
  final SoloChallenge challenge;

  @override
  List<Object?> get props => [challenge];
}

class ChallengeUpdateFailed extends ChallengeEvent {
  const ChallengeUpdateFailed(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class ChallengeHealthSyncTriggered extends ChallengeEvent {
  const ChallengeHealthSyncTriggered(this.challengeId);
  final String challengeId;

  @override
  List<Object?> get props => [challengeId];
}

class ChallengeCountdownTick extends ChallengeEvent {
  const ChallengeCountdownTick();
}

class ChallengeCompletionDetected extends ChallengeEvent {
  const ChallengeCompletionDetected(this.challengeId);
  final String challengeId;

  @override
  List<Object?> get props => [challengeId];
}

class ChallengeManualRefreshRequested extends ChallengeEvent {
  const ChallengeManualRefreshRequested(this.challengeId);
  final String challengeId;

  @override
  List<Object?> get props => [challengeId];
}
