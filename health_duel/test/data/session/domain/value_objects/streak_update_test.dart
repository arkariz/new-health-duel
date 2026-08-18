import 'package:flutter_test/flutter_test.dart';
import 'package:health_duel/data/session/domain/value_objects/streak_update.dart';

void main() {
  group('StreakUpdate.applySuccess', () {
    test('first-ever completion starts the streak at 1', () {
      final result = StreakUpdate.applySuccess(
        currentStreak: 0,
        longestStreak: 0,
        lastCompletedDate: null,
        completedAtLocal: DateTime(2026, 8, 18),
      );

      expect(result.currentStreak, 1);
      expect(result.longestStreak, 1);
      expect(result.lastCompletedDate, '2026-08-18');
    });

    test('completing on the day after the last completion extends the streak', () {
      final result = StreakUpdate.applySuccess(
        currentStreak: 4,
        longestStreak: 4,
        lastCompletedDate: '2026-08-17',
        completedAtLocal: DateTime(2026, 8, 18),
      );

      expect(result.currentStreak, 5);
      expect(result.longestStreak, 5);
      expect(result.lastCompletedDate, '2026-08-18');
    });

    test('a gap of more than a day resets the streak to 1, not 0', () {
      final result = StreakUpdate.applySuccess(
        currentStreak: 10,
        longestStreak: 12,
        lastCompletedDate: '2026-08-10',
        completedAtLocal: DateTime(2026, 8, 18),
      );

      expect(result.currentStreak, 1);
      // Longest streak is a running max — a reset never lowers it.
      expect(result.longestStreak, 12);
      expect(result.lastCompletedDate, '2026-08-18');
    });

    test('completing twice on the same calendar date does not double-count', () {
      final result = StreakUpdate.applySuccess(
        currentStreak: 3,
        longestStreak: 3,
        lastCompletedDate: '2026-08-18',
        completedAtLocal: DateTime(2026, 8, 18, 23, 59),
      );

      expect(result.currentStreak, 3);
      expect(result.longestStreak, 3);
    });

    test('a new streak that surpasses the old longest updates longestStreak', () {
      final result = StreakUpdate.applySuccess(
        currentStreak: 6,
        longestStreak: 6,
        lastCompletedDate: '2026-08-17',
        completedAtLocal: DateTime(2026, 8, 18),
      );

      expect(result.currentStreak, 7);
      expect(result.longestStreak, 7);
    });
  });

  group('StreakUpdate.effectiveCurrentStreak', () {
    test('null lastCompletedDate displays as 0', () {
      expect(
        StreakUpdate.effectiveCurrentStreak(
          currentStreak: 5,
          lastCompletedDate: null,
          nowLocal: DateTime(2026, 8, 18),
        ),
        0,
      );
    });

    test('last completion today shows the stored streak', () {
      expect(
        StreakUpdate.effectiveCurrentStreak(
          currentStreak: 5,
          lastCompletedDate: '2026-08-18',
          nowLocal: DateTime(2026, 8, 18, 20),
        ),
        5,
      );
    });

    test('last completion yesterday still shows the stored streak', () {
      expect(
        StreakUpdate.effectiveCurrentStreak(
          currentStreak: 5,
          lastCompletedDate: '2026-08-17',
          nowLocal: DateTime(2026, 8, 18, 8),
        ),
        5,
      );
    });

    test('a gap of two or more days displays as 0 even though nothing was written', () {
      expect(
        StreakUpdate.effectiveCurrentStreak(
          currentStreak: 5,
          lastCompletedDate: '2026-08-15',
          nowLocal: DateTime(2026, 8, 18),
        ),
        0,
      );
    });
  });

  group('StreakUpdate.dateKey', () {
    test('pads single-digit month and day', () {
      expect(StreakUpdate.dateKey(DateTime(2026, 3, 5)), '2026-03-05');
    });
  });
}
