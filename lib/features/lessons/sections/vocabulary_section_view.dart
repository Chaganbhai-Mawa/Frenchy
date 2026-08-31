import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/audio_button.dart';
import '../../../data/models/vocab_item.dart';

/// Interactive vocabulary cards: French side first, tap to reveal meaning,
/// self-assess ("Still learning" / "Got it") which feeds the spaced-
/// repetition schedule.
class VocabularySectionView extends ConsumerStatefulWidget {
  const VocabularySectionView({
    super.key,
    required this.items,
    required this.onDone,
  });

  final List<VocabItem> items;
  final VoidCallback onDone;

  @override
  ConsumerState<VocabularySectionView> createState() =>
      _VocabularySectionViewState();
}

class _VocabularySectionViewState extends ConsumerState<VocabularySectionView> {
  int _index = 0;
  bool _revealed = false;

  VocabItem get _current => widget.items[_index];

  Future<void> _assess(bool gotIt) async {
    await ref
        .read(srsProvider.notifier)
        .reviewWord(_current.id, correct: gotIt);
    await ref.read(progressProvider.notifier).recordSkill('vocabulary');
    if (!mounted) return;
    if (_index + 1 >= widget.items.length) {
      widget.onDone();
    } else {
      setState(() {
        _index++;
        _revealed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onDone());
      return const SizedBox.shrink();
    }
    final settings = ref.watch(settingsProvider);
    final isFavorite = settings.favoriteWords.contains(_current.id);

    return Padding(
      padding: AppSpacing.screen,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Word ${_index + 1} of ${widget.items.length}',
                style: theme.textTheme.labelMedium,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  isFavorite
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isFavorite ? AppColors.gold : null,
                ),
                tooltip: 'Save word',
                onPressed: () => ref
                    .read(settingsProvider.notifier)
                    .toggleFavoriteWord(_current.id),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _revealed = !_revealed),
              child: AnimatedContainer(
                duration: AppAnimations.normal,
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
                      _current.displayFrench,
                      style: AppTypography.frenchDisplay.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_current.pronunciation != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '[ ${_current.pronunciation} ]',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AudioButton(text: _current.french, size: 32),
                    const SizedBox(height: AppSpacing.lg),
                    AnimatedCrossFade(
                      duration: AppAnimations.normal,
                      crossFadeState: _revealed
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Text(
                        'Tap the card to reveal the meaning',
                        style: theme.textTheme.bodySmall,
                      ),
                      secondChild: Column(
                        children: [
                          Text(
                            _current.english,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_current.partOfSpeech.isNotEmpty)
                            Text(
                              _current.gender != null
                                  ? '${_current.partOfSpeech} · '
                                        '${_current.gender == 'f' ? 'feminine' : 'masculine'}'
                                  : _current.partOfSpeech,
                              style: theme.textTheme.labelMedium,
                            ),
                          if (_current.example != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _current.example!,
                              style: theme.textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            if (_current.exampleEnglish != null)
                              Text(
                                _current.exampleEnglish!,
                                style: theme.textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ],
                      ),
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
                  child: const Text('Still learning'),
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
    );
  }
}
