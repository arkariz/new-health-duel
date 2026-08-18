import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/challenge/domain/entities/solo_challenge.dart';
import 'package:health_duel/features/challenge/domain/repositories/solo_challenge_repository.dart';

class WatchSoloChallenge {
  const WatchSoloChallenge(this._repository);
  final SoloChallengeRepository _repository;

  Stream<Either<Failure, SoloChallenge>> call({
    required String userId,
    required String challengeId,
  }) {
    return _repository.watchChallenge(userId: userId, challengeId: challengeId);
  }
}
