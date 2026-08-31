import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/native_ad_card.dart';
import '../../data/models/cefr_level.dart';
import '../../data/models/lesson.dart';
import '../lessons/lesson_engine.dart';

/// Lessons of one topic unit, with completion state and the unit's videos.
class UnitDetailScreen extends ConsumerWidget {
  const UnitDetailScreen({super.key, required this.unitId});

  final String unitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final level = CefrLevel.fromCode(unitId.split('_').first);
    final courseAsync = ref.watch(courseLevelProvider(level));
    final progress = ref.watch(progressProvider);

    return courseAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          emoji: '😕',
          title: 'Unit unavailable',
          message: "We couldn't load this unit. Please go back and try again.",
        ),
      ),
      data: (course) {
        final unit = course.units.where((u) => u.id == unitId).firstOrNull;
        if (unit == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              emoji: '🔍',
              title: 'Unit not found',
              message: 'This unit does not exist yet.',
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text('Unit ${unit.unit} · ${unit.title}')),
          body: ListView(
            padding: AppSpacing.screen,
            children: [
              Row(
                children: [
                  Text(unit.icon, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      unit.subtitle.isEmpty
                          ? 'Master this topic step by step.'
                          : unit.subtitle,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final (index, lesson) in unit.lessons.indexed) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Builder(
                    builder: (context) {
                      final complete = progress.isLessonComplete(lesson.id);
                      final score = progress.completedLessons[lesson.id];
                      final started = progress
                          .sectionsDone(lesson.id)
                          .isNotEmpty;
                      final locked = isLessonLocked(
                        progress,
                        unit.lessons,
                        index,
                      );
                      return AppCard(
                        onTap: locked
                            ? () => _showLockedLessonSheet(context, ref, lesson)
                            : () => context.push('/lesson/${lesson.id}'),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: complete
                                    ? AppColors.successSoft
                                    : theme.colorScheme.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: complete
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: AppColors.success,
                                      )
                                    : locked
                                    ? Icon(
                                        Icons.lock_rounded,
                                        size: 20,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      )
                                    : Text(
                                        '${index + 1}',
                                        style: theme.textTheme.titleMedium,
                                      ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lesson.title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: locked
                                          ? theme.colorScheme.onSurfaceVariant
                                          : null,
                                    ),
                                  ),
                                  Text(
                                    complete
                                        ? 'Completed · ${score ?? 0}% score'
                                        : locked
                                        ? 'Locked · finish the previous lesson'
                                        : started
                                        ? 'In progress — continue!'
                                        : '${lesson.estimatedMinutes} min · '
                                              '${lesson.description}',
                                    style: theme.textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              locked
                                  ? Icons.play_circle_outline_rounded
                                  : Icons.chevron_right_rounded,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // A sponsored card every few lessons — the Learn tab's
                // highest-traffic list.
                if ((index + 1) % 4 == 0) const NativeAdCard(),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Explains why a lesson is locked and offers a rewarded-interstitial ad
/// to unlock it immediately instead of finishing the previous lesson.
void _showLockedLessonSheet(BuildContext context, WidgetRef ref, Lesson lesson) {
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.lock_rounded, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This lesson is locked',
              style: Theme.of(sheetContext).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Finish the previous lesson, or watch a short ad to unlock '
              '"${lesson.title}" right now.',
              style: Theme.of(sheetContext).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: const Text('Watch ad to unlock'),
              onPressed: () {
                Navigator.of(sheetContext).pop();
                if (!ref.read(adsEnabledProvider)) return;
                ref
                    .read(adsServiceProvider)
                    .rewardedInterstitial
                    .show(
                      onEarnedReward: () async {
                        await ref
                            .read(progressProvider.notifier)
                            .unlockLessonWithAd(lesson.id);
                        if (context.mounted) {
                          context.push('/lesson/${lesson.id}');
                        }
                      },
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
            ),
          ],
        ),
      ),
    ),
  );
}
