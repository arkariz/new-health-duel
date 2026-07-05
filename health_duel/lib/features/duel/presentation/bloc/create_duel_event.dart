import 'package:equatable/equatable.dart';

/// Where the opponent list is sourced from in the Create Duel screen.
///
/// - [friends] — only the user's added friends (curated list)
/// - [all]     — every registered user (challenge someone random)
enum OpponentSource { friends, all }

/// Create Duel Events
sealed class CreateDuelEvent extends Equatable {
  const CreateDuelEvent();

  @override
  List<Object?> get props => [];
}

/// Load potential opponents for the current user from [source]
class CreateDuelOpponentsRequested extends CreateDuelEvent {
  const CreateDuelOpponentsRequested(
    this.currentUserId, {
    this.source = OpponentSource.friends,
  });

  final String currentUserId;
  final OpponentSource source;

  @override
  List<Object?> get props => [currentUserId, source];
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
