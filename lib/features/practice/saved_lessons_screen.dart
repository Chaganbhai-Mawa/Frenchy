import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/lesson.dart';

/// Lessons the learner bookmarked, resolved from their ids across all levels.
class SavedLessonsScreen extends ConsumerWidget {
  const SavedLessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final savedIds = ref.watch(
      settingsProvider.select((s) => s.favoriteLessons),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Saved lessons')),
      body: savedIds.isEmpty
          ? const EmptyState(
              emoji: '🔖',
              title: 'No saved lessons yet',
              message:
                  'Tap the bookmark on any lesson to keep it here for quick '
                  'access.',
            )
          : ListView.builder(
              padding: AppSpacing.screen,
              itemCount: savedIds.length,
              itemBuilder: (context, i) {
                final id = savedIds[i];
                final lessonAsync = ref.watch(lessonProvider(id));
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: lessonAsync.when(
                    loading: () => const AppCard(
                      child: SizedBox(
                        height: 56,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    // A bookmarked lesson can disappear if its content pack is
                    // removed; show it plainly instead of failing.
                    error: (_, _) => _MissingCard(lessonId: id),
                    data: (lesson) => lesson == null
                        ? _MissingCard(lessonId: id)
                        : _SavedCard(lesson: lesson, theme: theme),
                  ),
                );
              },
            ),
    );
  }
}

class _SavedCard extends ConsumerWidget {
  const _SavedCard({required this.lesson, required this.theme});

  final Lesson lesson;
  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complete = ref.watch(
      progressProvider.select((p) => p.isLessonComplete(lesson.id)),
    );
    return AppCard(
      onTap: () => context.push('/lesson/${lesson.id}'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${lesson.level} · Unit ${lesson.unit}',
                  style: theme.textTheme.labelSmall,
                ),
                Text(lesson.title, style: theme.textTheme.titleMedium),
                Text(
                  complete
                      ? 'Completed'
                      : '${lesson.estimatedMinutes} min · ${lesson.description}',
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_rounded, color: AppColors.gold),
            tooltip: 'Remove from saved',
            onPressed: () => ref
                .read(settingsProvider.notifier)
                .toggleFavoriteLesson(lesson.id),
          ),
        ],
      ),
    );
  }
}

class _MissingCard extends ConsumerWidget {
  const _MissingCard({required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              'This lesson is no longer available.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () => ref
                .read(settingsProvider.notifier)
                .toggleFavoriteLesson(lessonId),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
