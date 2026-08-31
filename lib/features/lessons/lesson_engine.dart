import '../../app/constants/app_constants.dart';
import '../../data/models/lesson.dart';
import '../../data/models/user_progress.dart';
import '../../data/models/video_content.dart';

/// Unit id ("a1_u03") derived from a lesson id ("a1_u03_l02").
String unitIdOf(String lessonId) {
  final parts = lessonId.split('_');
  return parts.length >= 2 ? '${parts[0]}_${parts[1]}' : lessonId;
}

/// The sections actually shown for a lesson: the authored sections, plus an
/// optional appended "Watch" section built from the curated video catalog
/// (videos.json entries whose topic matches this lesson's unit). Catalog
/// videos are attached before the quiz so the journey ends on the test.
List<LessonSection> effectiveSections(
  Lesson lesson,
  List<VideoContent> catalog,
) {
  final hasOwnVideo = lesson.sections.any((s) => s.type == SectionType.video);
  final matching = catalog
      .where((v) => v.topic == unitIdOf(lesson.id))
      .toList();
  if (hasOwnVideo || matching.isEmpty) return lesson.sections;

  final videoSection = LessonSection(
    type: SectionType.video,
    title: 'Watch & Listen',
    required: false,
    videos: matching,
  );
  final sections = List<LessonSection>.of(lesson.sections);
  final quizIndex = sections.indexWhere((s) => s.type == SectionType.quiz);
  if (quizIndex >= 0) {
    sections.insert(quizIndex, videoSection);
  } else {
    sections.add(videoSection);
  }
  return sections;
}

/// XP awarded for completing a section of the given type.
int sectionXp(SectionType type) => switch (type) {
  SectionType.learn ||
  SectionType.grammar ||
  SectionType.pronunciation => AppConstants.xpLearnSection,
  SectionType.vocabulary => AppConstants.xpVocabulary,
  SectionType.listening => AppConstants.xpListening,
  SectionType.speaking => AppConstants.xpSpeaking,
  SectionType.reading => AppConstants.xpReading,
  SectionType.writing => AppConstants.xpWriting,
  SectionType.video => AppConstants.xpVideo,
  SectionType.practice => AppConstants.xpPractice,
  SectionType.quiz => AppConstants.xpQuiz,
  SectionType.review => AppConstants.xpReview,
};

/// Whether [unitLessons]\[index\] is locked: every lesson but the first in a
/// unit stays locked until its predecessor is complete, unless the learner
/// unlocked it early by watching a rewarded ad. Already-completed lessons
/// are never locked, so this only ever gates new ground.
bool isLessonLocked(
  UserProgress progress,
  List<Lesson> unitLessons,
  int index,
) {
  if (index <= 0) return false;
  final lesson = unitLessons[index];
  if (progress.isLessonComplete(lesson.id)) return false;
  if (progress.adUnlockedLessons.contains(lesson.id)) return false;
  return !progress.isLessonComplete(unitLessons[index - 1].id);
}

/// The next lesson that is currently locked for the learner across
/// [allLessons] (grouped by unit in [lessonsByUnit]), if any — the target
/// for the Home tab's "unlock next lesson" rewarded-ad action.
Lesson? nextLockedLesson(
  UserProgress progress,
  Map<String, List<Lesson>> lessonsByUnit,
) {
  for (final unitLessons in lessonsByUnit.values) {
    for (final (index, lesson) in unitLessons.indexed) {
      if (isLessonLocked(progress, unitLessons, index)) return lesson;
    }
  }
  return null;
}

/// Skill counter key for a section type (null = not a counted skill).
String? sectionSkill(SectionType type) => switch (type) {
  SectionType.listening => 'listening',
  SectionType.speaking => 'speaking',
  SectionType.reading => 'reading',
  SectionType.writing => 'writing',
  SectionType.quiz || SectionType.practice => 'quiz',
  _ => null,
};
