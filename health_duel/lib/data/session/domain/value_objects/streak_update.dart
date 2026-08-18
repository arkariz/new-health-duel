/// Streak transition math (pure, no I/O).
///
/// Rule (see MVP plan §M3 Streak): hitting a challenge target extends the
/// streak by one *only* if the last completion was yesterday; any bigger
/// gap starts a fresh streak at 1. Missing a day is not swept by a
/// server-side job — there are no Cloud Functions — so it's applied
/// explicitly when a challenge completes without meeting its target, and
/// otherwise shown as zero lazily at display time via
/// [effectiveCurrentStreak] rather than written eagerly.
abstract final class StreakUpdate {
  /// Next `(currentStreak, longestStreak, lastCompletedDate)` after hitting
  /// a target on [completedAtLocal]'s calendar date.
  static ({int currentStreak, int longestStreak, String lastCompletedDate})
      applySuccess({
    required int currentStreak,
    required int longestStreak,
    required String? lastCompletedDate,
    required DateTime completedAtLocal,
  }) {
    final today = dateKey(completedAtLocal);

    if (lastCompletedDate == today) {
      // Already recorded today (e.g. a duplicate completion event) — no
      // double count.
      return (
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastCompletedDate: today,
      );
    }

    final yesterday = dateKey(completedAtLocal.subtract(const Duration(days: 1)));
    final next = lastCompletedDate == yesterday ? currentStreak + 1 : 1;

    return (
      currentStreak: next,
      longestStreak: next > longestStreak ? next : longestStreak,
      lastCompletedDate: today,
    );
  }

  /// The streak value to actually show the user: zero once more than a
  /// day has passed since [lastCompletedDate], even if the stored value
  /// hasn't been reset yet.
  static int effectiveCurrentStreak({
    required int currentStreak,
    required String? lastCompletedDate,
    required DateTime nowLocal,
  }) {
    if (lastCompletedDate == null) return 0;
    final today = dateKey(nowLocal);
    final yesterday = dateKey(nowLocal.subtract(const Duration(days: 1)));
    if (lastCompletedDate == today || lastCompletedDate == yesterday) {
      return currentStreak;
    }
    return 0;
  }

  /// Local calendar date as `yyyy-MM-dd` — deliberately not a UTC
  /// timestamp, so the day boundary follows the user's own clock.
  static String dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
