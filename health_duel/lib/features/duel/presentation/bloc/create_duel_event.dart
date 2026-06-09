import 'package:equatable/equatable.dart';

/// Create Duel Events
sealed class CreateDuelEvent extends Equatable {
  const CreateDuelEvent();

  @override
  List<Object?> get props => [];
}

/// Load potential opponents for the current user
class CreateDuelOpponentsRequested extends CreateDuelEvent {

  const CreateDuelOpponentsRequested(this.currentUserId);
  final String currentUserId;

  @override
  List<Object?> get props => [currentUserId];
}

/// Submit a new duel challenge
class CreateDuelSubmitted extends CreateDuelEvent {

  const CreateDuelSubmitted({
    required this.challengerId,
    required this.challengedId,
    required this.challengedName,
  });
  final String challengerId;
  final String challengedId;
  final String challengedName;

  @override
  List<Object?> get props => [challengerId, challengedId, challengedName];
}
