import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frenchly/app/constants/app_constants.dart';
import 'package:frenchly/app/providers.dart';
import 'package:frenchly/core/services/key_value_store.dart';
import 'package:frenchly/data/models/app_settings.dart';

ProviderContainer buildContainer({int goalMinutes = 10}) {
  final container = ProviderContainer(
    overrides: [
      keyValueStoreProvider.overrideWithValue(MemoryStore()),
      initialSettingsProvider.overrideWithValue(
        AppSettings(dailyGoalMinutes: goalMinutes, onboardingComplete: true),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  final now = DateTime(2026, 8, 10, 9);

  group('daily goal bonus', () {
    test('is not awarded before the goal is reached', () async {
      final container = buildContainer();
      await container.read(progressProvider.notifier).addMinutes(6, now: now);

      final progress = container.read(progressProvider);
      expect(progress.minutesByDay['2026-08-10'], 6);
      expect(progress.dailyGoalCompletedOn, isNull);
      expect(progress.xp, 0);
    });

    test('is awarded once when the goal is reached', () async {
      final container = buildContainer();
      final notifier = container.read(progressProvider.notifier);

      await notifier.addMinutes(6, now: now);
      await notifier.addMinutes(5, now: now);

      var progress = container.read(progressProvider);
      expect(progress.dailyGoalCompletedOn, '2026-08-10');
      expect(progress.xp, AppConstants.xpDailyGoal);

      // Studying more the same day must not pay the bonus again.
      await notifier.addMinutes(20, now: now);
      progress = container.read(progressProvider);
      expect(progress.minutesByDay['2026-08-10'], 31);
      expect(progress.xp, AppConstants.xpDailyGoal);
    });

    test('is awarded again on a new day', () async {
      final container = buildContainer();
      final notifier = container.read(progressProvider.notifier);

      await notifier.addMinutes(10, now: now);
      await notifier.addMinutes(10, now: DateTime(2026, 8, 11, 9));

      final progress = container.read(progressProvider);
      expect(progress.dailyGoalCompletedOn, '2026-08-11');
      expect(progress.xp, AppConstants.xpDailyGoal * 2);
    });

    test('survives a save/load round trip', () async {
      final container = buildContainer();
      await container.read(progressProvider.notifier).addMinutes(10, now: now);

      final saved = container.read(progressProvider).toJson();
      expect(saved['dailyGoalCompletedOn'], '2026-08-10');
    });
  });
}
