import 'package:flutter/material.dart';

import '../../../app/theme/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/audio_button.dart';
import '../../../data/models/lesson.dart';

/// Teaching blocks (learn / grammar / pronunciation sections): explanation,
/// tappable example pairs with audio, cultural tips.
class LearnSectionView extends StatelessWidget {
  const LearnSectionView({
    super.key,
    required this.section,
    required this.onDone,
    this.showTranslations = true,
  });

  final LessonSection section;
  final VoidCallback onDone;
  final bool showTranslations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              for (final block in section.blocks) ...[
                if (block.heading.isNotEmpty)
                  Text(block.heading, style: theme.textTheme.headlineSmall),
                if (block.body.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(block.body, style: theme.textTheme.bodyLarge),
                ],
                const SizedBox(height: AppSpacing.md),
                for (final example in block.examples)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  example.french,
                                  style: theme.textTheme.titleLarge,
                                ),
                                if (showTranslations) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    example.english,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                                if (example.note != null)
                                  Text(
                                    example.note!,
                                    style: theme.textTheme.labelSmall,
                                  ),
                              ],
                            ),
                          ),
                          AudioButton(text: example.french),
                        ],
                      ),
                    ),
                  ),
                if (block.tip != null)
                  Container(
                    margin: const EdgeInsets.only(
                      top: AppSpacing.xs,
                      bottom: AppSpacing.md,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: AppRadius.small,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            block.tip!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
        Padding(
          padding: AppSpacing.screen,
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onDone,
              child: const Text('Got it — continue'),
            ),
          ),
        ),
      ],
    );
  }
}
