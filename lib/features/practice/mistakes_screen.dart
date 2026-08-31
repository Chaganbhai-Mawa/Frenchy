import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/constants/app_constants.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';

/// Mistake notebook: every wrong answer saved automatically, cleared by
/// reviewing it ("I understand now").
class MistakesScreen extends ConsumerWidget {
  const MistakesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mistakesAsync = ref.watch(mistakesProvider);
    final mistakes = mistakesAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('My mistakes')),
      body: !mistakesAsync.hasValue
          ? const Center(child: CircularProgressIndicator())
          : mistakes.isEmpty
          ? const EmptyState(
              emoji: '🌟',
              title: 'No mistakes here !',
              message:
                  'Wrong answers from lessons and quizzes are saved here '
                  'automatically so you can review them.',
            )
          : ListView(
              padding: AppSpacing.screen,
              children: [
                Text(
                  'Review each mistake, then mark it as understood '
                  '(+${AppConstants.xpMistakeCleared} XP).',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                for (final mistake in mistakes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mistake.prompt,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (mistake.userAnswer.isNotEmpty)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    mistake.userAnswer,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (mistake.correctAnswer.isNotEmpty)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    mistake.correctAnswer,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: AppSpacing.sm),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
                                await ref
                                    .read(mistakesProvider.notifier)
                                    .resolve(mistake.exerciseId);
                                await ref
                                    .read(progressProvider.notifier)
                                    .addXp(AppConstants.xpMistakeCleared);
                              },
                              child: const Text('I understand now ✓'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
