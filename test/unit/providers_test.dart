import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frenchly/app/constants/app_constants.dart';
import 'package:frenchly/app/providers.dart';
import 'package:frenchly/core/services/key_value_store.dart';
import 'package:frenchly/data/models/user_progress.dart';

ProviderContainer buildContainer() {
  final container = ProviderContainer(
    overrides: [keyValueStoreProvider.overrideWithValue(MemoryStore())],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('ProgressNotifier XP + daily challenge', () {
    test('addXp accumulates and marks the day active', () async {
      final container = buildContainer();
      final notifier = container.read(progressProvider.notifier);
      final now = DateTime(2026, 8, 9, 10);

      await notifier.addXp(25, now: now);
      final progress = container.read(progressProvider);
      expect(progress.xp, 25);
      expect(progress.activeDays, ['2026-08-09']);
      expect(progress.xpByDay['2026-08-09'], 25);
    });

    test('reaching the daily target awards the challenge bonus once', () async {
      final container = buildContainer();
      final notifier = container.read(progressProvider.notifier);
      final now = DateTime(2026, 8, 9, 10);

      await notifier.addXp(60, now: now);
      expect(
        container.read(progressProvider).dailyChallengeCompletedOn,
        isNull,
      );

      await notifier.addXp(60, now: now);
      var progress = container.read(progressProvider);
      expect(progress.dailyChallengeCompletedOn, '2026-08-09');
      // 120 earned + 100 bonus.
      expect(progress.xp, 120 + AppConstants.xpDailyChallenge);

      // No second bonus the same day.
      await notifier.addXp(50, now: now);
      progress = container.read(progressProvider);
      expect(progress.xp, 170 + AppConstants.xpDailyChallenge);
    });

    test('lesson completion keeps the best score', () async {
      final container = buildContainer();
      final notifier = container.read(progressProvider.notifier);

      await notifier.completeLesson('a1_u01_l01', 80);
      await notifier.completeLesson('a1_u01_l01', 60);
      expect(
        container.read(progressProvider).completedLessons['a1_u01_l01'],
        80,
      );
      await notifier.completeLesson('a1_u01_l01', 95);
      expect(
        container.read(progressProvider).completedLessons['a1_u01_l01'],
        95,
      );
    });

    test('first lesson unlocks the First Step achievement', () async {
      final container = buildContainer();
      final notifier = container.read(progressProvider.notifier);

      final unlocked = await notifier.completeLesson('a1_u01_l01', 100);
      expect(unlocked.map((a) => a.id), contains('first_step'));
      // Already recorded: not returned twice.
      final again = await notifier.completeLesson('a1_u01_l02', 100);
      expect(again.map((a) => a.id), isNot(contains('first_step')));
    });

    test('section progress marks and persists', () async {
      final container = buildContainer();
      final notifier = container.read(progressProvider.notifier);

      await notifier.markSectionDone('a1_u01_l01', 0);
      await notifier.markSectionDone('a1_u01_l01', 2);
      expect(container.read(progressProvider).sectionsDone('a1_u01_l01'), {
        0,
        2,
      });
    });

    test('progress persists through the repository', () async {
      final store = MemoryStore();
      final container = ProviderContainer(
        overrides: [keyValueStoreProvider.overrideWithValue(store)],
      );
      await container.read(progressProvider.notifier).addXp(75);
      container.dispose();

      final container2 = ProviderContainer(
        overrides: [keyValueStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container2.dispose);
      final loaded = await container2
          .read(progressRepositoryProvider)
          .getProgress();
      expect(loaded.xp, 75);
    });
  });

  group('SRS notifier', () {
    test('reviewing a word creates and updates its schedule', () async {
      final container = buildContainer();
      await container.read(srsProvider.future);
      final notifier = container.read(srsProvider.notifier);

      await notifier.reviewWord('bonjour', correct: true);
      var entries = container.read(srsProvider).value!;
      expect(entries['bonjour']!.box, 1);

      await notifier.reviewWord('bonjour', correct: false);
      entries = container.read(srsProvider).value!;
      expect(entries['bonjour']!.box, 0);
      expect(entries['bonjour']!.timesSeen, 2);
    });
  });

  group('Reset', () {
    test('resetAll clears progress', () async {
      final container = buildContainer();
      final notifier = container.read(progressProvider.notifier);
      await notifier.addXp(500);
      await notifier.resetAll();
      expect(container.read(progressProvider).xp, 0);
      expect(
        container.read(progressProvider),
        isA<UserProgress>().having((p) => p.completedLessons, 'lessons', {}),
      );
    });
  });
}
