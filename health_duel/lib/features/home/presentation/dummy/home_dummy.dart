/// Dummy home data — replace with real data sources when available.
/// Steps: from HealthBloc/HealthRepository
/// Duel: from DuelBloc/DuelRepository (active duel)
abstract final class HomeDummy {
  // Step data (replace with: HealthBloc state)
  static const int todaySteps = 6847;
  static const int stepGoal = 10000;
  static const double stepProgress = 68; // todaySteps / stepGoal

  // Active duel data (replace with: DuelBloc active duel)
  static const int mySteps = 6847;
  static const int opponentSteps = 5621;
  static const String opponentName = 'Sarah K.';
  static const String timeRemaining = '14h 23m';
  static const double myBattleProgress = 0.62;
  static const double opponentBattleProgress = 0.51;
}