import 'package:equatable/equatable.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/duel/domain/domain.dart';

/// Duel Events - User actions and triggers for duel feature
sealed class DuelEvent extends Equatable {
  const DuelEvent();

  @override
  List<Object?> get props => [];
}

/// Load and start watching a specific duel
class DuelLoadRequested extends DuelEvent {

  const DuelLoadRequested(this.duelId);
  final String duelId;

  @override
  List<Object?> get props => [duelId];
}

/// Real-time duel update succeeded
class DuelUpdateSucceeded extends DuelEvent {

  const DuelUpdateSucceeded(this.duel);
  final Duel duel;

  @override
  List<Object?> get props => [duel];
}

/// Real-time duel update failed
class DuelUpdateFailed extends DuelEvent {

  const DuelUpdateFailed(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Periodic health sync triggered (every 5 minutes)
class DuelHealthSyncTriggered extends DuelEvent {

  const DuelHealthSyncTriggered(this.duelId);
  final String duelId;

  @override
  List<Object?> get props => [duelId];
}

/// Countdown timer tick (every 1 second)
class DuelCountdownTick extends DuelEvent {
  const DuelCountdownTick();
}

/// Duel completion detected (24-hour window expired)
class DuelCompletionDetected extends DuelEvent {

  const DuelCompletionDetected(this.duelId);
  final String duelId;

  @override
  List<Object?> get props => [duelId];
}

/// Manual refresh requested by user
class DuelManualRefreshRequested extends DuelEvent {

  const DuelManualRefreshRequested(this.duelId);
  final String duelId;

  @override
  List<Object?> get props => [duelId];
}
