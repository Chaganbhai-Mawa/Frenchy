import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/achievement.dart';
import '../../data/models/user_progress.dart';

/// Progress dashboard: XP, streak calendar, skills, achievements preview.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = ref.watch(progressProvider);
    final srs = ref.watch(srsProvider).valueOrNull ?? {};
    final now = DateTime.now();
    final streak = progress.streak(now);
    final learnedWords = srs.values.where((e) => e.isLearned).length;
    final unlockedCount = progress.unlockedAchievements.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          // Headline stats.
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  emoji: '⚡',
                  value: '${progress.xp}',
                  label: 'Total XP',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatCard(
                  emoji: '🔥',
                  value: '$streak',
                  label: streak == 1 ? 'Day streak' : 'Day streak',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  emoji: '📚',
                  value: '$learnedWords',
                  label: 'Words learned',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatCard(
                  emoji: '🎓',
                  value: '${progress.completedLessons.length}',
                  label: 'Lessons done',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Streak calendar (current month).
          Text('This month', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: _MonthCalendar(progress: progress, now: now),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Skills.
          Text('Skills', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              children: [
                _SkillRow(
                  emoji: '🎧',
                  label: 'Listening',
                  count: progress.skillCounts['listening'] ?? 0,
                ),
                _SkillRow(
                  emoji: '🎤',
                  label: 'Speaking',
                  count: progress.skillCounts['speaking'] ?? 0,
                ),
                _SkillRow(
                  emoji: '📖',
                  label: 'Reading',
                  count: progress.skillCounts['reading'] ?? 0,
                ),
                _SkillRow(
                  emoji: '✍️',
                  label: 'Writing',
                  count: progress.skillCounts['writing'] ?? 0,
                ),
                _SkillRow(
                  emoji: '🏆',
                  label: 'Quiz questions',
                  count: progress.skillCounts['quiz'] ?? 0,
                ),
                _SkillRow(
                  emoji: '🗂️',
                  label: 'Vocabulary reviews',
                  count: progress.skillCounts['vocabulary'] ?? 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Achievements preview.
          AppCard(
            onTap: () => context.go('/progress/achievements'),
            child: Row(
              children: [
                const Text('🏅', style: TextStyle(fontSize: 28)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Achievements', style: theme.textTheme.titleMedium),
                      Text(
                        '$unlockedCount of ${AchievementCatalog.all.length} unlocked',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
  });

  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: theme.textTheme.headlineMedium),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Simple month grid with active days highlighted — friendly, not punitive.
class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({required this.progress, required this.now});

  final UserProgress progress;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final active = progress.activeDays.toSet();

    return Column(
      children: [
        Text(
          '${_monthName(now.month)} ${now.year}',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var day = 1; day <= daysInMonth; day++)
              Builder(
                builder: (context) {
                  final key = UserProgress.dayKey(
                    DateTime(now.year, now.month, day),
                  );
                  final isActive = active.contains(key);
                  final isToday = day == now.day;
                  return Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.streakFlame
                          : theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isActive
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }

  static String _monthName(int month) => const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month - 1];
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.emoji,
    required this.label,
    required this.count,
  });

  final String emoji;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text('$count', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
