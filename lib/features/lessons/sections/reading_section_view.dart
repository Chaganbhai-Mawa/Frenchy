import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_dimensions.dart';
import '../../../core/utils/answer_checker.dart';
import '../../../core/widgets/audio_button.dart';
import '../../../data/models/lesson.dart';
import '../../../data/models/vocab_item.dart';
import '../widgets/exercise_player.dart';

/// Reading passage: French-first with tap-a-word lookups, hidden translation
/// the learner can reveal, audio, then comprehension questions.
class ReadingSectionView extends ConsumerStatefulWidget {
  const ReadingSectionView({
    super.key,
    required this.section,
    required this.lessonVocabulary,
    required this.onFinished,
    this.showTranslations = true,
  });

  final LessonSection section;
  final List<VocabItem> lessonVocabulary;
  final void Function(List<ExerciseOutcome> outcomes) onFinished;
  final bool showTranslations;

  @override
  ConsumerState<ReadingSectionView> createState() => _ReadingSectionViewState();
}

class _ReadingSectionViewState extends ConsumerState<ReadingSectionView> {
  int _passageIndex = 0;
  bool _showTranslation = false;
  bool _inQuestions = false;
  final List<ExerciseOutcome> _outcomes = [];

  ReadingPassage get _passage => widget.section.passage[_passageIndex];

  void _onPassageQuestionsDone(List<ExerciseOutcome> outcomes) {
    _outcomes.addAll(outcomes);
    if (_passageIndex + 1 < widget.section.passage.length) {
      setState(() {
        _passageIndex++;
        _showTranslation = false;
        _inQuestions = false;
      });
    } else {
      widget.onFinished(List.unmodifiable(_outcomes));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.section.passage.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onFinished(const []),
      );
      return const SizedBox.shrink();
    }
    if (_inQuestions && _passage.questions.isNotEmpty) {
      return ExercisePlayer(
        exercises: _passage.questions,
        showTranslations: widget.showTranslations,
        onFinished: _onPassageQuestionsDone,
      );
    }
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _passage.title,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  AudioButton(text: _passage.french.replaceAll('—', '')),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tap any word to see its meaning',
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: AppRadius.medium,
                  boxShadow: AppShadows.card(theme.brightness),
                ),
                child: _TappableText(
                  text: _passage.french,
                  vocabulary: widget.lessonVocabulary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_passage.english.isNotEmpty)
                _showTranslation
                    ? Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: AppRadius.medium,
                        ),
                        child: Text(
                          _passage.english,
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    : Center(
                        child: TextButton.icon(
                          onPressed: () =>
                              setState(() => _showTranslation = true),
                          icon: const Icon(Icons.translate_rounded, size: 18),
                          label: const Text('Show translation'),
                        ),
                      ),
            ],
          ),
        ),
        Padding(
          padding: AppSpacing.screen,
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (_passage.questions.isEmpty) {
                  _onPassageQuestionsDone(const []);
                } else {
                  setState(() => _inQuestions = true);
                }
              },
              child: Text(
                _passage.questions.isEmpty
                    ? 'Continue'
                    : 'Answer the questions',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Renders the passage with each word tappable for a vocabulary lookup.
class _TappableText extends StatelessWidget {
  const _TappableText({required this.text, required this.vocabulary});

  final String text;
  final List<VocabItem> vocabulary;

  void _lookup(BuildContext context, String rawWord) {
    final cleaned = AnswerChecker.normalize(
      rawWord,
    ).replaceAll(RegExp(r"^(l|d|j|c|n|s|t|qu)'"), '');
    if (cleaned.isEmpty) return;
    VocabItem? match;
    for (final item in vocabulary) {
      final french = AnswerChecker.normalize(item.french);
      if (french == cleaned ||
          french.split(' ').contains(cleaned) ||
          AnswerChecker.stripAccents(french) ==
              AnswerChecker.stripAccents(cleaned)) {
        match = item;
        break;
      }
    }
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    match?.displayFrench ?? rawWord,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                AudioButton(text: match?.french ?? rawWord),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              match != null
                  ? match.english
                  : "This word isn't in this lesson's vocabulary yet — "
                        'listen to it and keep reading !',
              style: theme.textTheme.bodyLarge,
            ),
            if (match?.example != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(match!.example!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyLarge?.copyWith(height: 1.7);
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Wrap(
            children: [
              for (final word in line.split(' '))
                GestureDetector(
                  onTap: () => _lookup(context, word),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(word, style: style),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
