import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/widgets/audio_button.dart';
import '../../../data/models/exercise.dart';
import 'exercise_views.dart';

/// Speaking exercise: listen → tap microphone → speak → transcription
/// similarity score. We honestly label the score as "recognition", never as
/// phonetic accuracy the device API cannot measure.
class SpeakExerciseView extends ConsumerStatefulWidget {
  const SpeakExerciseView({
    super.key,
    required this.exercise,
    required this.locked,
    required this.onAnswered,
  });

  final Exercise exercise;
  final bool locked;
  final AnswerCallback onAnswered;

  @override
  ConsumerState<SpeakExerciseView> createState() => _SpeakExerciseViewState();
}

class _SpeakExerciseViewState extends ConsumerState<SpeakExerciseView> {
  bool _listening = false;
  String _partial = '';
  SpeechAttempt? _attempt;

  Future<void> _startListening() async {
    final speech = ref.read(speechProvider);
    setState(() {
      _listening = true;
      _partial = '';
      _attempt = null;
    });
    final attempt = await speech.listenFor(
      widget.exercise.french ?? '',
      onPartial: (partial) {
        if (mounted) setState(() => _partial = partial);
      },
    );
    if (!mounted) return;
    setState(() {
      _listening = false;
      _attempt = attempt;
    });
  }

  void _submit() {
    final attempt = _attempt;
    if (attempt == null) return;
    final score = (attempt.similarity * 100).round();
    widget.onAnswered(
      attempt.similarity >= 0.6,
      attempt.transcript,
      message: attempt.similarity >= 0.9
          ? 'Excellent ! Recognized $score% of the words. 🎉'
          : attempt.similarity >= 0.6
          ? 'Très bien ! Recognized $score% — keep practicing.'
          : 'Good try — the recognizer caught $score%. Listen and repeat once more.',
    );
  }

  /// Speech is optional: never block learners without a mic or the API.
  void _skip() {
    widget.onAnswered(
      true,
      '(practiced without microphone)',
      message: 'Practiced by listening and repeating — nice work !',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercise = widget.exercise;
    return ExerciseShell(
      exercise: exercise,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The phrase to pronounce.
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppRadius.medium,
              boxShadow: AppShadows.card(theme.brightness),
            ),
            child: Column(
              children: [
                Text(
                  exercise.french ?? '',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                if (exercise.english != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    exercise.english!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AudioButton(text: exercise.french ?? '', size: 30),
                    const SizedBox(width: AppSpacing.sm),
                    AudioButton(
                      text: exercise.french ?? '',
                      slow: true,
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (exercise.tip != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text('💡 ${exercise.tip}', style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: AppSpacing.lg),

          // Microphone.
          Center(
            child: GestureDetector(
              onTap: widget.locked || _listening ? null : _startListening,
              child: AnimatedContainer(
                duration: AppAnimations.normal,
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: _listening
                      ? AppColors.accent
                      : theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (_listening)
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 6,
                      ),
                  ],
                ),
                child: Icon(
                  _listening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              _listening
                  ? 'Listening… speak now !'
                  : 'Tap the microphone and say the phrase',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (_listening && _partial.isNotEmpty)
            Center(
              child: Text('« $_partial »', style: theme.textTheme.titleMedium),
            ),

          if (_attempt != null) _buildResult(theme),

          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: widget.locked ? null : _skip,
                child: const Text('Practice without mic'),
              ),
              FilledButton(
                onPressed: widget.locked || _attempt == null ? null : _submit,
                child: const Text('Continue'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResult(ThemeData theme) {
    final attempt = _attempt!;
    if (!attempt.succeeded) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppRadius.small,
        ),
        child: Text(attempt.error!, style: theme.textTheme.bodyMedium),
      );
    }
    final score = (attempt.similarity * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('We heard:', style: theme.textTheme.labelMedium),
        Text('« ${attempt.transcript} »', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: attempt.similarity,
                  minHeight: 10,
                  color: score >= 60 ? AppColors.success : AppColors.warning,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('$score% recognized', style: theme.textTheme.labelMedium),
          ],
        ),
      ],
    );
  }
}
