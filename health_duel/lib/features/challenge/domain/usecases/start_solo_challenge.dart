import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/features/challenge/domain/entities/solo_challenge.dart';
import 'package:health_duel/features/challenge/domain/repositories/solo_challenge_repository.dart';
import 'package:health_duel/features/duel/domain/value_objects/duel_metric.dart';

/// Start Solo Challenge Use Case
///
/// Refuses to start a second challenge while one is already active — a
/// user can only run one 24h window at a time.
class StartSoloChallenge {
  const StartSoloChallenge(this._repository);
  final SoloChallengeRepository _repository;

  Future<Either<Failure, SoloChallenge>> call({
    required String userId,
    required int target,
    DuelMetric metric = DuelMetric.steps,
  }) async {
    final activeResult = await _repository.getActiveChallenge(userId);

    return activeResult.fold(
      Left.new,
      (active) {
        if (active != null && active.isActive) {
          return const Left(
            ValidationFailure(message: 'You already have an active challenge'),
          );
        }
        return _repository.startChallenge(
          userId: userId,
          target: target,
          metric: metric,
        );
      },
    );
  }
}
