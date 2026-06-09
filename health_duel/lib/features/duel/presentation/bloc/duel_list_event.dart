import 'package:equatable/equatable.dart';

/// Duel List Events
sealed class DuelListEvent extends Equatable {
  const DuelListEvent();

  @override
  List<Object?> get props => [];
}

/// Load all duel lists for the current user
class DuelListLoadRequested extends DuelListEvent {

  const DuelListLoadRequested(this.userId);
  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Accept a pending duel invitation
class DuelAcceptRequested extends DuelListEvent {

  const DuelAcceptRequested(this.duelId);
  final String duelId;

  @override
  List<Object?> get props => [duelId];
}

/// Decline a pending duel invitation
class DuelDeclineRequested extends DuelListEvent {

  const DuelDeclineRequested(this.duelId);
  final String duelId;

  @override
  List<Object?> get props => [duelId];
}
