import 'package:dartz/dartz.dart';
import 'package:health_duel/core/error/failures.dart';
import 'package:health_duel/data/session/domain/repositories/session_repository.dart';
import 'package:health_duel/data/session/domain/value_objects/streak_update.dart';

/// Record Challenge Completion Use Case (Global)
///
/// Applies the streak transition (see [StreakUpdate]) for a solo
/// challenge that just finished. Called by the challenge feature — kept
/// here (not in `features/challenge/`) because streak lives on the
/// global `users/{uid}` doc, not on the challenge itself.
class RecordChallengeCompletion {
  const RecordChallengeCompletion(this._repository);
  final SessionRepository _repository;

  Future<Either<Failure, void>> call({
    required bool metTarget,
    DateTime? completedAt,
  }) async {
    final userResult = await _repository.getCurrentUser();

    return userResult.fold(
      Left.new,
      (user) async {
        if (user == null) {
          return const Left(AuthFailure(message: 'No signed-in user'));
        }

        if (!metTarget) {
          return _repository.updateStreak(
            userId: user.id,
            currentStreak: 0,
            longestStreak: user.longestStreak,
            lastCompletedDate: user.lastCompletedDate,
          );
        }

        final next = StreakUpdate.applySuccess(
          currentStreak: user.currentStreak,
          longestStreak: user.longestStreak,
          lastCompletedDate: user.lastCompletedDate,
          completedAtLocal: completedAt ?? DateTime.now(),
        );

        return _repository.updateStreak(
          userId: user.id,
          currentStreak: next.currentStreak,
          longestStreak: next.longestStreak,
          lastCompletedDate: next.lastCompletedDate,
        );
      },
    );
  }
}
