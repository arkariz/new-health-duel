import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/challenge/domain/entities/solo_challenge.dart';
import 'package:health_duel/features/challenge/domain/repositories/solo_challenge_repository.dart';

class GetActiveSoloChallenge {
  const GetActiveSoloChallenge(this._repository);
  final SoloChallengeRepository _repository;

  Future<Either<Failure, SoloChallenge?>> call(String userId) {
    return _repository.getActiveChallenge(userId);
  }
}
