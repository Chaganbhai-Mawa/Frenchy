import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/widgets/app_card.dart';

/// Practice hub / Review Center: due words, weak words, mistakes, vocabulary.
class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final srs = ref.watch(srsProvider).valueOrNull ?? {};
    final mistakes = ref.watch(mistakesProvider).valueOrNull ?? [];
    final savedLessons = ref.watch(
      settingsProvider.select((s) => s.favoriteLessons),
    );

    final now = DateTime.now();
    final due = srs.values.where((e) => e.isDue(now)).length;
    final weak = srs.values.where((e) => e.isWeak).length;
    final learned = srs.values.where((e) => e.isLearned).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Review Center')),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          _ReviewTile(
            emoji: '📆',
            title: 'Due today',
            subtitle: due == 0
                ? 'Nothing due — bien joué !'
                : '$due word${due == 1 ? '' : 's'} ready for review',
            badge: due,
            onTap: () => context.go('/practice/review'),
          ),
          _ReviewTile(
            emoji: '💪',
            title: 'Weak words',
            subtitle: weak == 0
                ? 'No weak words right now'
                : '$weak word${weak == 1 ? '' : 's'} need extra practice',
            badge: weak,
            onTap: () => context.go('/practice/review?mode=weak'),
          ),
          _ReviewTile(
            emoji: '📒',
            title: 'My mistakes',
            subtitle: mistakes.isEmpty
                ? 'Your mistake notebook is empty'
                : '${mistakes.length} mistake${mistakes.length == 1 ? '' : 's'} to review',
            badge: mistakes.length,
            onTap: () => context.go('/practice/mistakes'),
          ),
          _ReviewTile(
            emoji: '🗂️',
            title: 'All vocabulary',
            subtitle: learned == 0
                ? 'Browse and search every word you meet'
                : '$learned words learned so far',
            onTap: () => context.go('/practice/vocabulary'),
          ),
          _ReviewTile(
            emoji: '🔖',
            title: 'Saved lessons',
            subtitle: savedLessons.isEmpty
                ? 'Bookmark a lesson to find it quickly here'
                : '${savedLessons.length} lesson'
                      '${savedLessons.length == 1 ? '' : 's'} saved',
            badge: savedLessons.length,
            onTap: () => context.go('/practice/saved'),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'A few minutes of review each day moves words into your '
            'long-term memory.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge = 0,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (badge > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '$badge',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
