import 'package:health_duel/features/challenge/challenge.dart';

/// Solo Challenge Status Value Object
///
/// A solo challenge has no acceptance step (unlike a duel) — it starts
/// the moment the user sets a target, runs for 24h, then completes.
enum ChallengeStatus {
  /// 24-hour window in progress.
  active,

  /// 24-hour window ended — target met or not, see [SoloChallenge.metTarget].
  completed;

  bool get isFinal => this == ChallengeStatus.completed;
}
