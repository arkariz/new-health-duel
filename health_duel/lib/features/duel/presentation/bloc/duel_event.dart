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
  final String duelId;

  const DuelLoadRequested(this.duelId);

  @override
  List<Object?> get props => [duelId];
}

/// Real-time duel update succeeded
class DuelUpdateSucceeded extends DuelEvent {
  final Duel duel;

  const DuelUpdateSucceeded(this.duel);

  @override
  List<Object?> get props => [duel];
}

/// Real-time duel update failed
class DuelUpdateFailed extends DuelEvent {
  final Failure failure;

  const DuelUpdateFailed(this.failure);

  @override
  List<Object?> get props => [failure];
}

/// Periodic health sync triggered (every 5 minutes)
class DuelHealthSyncTriggered extends DuelEvent {
  final String duelId;

  const DuelHealthSyncTriggered(this.duelId);

  @override
  List<Object?> get props => [duelId];
}

/// Countdown timer tick (every 1 second)
class DuelCountdownTick extends DuelEvent {
  const DuelCountdownTick();
}

/// Duel completion detected (24-hour window expired)
class DuelCompletionDetected extends DuelEvent {
  final String duelId;

  const DuelCompletionDetected(this.duelId);

  @override
  List<Object?> get props => [duelId];
}

/// Manual refresh requested by user
class DuelManualRefreshRequested extends DuelEvent {
  final String duelId;

  const DuelManualRefreshRequested(this.duelId);

  @override
  List<Object?> get props => [duelId];
}
