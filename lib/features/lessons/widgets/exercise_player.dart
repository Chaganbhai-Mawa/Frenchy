import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../data/models/exercise.dart';
import 'exercise_views.dart';
import 'speak_exercise_view.dart';

/// Result of one answered exercise.
class ExerciseOutcome {
  const ExerciseOutcome({
    required this.exercise,
    required this.correct,
    required this.userAnswer,
  });

  final Exercise exercise;
  final bool correct;
  final String userAnswer;
}

/// Plays a list of exercises one at a time with a progress bar, friendly
/// feedback after each answer, and a completion callback. Reused by
/// listening, writing, quiz, practice, reading questions and review flows.
class ExercisePlayer extends ConsumerStatefulWidget {
  const ExercisePlayer({
    super.key,
    required this.exercises,
    required this.onFinished,
    this.showTranslations = true,
  });

  final List<Exercise> exercises;
  final void Function(List<ExerciseOutcome> outcomes) onFinished;
  final bool showTranslations;

  @override
  ConsumerState<ExercisePlayer> createState() => _ExercisePlayerState();
}

class _ExercisePlayerState extends ConsumerState<ExercisePlayer> {
  int _index = 0;
  final List<ExerciseOutcome> _outcomes = [];
  _Feedback? _feedback;

  Exercise get _current => widget.exercises[_index];

  void _onAnswered(bool correct, String userAnswer, {String? message}) {
    if (_feedback != null) return;
    setState(() {
      _outcomes.add(
        ExerciseOutcome(
          exercise: _current,
          correct: correct,
          userAnswer: userAnswer,
        ),
      );
      _feedback = _Feedback(
        correct: correct,
        message:
            message ?? (correct ? _praise(_outcomes.length) : 'Good attempt !'),
        correctAnswer: _current.type == ExerciseType.match
            ? null
            : _current.answer,
        tip: _current.tip,
      );
    });
  }

  static String _praise(int seed) {
    const praises = ['Excellent ! 🎉', 'Très bien !', 'Parfait ! ✨', 'Bravo !'];
    return praises[seed % praises.length];
  }

  void _next() {
    if (_index + 1 >= widget.exercises.length) {
      widget.onFinished(List.unmodifiable(_outcomes));
      return;
    }
    setState(() {
      _index++;
      _feedback = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.exercises.isEmpty) {
      // Defensive: content should never supply an empty section.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onFinished(const []),
      );
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Progress.
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value:
                        (_index + (_feedback != null ? 1 : 0)) /
                        widget.exercises.length,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${_index + 1}/${widget.exercises.length}',
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: AppAnimations.normal,
            switchInCurve: AppAnimations.curve,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0.15, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(_current.id.isEmpty ? '$_index' : _current.id),
              child: _buildExercise(),
            ),
          ),
        ),
        if (_feedback != null)
          _FeedbackBanner(feedback: _feedback!, onNext: _next),
      ],
    );
  }

  Widget _buildExercise() {
    final locked = _feedback != null;
    switch (_current.type) {
      case ExerciseType.listenChoose:
      case ExerciseType.multipleChoice:
      case ExerciseType.trueFalse:
        return ChoiceExerciseView(
          exercise: _current,
          locked: locked,
          onAnswered: _onAnswered,
        );
      case ExerciseType.listenType:
      case ExerciseType.dictation:
      case ExerciseType.fillBlank:
      case ExerciseType.translate:
        return TypingExerciseView(
          exercise: _current,
          locked: locked,
          showTranslations: widget.showTranslations,
          onAnswered: _onAnswered,
        );
      case ExerciseType.arrangeWords:
        return ArrangeExerciseView(
          exercise: _current,
          locked: locked,
          onAnswered: _onAnswered,
        );
      case ExerciseType.match:
        return MatchExerciseView(
          exercise: _current,
          locked: locked,
          onAnswered: _onAnswered,
        );
      case ExerciseType.speak:
        return SpeakExerciseView(
          exercise: _current,
          locked: locked,
          onAnswered: _onAnswered,
        );
    }
  }
}

class _Feedback {
  const _Feedback({
    required this.correct,
    required this.message,
    this.correctAnswer,
    this.tip,
  });

  final bool correct;
  final String message;
  final String? correctAnswer;
  final String? tip;
}

/// Bottom feedback banner: green for correct, warm amber for "not yet" —
/// never punitive red walls.
class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.feedback, required this.onNext});

  final _Feedback feedback;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final background = feedback.correct
        ? (isLight ? AppColors.successSoft : const Color(0xFF1E3A2A))
        : (isLight ? const Color(0xFFFDF0E0) : const Color(0xFF3E3222));
    final accent = feedback.correct ? AppColors.success : AppColors.warning;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: AppAnimations.normal,
      curve: AppAnimations.curve,
      builder: (context, offset, child) =>
          Transform.translate(offset: Offset(0, offset * 80), child: child),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    feedback.correct
                        ? Icons.check_circle_rounded
                        : Icons.tips_and_updates_rounded,
                    color: accent,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      feedback.message,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
              if (!feedback.correct &&
                  feedback.correctAnswer != null &&
                  feedback.correctAnswer!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Answer: ${feedback.correctAnswer}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (feedback.tip != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(feedback.tip!, style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  onPressed: onNext,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
