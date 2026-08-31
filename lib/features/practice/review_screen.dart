import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/constants/app_constants.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/audio_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/vocab_item.dart';

/// Spaced-repetition flashcard review of due (or weak) words.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, this.weakOnly = false});

  final bool weakOnly;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  List<VocabItem>? _queue;
  int _index = 0;
  bool _revealed = false;
  int _gotIt = 0;

  void _buildQueue() {
    final srs = ref.read(srsProvider).valueOrNull ?? {};
    final vocab = ref.read(vocabularyIndexProvider).valueOrNull ?? {};
    final now = DateTime.now();
    final entries =
        srs.values
            .where((e) => widget.weakOnly ? e.isWeak : e.isDue(now))
            .toList()
          ..sort((a, b) => a.box.compareTo(b.box));
    _queue = [
      for (final entry in entries.take(20))
        if (vocab[entry.wordId] != null) vocab[entry.wordId]!,
    ];
  }

  Future<void> _assess(bool correct) async {
    final word = _queue![_index];
    await ref.read(srsProvider.notifier).reviewWord(word.id, correct: correct);
    await ref.read(progressProvider.notifier).addXp(AppConstants.xpReviewWord);
    await ref.read(progressProvider.notifier).recordSkill('vocabulary');
    if (correct) _gotIt++;
    if (!mounted) return;
    setState(() {
      _index++;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final srsReady = ref.watch(srsProvider).hasValue;
    final vocabReady = ref.watch(vocabularyIndexProvider).hasValue;
    if (!srsReady || !vocabReady) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_queue == null) _buildQueue();
    final queue = _queue!;

    if (queue.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.weakOnly ? 'Weak words' : 'Review')),
        body: EmptyState(
          emoji: widget.weakOnly ? '💪' : '🌿',
          title: widget.weakOnly ? 'No weak words !' : 'All caught up !',
          message: widget.weakOnly
              ? "You're holding your own everywhere. Keep learning new "
                    'lessons to grow your vocabulary.'
              : 'No words are due right now. Complete lessons to meet new '
                    'words, then come back later.',
        ),
      );
    }

    if (_index >= queue.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review complete')),
        body: EmptyState(
          emoji: '🎉',
          title: 'Bien joué !',
          message:
              'You reviewed ${queue.length} words and remembered '
              '$_gotIt of them. Each review earned '
              '+${AppConstants.xpReviewWord} XP.',
          actionLabel: 'Done',
          onAction: () => Navigator.of(context).pop(),
        ),
      );
    }

    final word = queue[_index];
    return Scaffold(
      appBar: AppBar(title: Text(widget.weakOnly ? 'Weak words' : 'Review')),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screen,
          child: Column(
            children: [
              Text(
                '${_index + 1} of ${queue.length}',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _revealed = !_revealed),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: AppRadius.large,
                      boxShadow: AppShadows.card(theme.brightness),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          word.displayFrench,
                          style: AppTypography.frenchDisplay.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AudioButton(text: word.french, size: 30),
                        const SizedBox(height: AppSpacing.lg),
                        _revealed
                            ? Column(
                                children: [
                                  Text(
                                    word.english,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          color: theme.colorScheme.primary,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (word.example != null) ...[
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      word.example!,
                                      style: theme.textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              )
                            : Text(
                                'Do you remember this word ?\nTap to check.',
                                style: theme.textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _revealed ? () => _assess(false) : null,
                      child: const Text('Forgot it'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                      onPressed: _revealed ? () => _assess(true) : null,
                      child: const Text('Got it !'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
