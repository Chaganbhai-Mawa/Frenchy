import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/utils/answer_checker.dart';
import '../../../core/widgets/audio_button.dart';
import '../../../data/models/exercise.dart';

typedef AnswerCallback =
    void Function(bool correct, String userAnswer, {String? message});

/// Shared scaffold for a single exercise: prompt, optional audio, content.
class ExerciseShell extends StatelessWidget {
  const ExerciseShell({
    super.key,
    required this.exercise,
    required this.child,
    this.hideFrench = false,
  });

  final Exercise exercise;
  final Widget child;

  /// Hide the French text (pure listening exercises).
  final bool hideFrench;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: AppSpacing.screen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (exercise.prompt.isNotEmpty)
            Text(exercise.prompt, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          if (exercise.usesAudio && exercise.french != null)
            Row(
              children: [
                AudioButton(text: exercise.french!, size: 32),
                const SizedBox(width: AppSpacing.sm),
                AudioButton(text: exercise.french!, slow: true, size: 24),
                if (!hideFrench) ...[
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      exercise.french!,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ],
              ],
            )
          else if (exercise.french != null &&
              exercise.type != ExerciseType.speak)
            Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.french!,
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                AudioButton(text: exercise.french!),
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

/// Multiple choice / listen-and-choose / true-false.
class ChoiceExerciseView extends StatefulWidget {
  const ChoiceExerciseView({
    super.key,
    required this.exercise,
    required this.locked,
    required this.onAnswered,
  });

  final Exercise exercise;
  final bool locked;
  final AnswerCallback onAnswered;

  @override
  State<ChoiceExerciseView> createState() => _ChoiceExerciseViewState();
}

class _ChoiceExerciseViewState extends State<ChoiceExerciseView> {
  String? _selected;

  List<String> get _options => widget.exercise.options.isNotEmpty
      ? widget.exercise.options
      : const ['True', 'False'];

  @override
  Widget build(BuildContext context) {
    return ExerciseShell(
      exercise: widget.exercise,
      hideFrench: widget.exercise.type == ExerciseType.listenChoose,
      child: Column(
        children: [
          for (final option in _options)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _OptionTile(
                label: option,
                state: _tileState(option),
                onTap: widget.locked
                    ? null
                    : () {
                        setState(() => _selected = option);
                        widget.onAnswered(
                          option == widget.exercise.answer,
                          option,
                        );
                      },
              ),
            ),
        ],
      ),
    );
  }

  _OptionState _tileState(String option) {
    if (!widget.locked) {
      return _selected == option ? _OptionState.selected : _OptionState.idle;
    }
    if (option == widget.exercise.answer) return _OptionState.correct;
    if (option == _selected) return _OptionState.wrong;
    return _OptionState.idle;
  }
}

enum _OptionState { idle, selected, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.state, this.onTap});

  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (background, border, foreground) = switch (state) {
      _OptionState.correct => (
        theme.brightness == Brightness.light
            ? AppColors.successSoft
            : const Color(0xFF1E3A2A),
        AppColors.success,
        AppColors.success,
      ),
      _OptionState.wrong => (
        theme.brightness == Brightness.light
            ? const Color(0xFFFDECEC)
            : const Color(0xFF3E2626),
        AppColors.error,
        AppColors.error,
      ),
      _OptionState.selected => (
        theme.colorScheme.primaryContainer,
        theme.colorScheme.primary,
        theme.colorScheme.onSurface,
      ),
      _OptionState.idle => (
        theme.colorScheme.surface,
        theme.colorScheme.outline,
        theme.colorScheme.onSurface,
      ),
    };
    return AnimatedContainer(
      duration: AppAnimations.fast,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.medium,
        border: Border.all(color: border, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.medium,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: foreground,
                    ),
                  ),
                ),
                if (state == _OptionState.correct)
                  const Icon(Icons.check_rounded, color: AppColors.success),
                if (state == _OptionState.wrong)
                  const Icon(Icons.close_rounded, color: AppColors.error),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Typed answers: listen-and-type, dictation, fill-blank, translation.
class TypingExerciseView extends StatefulWidget {
  const TypingExerciseView({
    super.key,
    required this.exercise,
    required this.locked,
    required this.onAnswered,
    this.showTranslations = true,
  });

  final Exercise exercise;
  final bool locked;
  final AnswerCallback onAnswered;
  final bool showTranslations;

  @override
  State<TypingExerciseView> createState() => _TypingExerciseViewState();
}

class _TypingExerciseViewState extends State<TypingExerciseView> {
  final TextEditingController _controller = TextEditingController();
  bool _showHint = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.locked || _controller.text.trim().isEmpty) return;
    final verdict = AnswerChecker.check(
      _controller.text,
      widget.exercise.answer,
      alsoAccepted: widget.exercise.acceptedAnswers,
    );
    switch (verdict) {
      case AnswerVerdict.correct:
        widget.onAnswered(true, _controller.text);
      case AnswerVerdict.almostAccents:
        widget.onAnswered(
          true,
          _controller.text,
          message: 'Correct ! Just watch the accents ✍️',
        );
      case AnswerVerdict.incorrect:
        widget.onAnswered(false, _controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercise = widget.exercise;
    return ExerciseShell(
      exercise: exercise,
      hideFrench:
          exercise.type == ExerciseType.listenType ||
          exercise.type == ExerciseType.dictation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (exercise.type == ExerciseType.translate &&
              exercise.english != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                '« ${exercise.english} »',
                style: theme.textTheme.headlineSmall,
              ),
            ),
          TextField(
            controller: _controller,
            enabled: !widget.locked,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            style: theme.textTheme.titleLarge,
            decoration: const InputDecoration(
              hintText: 'Type your answer in French…',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Accent helper row — typing French on any keyboard.
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              for (final char in ['é', 'è', 'ê', 'à', 'ç', 'ù', 'ô', 'î'])
                ActionChip(
                  label: Text(char),
                  onPressed: widget.locked
                      ? null
                      : () {
                          final text = _controller.text;
                          final sel = _controller.selection;
                          final offset = sel.isValid ? sel.start : text.length;
                          _controller.text =
                              text.substring(0, offset) +
                              char +
                              text.substring(
                                sel.isValid ? sel.end : text.length,
                              );
                          _controller.selection = TextSelection.collapsed(
                            offset: offset + char.length,
                          );
                        },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              if (exercise.hint != null)
                TextButton.icon(
                  onPressed: widget.locked
                      ? null
                      : () => setState(() => _showHint = true),
                  icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
                  label: const Text('Hint'),
                ),
              const Spacer(),
              FilledButton(
                onPressed: widget.locked ? null : _submit,
                child: const Text('Check'),
              ),
            ],
          ),
          if (_showHint && exercise.hint != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                '💡 ${exercise.hint}',
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

/// Arrange scrambled word chips into a sentence.
class ArrangeExerciseView extends StatefulWidget {
  const ArrangeExerciseView({
    super.key,
    required this.exercise,
    required this.locked,
    required this.onAnswered,
  });

  final Exercise exercise;
  final bool locked;
  final AnswerCallback onAnswered;

  @override
  State<ArrangeExerciseView> createState() => _ArrangeExerciseViewState();
}

class _ArrangeExerciseViewState extends State<ArrangeExerciseView> {
  late List<String> _bank;
  final List<String> _chosen = [];

  @override
  void initState() {
    super.initState();
    _bank = List.of(widget.exercise.words);
  }

  void _submit() {
    final sentence = _chosen.join(' ');
    final correct =
        AnswerChecker.check(sentence, widget.exercise.answer) !=
        AnswerVerdict.incorrect;
    widget.onAnswered(correct, sentence);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExerciseShell(
      exercise: widget.exercise,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.exercise.english != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                '« ${widget.exercise.english} »',
                style: theme.textTheme.titleLarge,
              ),
            ),
          // Answer area.
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppRadius.medium,
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final (i, word) in _chosen.indexed)
                  InputChip(
                    label: Text(word),
                    onPressed: widget.locked
                        ? null
                        : () => setState(() {
                            _chosen.removeAt(i);
                            _bank.add(word);
                          }),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (i, word) in _bank.indexed)
                ActionChip(
                  label: Text(word, style: theme.textTheme.titleMedium),
                  onPressed: widget.locked
                      ? null
                      : () => setState(() {
                          _bank.removeAt(i);
                          _chosen.add(word);
                        }),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: widget.locked || _bank.isNotEmpty ? null : _submit,
              child: const Text('Check'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Match French ↔ English pairs by tapping one from each column.
class MatchExerciseView extends StatefulWidget {
  const MatchExerciseView({
    super.key,
    required this.exercise,
    required this.locked,
    required this.onAnswered,
  });

  final Exercise exercise;
  final bool locked;
  final AnswerCallback onAnswered;

  @override
  State<MatchExerciseView> createState() => _MatchExerciseViewState();
}

class _MatchExerciseViewState extends State<MatchExerciseView> {
  late final List<String> _french;
  late final List<String> _english;
  final Set<String> _matchedFrench = {};
  String? _selectedFrench;
  String? _wrongEnglish;
  int _missCount = 0;

  @override
  void initState() {
    super.initState();
    _french = widget.exercise.pairs.map((p) => p.french).toList();
    _english = widget.exercise.pairs.map((p) => p.english).toList()..shuffle();
  }

  void _tapEnglish(String english) {
    if (_selectedFrench == null) return;
    final pair = widget.exercise.pairs.firstWhere(
      (p) => p.french == _selectedFrench,
    );
    if (pair.english == english) {
      setState(() {
        _matchedFrench.add(_selectedFrench!);
        _selectedFrench = null;
        _wrongEnglish = null;
      });
      if (_matchedFrench.length == widget.exercise.pairs.length) {
        final perfect = _missCount == 0;
        widget.onAnswered(
          perfect,
          'matched with $_missCount mistakes',
          message: perfect
              ? 'Parfait ! Every pair matched. 🎉'
              : 'All matched ! Watch the tricky ones next time.',
        );
      }
    } else {
      setState(() {
        _missCount++;
        _wrongEnglish = english;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExerciseShell(
      exercise: widget.exercise,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                for (final word in _french)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _MatchTile(
                      label: word,
                      matched: _matchedFrench.contains(word),
                      selected: _selectedFrench == word,
                      wrong: false,
                      onTap: widget.locked || _matchedFrench.contains(word)
                          ? null
                          : () => setState(() {
                              _selectedFrench = word;
                              _wrongEnglish = null;
                            }),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              children: [
                for (final word in _english)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Builder(
                      builder: (context) {
                        final matched = widget.exercise.pairs.any(
                          (p) =>
                              p.english == word &&
                              _matchedFrench.contains(p.french),
                        );
                        return _MatchTile(
                          label: word,
                          matched: matched,
                          selected: false,
                          wrong: _wrongEnglish == word,
                          onTap: widget.locked || matched
                              ? null
                              : () => _tapEnglish(word),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({
    required this.label,
    required this.matched,
    required this.selected,
    required this.wrong,
    this.onTap,
  });

  final String label;
  final bool matched;
  final bool selected;
  final bool wrong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = matched
        ? AppColors.success
        : wrong
        ? AppColors.error
        : selected
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;
    return AnimatedOpacity(
      duration: AppAnimations.normal,
      opacity: matched ? 0.45 : 1,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        width: double.infinity,
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: AppRadius.small,
          border: Border.all(color: color, width: selected ? 2 : 1.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.small,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.md,
              ),
              child: Text(
                label,
                style: theme.textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
