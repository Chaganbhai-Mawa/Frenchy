import 'package:flutter_test/flutter_test.dart';
import 'package:frenchly/data/models/user_progress.dart';

void main() {
  group('UserProgress streak', () {
    test('no activity means no streak', () {
      const progress = UserProgress();
      expect(progress.streak(DateTime(2026, 8, 9)), 0);
    });

    test('consecutive days count including today', () {
      const progress = UserProgress(
        activeDays: ['2026-08-07', '2026-08-08', '2026-08-09'],
      );
      expect(progress.streak(DateTime(2026, 8, 9)), 3);
    });

    test('streak survives when today has no activity yet (grace)', () {
      const progress = UserProgress(activeDays: ['2026-08-07', '2026-08-08']);
      expect(progress.streak(DateTime(2026, 8, 9)), 2);
    });

    test('a missed full day breaks the streak', () {
      const progress = UserProgress(activeDays: ['2026-08-05', '2026-08-06']);
      expect(progress.streak(DateTime(2026, 8, 9)), 0);
    });

    test('gap in history only counts the latest run', () {
      const progress = UserProgress(
        activeDays: ['2026-08-01', '2026-08-02', '2026-08-08', '2026-08-09'],
      );
      expect(progress.streak(DateTime(2026, 8, 9)), 2);
    });
  });

  group('UserProgress persistence', () {
    test('round-trips through JSON', () {
      const progress = UserProgress(
        xp: 250,
        completedLessons: {'a1_u01_l01': 92},
        sectionProgress: {
          'a1_u01_l02': {0, 1, 3},
        },
        activeDays: ['2026-08-09'],
        skillCounts: {'listening': 12},
        unlockedAchievements: {'first_step': '2026-08-09'},
      );
      final restored = UserProgress.fromJson(progress.toJson());
      expect(restored.xp, 250);
      expect(restored.completedLessons['a1_u01_l01'], 92);
      expect(restored.sectionsDone('a1_u01_l02'), {0, 1, 3});
      expect(restored.skillCounts['listening'], 12);
      expect(restored.unlockedAchievements['first_step'], '2026-08-09');
    });

    test('dayKey pads correctly', () {
      expect(UserProgress.dayKey(DateTime(2026, 8, 9)), '2026-08-09');
      expect(UserProgress.dayKey(DateTime(2026, 12, 31)), '2026-12-31');
    });
  });
}
