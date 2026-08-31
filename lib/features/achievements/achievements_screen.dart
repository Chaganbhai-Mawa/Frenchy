import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/achievement.dart';

/// Achievement gallery: unlocked badges in color, locked ones dimmed with
/// their goal visible so learners know what to aim for.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: GridView.builder(
        padding: AppSpacing.screen,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.95,
        ),
        itemCount: AchievementCatalog.all.length,
        itemBuilder: (context, i) {
          final achievement = AchievementCatalog.all[i];
          final unlockedOn = progress.unlockedAchievements[achievement.id];
          final unlocked = unlockedOn != null;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1),
            duration: AppAnimations.slow,
            curve: AppAnimations.bounce,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: AppCard(
              color: unlocked
                  ? null
                  : theme.colorScheme.surfaceContainerHighest,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: unlocked ? 1 : 0.35,
                    child: Text(
                      achievement.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    achievement.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: unlocked
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    unlocked ? 'Unlocked $unlockedOn' : achievement.description,
                    style: theme.textTheme.labelSmall,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (unlocked)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.xs),
                      child: Icon(
                        Icons.verified_rounded,
                        color: AppColors.gold,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
