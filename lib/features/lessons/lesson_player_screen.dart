import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants/app_constants.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/widgets/confetti_overlay.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/achievement.dart';
import '../../data/models/lesson.dart';
import '../../data/models/mistake.dart';
import 'lesson_engine.dart';
import 'sections/learn_section_view.dart';
import 'sections/reading_section_view.dart';
import 'sections/video_section_view.dart';
import 'sections/vocabulary_section_view.dart';
import 'widgets/exercise_player.dart';

/// Plays a lesson section by section: renders the right view for each
/// section type, awards XP, records skills and mistakes, persists progress
/// after every step, and celebrates completion.
class LessonPlayerScreen extends ConsumerStatefulWidget {
  const LessonPlayerScreen({
    super.key,
    required this.lessonId,
    required this.initialSectionIndex,
  });

  final String lessonId;
  final int initialSectionIndex;

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  late int _index = widget.initialSectionIndex;
  final Stopwatch _stopwatch = Stopwatch()..start();
  int _minutesRecorded = 0;

  // Session results.
  int _quizCorrect = 0;
  int _quizTotal = 0;
  final List<Achievement> _unlocked = [];
  bool _celebrating = false;
  int _sessionXp = 0;
  int _newWords = 0;

  Future<void> _recordMinutes() async {
    final minutes = _stopwatch.elapsed.inMinutes - _minutesRecorded;
    if (minutes > 0) {
      _minutesRecorded += minutes;
      await ref.read(progressProvider.notifier).addMinutes(minutes);
    }
  }

  Future<void> _onSectionDone(
    Lesson lesson,
    List<LessonSection> sections,
    List<ExerciseOutcome> outcomes,
  ) async {
    final section = sections[_index];
    final progressNotifier = ref.read(progressProvider.notifier);
    final alreadyDone = ref
        .read(progressProvider)
        .sectionsDone(lesson.id)
        .contains(_index);

    // Mistake notebook + quiz score bookkeeping.
    for (final outcome in outcomes) {
      if (!outcome.correct) {
        await ref
            .read(mistakesProvider.notifier)
            .add(
              Mistake(
                exerciseId: outcome.exercise.id,
                lessonId: lesson.id,
                prompt: outcome.exercise.prompt.isNotEmpty
                    ? outcome.exercise.prompt
                    : (outcome.exercise.french ?? ''),
                correctAnswer: outcome.exercise.answer,
                userAnswer: outcome.userAnswer,
                timestamp: DateTime.now(),
              ),
            );
      }
    }
    if (section.type == SectionType.quiz) {
      _quizCorrect += outcomes.where((o) => o.correct).length;
      _quizTotal += outcomes.length;
    }

    final skill = sectionSkill(section.type);
    if (skill != null && outcomes.isNotEmpty) {
      await progressNotifier.recordSkill(skill, outcomes.length);
    }
    if (section.type == SectionType.vocabulary) {
      _newWords += section.vocabulary.length;
    }

    // Section XP only the first time — no XP farming by replaying.
    if (!alreadyDone) {
      final xp = sectionXp(section.type);
      _sessionXp += xp;
      _unlocked.addAll(await progressNotifier.addXp(xp));
    }
    await progressNotifier.markSectionDone(lesson.id, _index);
    await _recordMinutes();
    if (!mounted) return;

    // Advance or finish.
    if (_index + 1 < sections.length) {
      setState(() => _index++);
      return;
    }
    await _finishLesson(lesson, sections);
  }

  Future<void> _finishLesson(
    Lesson lesson,
    List<LessonSection> sections,
  ) async {
    final progressNotifier = ref.read(progressProvider.notifier);
    final progress = ref.read(progressProvider);
    final done = progress.sectionsDone(lesson.id);
    final allRequiredDone = [
      for (final (i, s) in sections.indexed)
        if (s.required) i,
    ].every(done.contains);

    if (allRequiredDone) {
      final wasComplete = progress.isLessonComplete(lesson.id);
      final score = _quizTotal > 0
          ? (100 * _quizCorrect / _quizTotal).round()
          : (progress.completedLessons[lesson.id] ?? 100);
      final lessonXp = wasComplete
          ? AppConstants.xpLessonRepeat
          : AppConstants.xpLesson;
      _sessionXp += lessonXp;
      _unlocked.addAll(await progressNotifier.addXp(lessonXp));
      _unlocked.addAll(await progressNotifier.completeLesson(lesson.id, score));

      // Finishing the last lesson of a level advances the learner.
      try {
        final course = await ref.read(
          courseLevelProvider(ref.read(progressProvider).level).future,
        );
        _unlocked.addAll(
          await progressNotifier.maybeAdvanceLevel([
            for (final unit in course.units)
              for (final l in unit.lessons) l.id,
          ]),
        );
      } catch (_) {
        // Level advancement is a bonus — never block the celebration.
      }
    }
    await _recordMinutes();
    if (!mounted) return;
    setState(() => _celebrating = true);
    // Lesson completion is the app's most reliable natural break point.
    if (ref.read(adsEnabledProvider)) {
      ref.read(adsServiceProvider).interstitial.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonAsync = ref.watch(lessonProvider(widget.lessonId));
    final catalog = ref.watch(videoCatalogProvider).valueOrNull ?? const [];
    final showTranslations = ref.watch(
      settingsProvider.select((s) => s.showTranslations),
    );

    return lessonAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          emoji: '😕',
          title: 'Lesson unavailable',
          message: "We couldn't load this lesson. Please try again.",
        ),
      ),
      data: (lesson) {
        if (lesson == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              emoji: '🔍',
              title: 'Lesson not found',
              message: 'This lesson does not exist yet.',
            ),
          );
        }
        final sections = effectiveSections(lesson, catalog);
        if (_celebrating) {
          return _CelebrationView(
            lesson: lesson,
            score: _quizTotal > 0
                ? (100 * _quizCorrect / _quizTotal).round()
                : null,
            xp: _sessionXp,
            newWords: _newWords,
            unlocked: _unlocked,
          );
        }
        if (_index >= sections.length) {
          // Defensive: bad deep link index.
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              emoji: '🔍',
              title: 'Section not found',
              message: 'This lesson step does not exist.',
            ),
          );
        }
        final section = sections[_index];
        return Scaffold(
          appBar: AppBar(
            title: Text('${section.type.emoji}  ${section.title}'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Center(
                  child: Text(
                    '${_index + 1} / ${sections.length}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: KeyedSubtree(
              key: ValueKey('${lesson.id}_$_index'),
              child: _buildSection(lesson, sections, section, showTranslations),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(
    Lesson lesson,
    List<LessonSection> sections,
    LessonSection section,
    bool showTranslations,
  ) {
    void doneNoOutcomes() => _onSectionDone(lesson, sections, const []);
    void doneWithOutcomes(List<ExerciseOutcome> outcomes) =>
        _onSectionDone(lesson, sections, outcomes);

    switch (section.type) {
      case SectionType.learn:
      case SectionType.grammar:
      case SectionType.pronunciation:
        return LearnSectionView(
          section: section,
          showTranslations: showTranslations,
          onDone: doneNoOutcomes,
        );
      case SectionType.vocabulary:
        return VocabularySectionView(
          items: section.vocabulary,
          onDone: doneNoOutcomes,
        );
      case SectionType.reading:
        return ReadingSectionView(
          section: section,
          lessonVocabulary: lesson.allVocabulary,
          showTranslations: showTranslations,
          onFinished: doneWithOutcomes,
        );
      case SectionType.video:
        return VideoSectionView(section: section, onFinished: doneWithOutcomes);
      case SectionType.listening:
      case SectionType.speaking:
      case SectionType.writing:
      case SectionType.practice:
      case SectionType.quiz:
      case SectionType.review:
        return ExercisePlayer(
          exercises: section.exercises,
          showTranslations: showTranslations,
          onFinished: doneWithOutcomes,
        );
    }
  }
}

/// 🎉 End-of-lesson celebration: XP, score, streak, new words, achievements.
class _CelebrationView extends ConsumerWidget {
  const _CelebrationView({
    required this.lesson,
    required this.score,
    required this.xp,
    required this.newWords,
    required this.unlocked,
  });

  final Lesson lesson;
  final int? score;
  final int xp;
  final int newWords;
  final List<Achievement> unlocked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = ref.watch(progressProvider);
    final streak = progress.streak(DateTime.now());
    final reduced = ref.watch(
      settingsProvider.select((s) => s.reducedAnimations),
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: AppSpacing.screen,
                child: Column(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: AppSpacing.md),
                    Text('Excellent !', style: theme.textTheme.displayMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${lesson.title} — lesson complete',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      alignment: WrapAlignment.center,
                      children: [
                        _StatChip(label: '+$xp XP', emoji: '⚡'),
                        if (score != null)
                          _StatChip(label: '$score% score', emoji: '🎯'),
                        if (streak > 0)
                          _StatChip(label: '$streak day streak', emoji: '🔥'),
                        if (newWords > 0)
                          _StatChip(label: '$newWords new words', emoji: '📚'),
                      ],
                    ),
                    if (unlocked.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Achievement unlocked !',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final achievement in unlocked)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Text(
                            '${achievement.emoji} ${achievement.title} — '
                            '${achievement.description}',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          // Back to wherever the lesson was opened from.
                          if (context.canPop()) {
                            context.pop();
                            if (context.canPop()) context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!reduced) const Positioned.fill(child: ConfettiOverlay()),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.emoji});

  final String label;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.card(theme.brightness),
      ),
      child: Text('$emoji $label', style: theme.textTheme.titleSmall),
    );
  }
}
