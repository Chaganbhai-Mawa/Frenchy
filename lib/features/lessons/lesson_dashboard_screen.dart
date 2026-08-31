import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/progress_ring.dart';
import 'lesson_engine.dart';

/// The lesson's front door: shows the complete learning journey (every
/// section with its state) before the learner dives in.
class LessonDashboardScreen extends ConsumerWidget {
  const LessonDashboardScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lessonAsync = ref.watch(lessonProvider(lessonId));
    final catalog = ref.watch(videoCatalogProvider).valueOrNull ?? const [];
    final progress = ref.watch(progressProvider);

    return lessonAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          emoji: '😕',
          title: 'Lesson unavailable',
          message: "We couldn't load this lesson. Please try again.",
        ),
      ),
      data: (lesson) {
        if (lesson == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              emoji: '🔍',
              title: 'Lesson not found',
              message: 'This lesson does not exist yet.',
            ),
          );
        }
        final sections = effectiveSections(lesson, catalog);
        final done = progress.sectionsDone(lesson.id);
        final requiredIndexes = [
          for (final (i, s) in sections.indexed)
            if (s.required) i,
        ];
        final requiredDone = requiredIndexes.where(done.contains).length;
        final pct = requiredIndexes.isEmpty
            ? 0.0
            : requiredDone / requiredIndexes.length;
        final isComplete = progress.isLessonComplete(lesson.id);
        // Resume at the first unfinished section.
        final resumeIndex = () {
          for (final (i, _) in sections.indexed) {
            if (!done.contains(i)) return i;
          }
          return 0;
        }();

        final isSaved = ref
            .watch(settingsProvider.select((s) => s.favoriteLessons))
            .contains(lesson.id);

        return Scaffold(
          appBar: AppBar(
            title: Text('${lesson.level} · Unit ${lesson.unit}'),
            actions: [
              IconButton(
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isSaved ? AppColors.gold : null,
                ),
                tooltip: isSaved ? 'Remove from saved' : 'Save this lesson',
                onPressed: () => ref
                    .read(settingsProvider.notifier)
                    .toggleFavoriteLesson(lesson.id),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: AppSpacing.screen,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lesson.title,
                                  style: theme.textTheme.displayMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  lesson.description,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          ProgressRing(
                            progress: pct,
                            size: 64,
                            strokeWidth: 7,
                            color: isComplete
                                ? AppColors.success
                                : theme.colorScheme.primary,
                            child: Text(
                              isComplete ? '✓' : '${(pct * 100).round()}%',
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '⏱️ About ${lesson.estimatedMinutes} minutes',
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text("Today's lesson", style: theme.textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      for (final (index, section) in sections.indexed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AppCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            onTap: () => context.push(
                              '/lesson/${lesson.id}/play/$index',
                            ),
                            child: Row(
                              children: [
                                Text(
                                  section.type.emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        section.title,
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      if (!section.required)
                                        Text(
                                          'Optional',
                                          style: theme.textTheme.labelSmall,
                                        ),
                                    ],
                                  ),
                                ),
                                if (done.contains(index))
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.success,
                                  )
                                else if (index == resumeIndex)
                                  Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: theme.colorScheme.primary,
                                  )
                                else
                                  Icon(
                                    Icons.circle_outlined,
                                    color: theme.colorScheme.outline,
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: AppSpacing.screen,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.push(
                        '/lesson/${lesson.id}/play/$resumeIndex',
                      ),
                      child: Text(
                        isComplete
                            ? 'Practice again'
                            : done.isEmpty
                            ? 'Start lesson'
                            : 'Continue lesson',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
