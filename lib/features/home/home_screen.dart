import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/progress_ring.dart';
import '../../data/models/course.dart';
import '../../data/models/lesson.dart';
import '../../data/models/user_progress.dart';
import '../lessons/lesson_engine.dart';

/// The home screen answers one question: "What should I do today?"
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final progress = ref.watch(progressProvider);
    final courseAsync = ref.watch(courseLevelProvider(progress.level));

    final now = DateTime.now();
    final today = UserProgress.dayKey(now);
    final minutesToday = progress.minutesByDay[today] ?? 0;
    final goal = settings.dailyGoalMinutes;
    final goalReached = progress.dailyGoalCompletedOn == today;
    final streak = progress.streak(now);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screen,
          children: [
            // Greeting.
            Text(
              settings.name.isEmpty
                  ? 'Bonjour ! 👋'
                  : 'Bonjour, ${settings.name} 👋',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "Ready for today's French?",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Progress overview card.
            courseAsync.when(
              data: (course) {
                final totalLessons = course.lessonCount;
                final done = course.units
                    .expand((u) => u.lessons)
                    .where((l) => progress.isLessonComplete(l.id))
                    .length;
                final pct = totalLessons == 0 ? 0.0 : done / totalLessons;
                return AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${progress.level.code} · ${progress.level.label}',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 10,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              '$done of $totalLessons lessons · '
                              '${(pct * 100).round()}%',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                const Text(
                                  '🔥',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  streak == 0
                                      ? 'Start your streak today!'
                                      : '$streak day streak',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: AppColors.streakFlame,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ProgressRing(
                        progress: goal == 0 ? 0 : minutesToday / goal,
                        size: 84,
                        color: AppColors.success,
                        child: goalReached
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.success,
                                  ),
                                  Text(
                                    'Goal done',
                                    style: theme.textTheme.labelSmall,
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$minutesToday',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                  Text(
                                    '/ $goal min',
                                    style: theme.textTheme.labelSmall,
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const AppCard(
                child: SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Continue learning.
            Text('Continue learning', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            courseAsync.when(
              data: (course) {
                final lessons = course.units.expand((u) => u.lessons).toList();
                final nextLesson = lessons
                    .where((l) => !progress.isLessonComplete(l.id))
                    .firstOrNull;
                if (nextLesson == null) {
                  return AppCard(
                    child: Column(
                      children: [
                        const Text('🎉', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'You finished every available lesson — magnifique !',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Review your words to keep them fresh.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }
                return _ContinueCard(lesson: nextLesson, progress: progress);
              },
              loading: () => const SizedBox(height: 90),
              error: (_, _) => AppCard(
                child: Text(
                  "We couldn't load the course. Please restart the app.",
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            courseAsync.maybeWhen(
              data: (course) => _UnlockLessonCard(course: course, progress: progress),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Daily challenge.
            _DailyChallengeCard(progress: progress),
            const SizedBox(height: AppSpacing.lg),

            // Today's practice shortcuts.
            Text("Today's practice", style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _PracticeShortcut(
                    emoji: '🔁',
                    label: 'Review words',
                    onTap: () => context.go('/practice/review'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _PracticeShortcut(
                    emoji: '📒',
                    label: 'My mistakes',
                    onTap: () => context.go('/practice/mistakes'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _PracticeShortcut(
                    emoji: '🗂️',
                    label: 'Vocabulary',
                    onTap: () => context.go('/practice/vocabulary'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _PracticeShortcut(
                    emoji: '🏆',
                    label: 'Achievements',
                    onTap: () => context.go('/progress/achievements'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueCard extends ConsumerWidget {
  const _ContinueCard({required this.lesson, required this.progress});

  final Lesson lesson;
  final UserProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Count against the same effective section list the player uses
    // (authored sections + attached catalog video).
    final catalog = ref.watch(videoCatalogProvider).valueOrNull ?? const [];
    final sectionsDone = progress.sectionsDone(lesson.id).length;
    final totalSections = effectiveSections(lesson, catalog).length;
    return AppCard(
      onTap: () => context.push('/lesson/${lesson.id}'),
      color: theme.colorScheme.primaryContainer,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unit ${lesson.unit} · Lesson',
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(lesson.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  sectionsDone > 0
                      ? '$sectionsDone of $totalSections steps done — keep going!'
                      : '${lesson.estimatedMinutes} min · ${lesson.description}',
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _DailyChallengeCard extends ConsumerWidget {
  const _DailyChallengeCard({required this.progress});

  final UserProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final today = UserProgress.dayKey(DateTime.now());
    final done = progress.dailyChallengeCompletedOn == today;
    final xpToday = progress.xpByDay[today] ?? 0;
    const target = ProgressNotifier.dailyChallengeXpTarget;

    return AppCard(
      child: Row(
        children: [
          Text(done ? '✅' : '⚡', style: const TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's challenge", style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  done
                      ? 'Done! +100 XP bonus earned. À demain !'
                      : 'Earn $target XP today · $xpToday / $target',
                  style: theme.textTheme.bodySmall,
                ),
                if (!done) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (xpToday / target).clamp(0.0, 1.0),
                      minHeight: 6,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!done) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              '+100 XP',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Offers to unlock the learner's next locked lesson by watching a
/// rewarded ad. Renders nothing once nothing is locked.
class _UnlockLessonCard extends ConsumerWidget {
  const _UnlockLessonCard({required this.course, required this.progress});

  final CourseLevel course;
  final UserProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = nextLockedLesson(progress, {
      for (final unit in course.units) unit.id: unit.lessons,
    });
    if (locked == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return AppCard(
      child: Row(
        children: [
          const Text('🔓', style: TextStyle(fontSize: 26)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Unlock next lesson', style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  'Watch a short ad to unlock "${locked.title}" early.',
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: () {
              if (!ref.read(adsEnabledProvider)) return;
              ref
                  .read(adsServiceProvider)
                  .rewarded
                  .show(
                    onEarnedReward: () => ref
                        .read(progressProvider.notifier)
                        .unlockLessonWithAd(locked.id),
                    onUnavailable: () {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Ad not ready yet — try again in a moment.',
                          ),
                        ),
                      );
                    },
                  );
            },
            child: const Text('Watch ad'),
          ),
        ],
      ),
    );
  }
}

class _PracticeShortcut extends StatelessWidget {
  const _PracticeShortcut({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
