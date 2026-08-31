import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/utils/answer_checker.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/audio_button.dart';
import '../../core/widgets/empty_state.dart';

/// Vocabulary browser: offline search, category filter, favorites, and SRS
/// state per word.
class VocabularyScreen extends ConsumerStatefulWidget {
  const VocabularyScreen({super.key});

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  String _query = '';
  String? _category;
  bool _favoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabAsync = ref.watch(vocabularyIndexProvider);
    final srs = ref.watch(srsProvider).valueOrNull ?? {};
    final favorites = ref.watch(
      settingsProvider.select((s) => s.favoriteWords),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Vocabulary')),
      body: vocabAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const EmptyState(
          emoji: '😕',
          title: 'Vocabulary unavailable',
          message: "We couldn't load the word list. Please try again.",
        ),
        data: (index) {
          final all = index.values.toList()
            ..sort((a, b) => a.french.compareTo(b.french));
          final categories = all.map((v) => v.category).toSet()..remove('');
          final normalizedQuery = AnswerChecker.stripAccents(
            AnswerChecker.normalize(_query),
          );

          final filtered = all.where((word) {
            if (_favoritesOnly && !favorites.contains(word.id)) return false;
            if (_category != null && word.category != _category) return false;
            if (normalizedQuery.isEmpty) return true;
            bool matches(String text) => AnswerChecker.stripAccents(
              AnswerChecker.normalize(text),
            ).contains(normalizedQuery);
            return matches(word.french) || matches(word.english);
          }).toList();

          if (all.isEmpty) {
            return const EmptyState(
              emoji: '📚',
              title: 'Your vocabulary list is empty',
              message:
                  'Complete your first lesson to start building your French '
                  'word collection.',
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  0,
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    hintText: 'Search French or English…',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  children: [
                    FilterChip(
                      label: const Text('⭐ Saved'),
                      selected: _favoritesOnly,
                      onSelected: (v) => setState(() => _favoritesOnly = v),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    for (final category in categories) ...[
                      FilterChip(
                        label: Text(category),
                        selected: _category == category,
                        onSelected: (v) =>
                            setState(() => _category = v ? category : null),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyState(
                        emoji: '🔍',
                        title: 'No words found',
                        message: _favoritesOnly
                            ? 'You have no saved words matching this search. '
                                  'Tap the bookmark on any word card to save it.'
                            : 'Try a different search or category.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.md,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final word = filtered[i];
                          final entry = srs[word.id];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: AppCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          word.displayFrench,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Text(
                                          word.english,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        if (entry != null)
                                          Text(
                                            entry.isLearned
                                                ? '✓ learned'
                                                : entry.isWeak
                                                ? '💪 needs practice'
                                                : '🌱 learning',
                                            style: theme.textTheme.labelSmall,
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      favorites.contains(word.id)
                                          ? Icons.bookmark_rounded
                                          : Icons.bookmark_border_rounded,
                                      color: favorites.contains(word.id)
                                          ? AppColors.gold
                                          : null,
                                    ),
                                    onPressed: () => ref
                                        .read(settingsProvider.notifier)
                                        .toggleFavoriteWord(word.id),
                                  ),
                                  AudioButton(text: word.french, size: 22),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
