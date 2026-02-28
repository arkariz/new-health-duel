import 'package:equatable/equatable.dart';

/// Duel List Events
sealed class DuelListEvent extends Equatable {
  const DuelListEvent();

  @override
  List<Object?> get props => [];
}

/// Load all duel lists for the current user
class DuelListLoadRequested extends DuelListEvent {
  final String userId;

  const DuelListLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Accept a pending duel invitation
class DuelAcceptRequested extends DuelListEvent {
  final String duelId;

  const DuelAcceptRequested(this.duelId);

  @override
  List<Object?> get props => [duelId];
}

/// Decline a pending duel invitation
class DuelDeclineRequested extends DuelListEvent {
  final String duelId;

  const DuelDeclineRequested(this.duelId);

  @override
  List<Object?> get props => [duelId];
}
