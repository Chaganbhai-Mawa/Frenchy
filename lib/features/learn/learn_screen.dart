import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/progress_ring.dart';
import '../../data/models/cefr_level.dart';

void _openUnit(BuildContext context, WidgetRef ref, String unitId) {
  // Every unit entry is a natural break point — attempt an interstitial,
  // then navigate whether or not one was ready to show.
  if (!ref.read(adsEnabledProvider)) {
    context.go('/learn/unit/$unitId');
    return;
  }
  ref
      .read(adsServiceProvider)
      .interstitial
      .show(onComplete: () => context.go('/learn/unit/$unitId'));
}

/// The French Journey: CEFR levels with their topic units. Tapping a level
/// tile browses that level; the learner's current level is highlighted.
class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  CefrLevel? _browsing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = ref.watch(progressProvider);
    final selected = _browsing ?? progress.level;
    final courseAsync = ref.watch(courseLevelProvider(selected));

    return Scaffold(
      appBar: AppBar(title: const Text('French Journey')),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          // Level track.
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: CefrLevel.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, i) {
                final level = CefrLevel.values[i];
                final isSelected = level == selected;
                final isCurrent = level == progress.level;
                return GestureDetector(
                  onTap: () => setState(() => _browsing = level),
                  child: Container(
                    width: 96,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.levelColor(level.code)
                          : theme.colorScheme.surface,
                      borderRadius: AppRadius.medium,
                      border: isCurrent && !isSelected
                          ? Border.all(
                              color: AppColors.levelColor(level.code),
                              width: 2,
                            )
                          : null,
                      boxShadow: AppShadows.card(theme.brightness),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          level.code,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          level.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? Colors.white70
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          courseAsync.when(
            data: (course) {
              if (course.units.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xl),
                  child: Column(
                    children: [
                      const Text('🚧', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '${course.level.code} content is on its way!',
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  for (final unit in course.units)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _UnitCard(
                        unitId: unit.id,
                        icon: unit.icon,
                        title: 'Unit ${unit.unit} · ${unit.title}',
                        subtitle: unit.subtitle,
                        lessonCount: unit.lessons.length,
                        completedCount: unit.lessons
                            .where((l) => progress.isLessonComplete(l.id))
                            .length,
                        onTap: () => _openUnit(context, ref, unit.id),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xl),
              child: Text(
                "We couldn't load the course content. Please restart the app.",
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({
    required this.unitId,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.lessonCount,
    required this.completedCount,
    required this.onTap,
  });

  final String unitId;
  final String icon;
  final String title;
  final String subtitle;
  final int lessonCount;
  final int completedCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = lessonCount > 0 && completedCount == lessonCount;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          done
              ? const Text('🏅', style: TextStyle(fontSize: 26))
              : ProgressRing(
                  progress: lessonCount == 0 ? 0 : completedCount / lessonCount,
                  size: 44,
                  strokeWidth: 5,
                  child: Text(
                    '$completedCount/$lessonCount',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
        ],
      ),
    );
  }
}
