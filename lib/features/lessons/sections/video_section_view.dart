import 'package:flutter/material.dart';

import '../../../app/theme/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/lesson.dart';
import '../../video/learning_video_player.dart';
import '../widgets/exercise_player.dart';

/// Video section: watch a curated online video, browse its vocabulary and
/// transcript, then answer optional comprehension questions. Always
/// skippable — external availability must never block a lesson.
class VideoSectionView extends StatefulWidget {
  const VideoSectionView({
    super.key,
    required this.section,
    required this.onFinished,
  });

  final LessonSection section;
  final void Function(List<ExerciseOutcome> outcomes) onFinished;

  @override
  State<VideoSectionView> createState() => _VideoSectionViewState();
}

class _VideoSectionViewState extends State<VideoSectionView> {
  int _videoIndex = 0;
  bool _inQuestions = false;
  bool _showTranscript = false;
  final List<ExerciseOutcome> _outcomes = [];

  void _nextVideo(List<ExerciseOutcome> outcomes) {
    _outcomes.addAll(outcomes);
    if (_videoIndex + 1 < widget.section.videos.length) {
      setState(() {
        _videoIndex++;
        _inQuestions = false;
        _showTranscript = false;
      });
    } else {
      widget.onFinished(List.unmodifiable(_outcomes));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.section.videos.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onFinished(const []),
      );
      return const SizedBox.shrink();
    }
    final video = widget.section.videos[_videoIndex];

    if (_inQuestions && video.questions.isNotEmpty) {
      return ExercisePlayer(exercises: video.questions, onFinished: _nextVideo);
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '🌐 Online video',
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(video.title, style: theme.textTheme.headlineSmall),
              if (video.description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(video.description, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: AppSpacing.md),
              // Keyed so switching videos rebuilds the WebView.
              KeyedSubtree(
                key: ValueKey(video.url),
                child: LearningVideoPlayer(video: video),
              ),
              const SizedBox(height: AppSpacing.md),
              if (video.vocabulary.isNotEmpty) ...[
                Text(
                  'Words from this video',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final word in video.vocabulary)
                      Chip(label: Text('${word.french} — ${word.english}')),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (video.transcript.isNotEmpty) ...[
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _showTranscript = !_showTranscript),
                  icon: Icon(
                    _showTranscript
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                  label: Text(
                    _showTranscript ? 'Hide transcript' : 'Show transcript',
                  ),
                ),
                if (_showTranscript)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final line in video.transcript)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: Text(
                              line,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
        Padding(
          padding: AppSpacing.screen,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _nextVideo(const []),
                  child: const Text('Skip video'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    if (video.questions.isEmpty) {
                      _nextVideo(const []);
                    } else {
                      setState(() => _inQuestions = true);
                    }
                  },
                  child: Text(
                    video.questions.isEmpty
                        ? 'Done watching'
                        : 'Answer questions',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
