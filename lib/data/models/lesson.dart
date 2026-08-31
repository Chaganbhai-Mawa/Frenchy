import 'exercise.dart';
import 'video_content.dart';
import 'vocab_item.dart';

/// Section kinds a lesson may contain. The JSON author controls which
/// sections exist and their order; the UI renders whatever is supplied.
enum SectionType {
  learn('Learn', '📚'),
  vocabulary('Vocabulary', '🎯'),
  grammar('Grammar', '🧩'),
  pronunciation('Pronunciation', '🗣️'),
  reading('Reading', '📖'),
  listening('Listening', '🎧'),
  speaking('Speaking', '🎤'),
  writing('Writing', '✍️'),
  video('Watch', '🎬'),
  practice('Practice', '🧠'),
  quiz('Quiz', '🏆'),
  review('Review', '🔁');

  const SectionType(this.defaultTitle, this.emoji);

  final String defaultTitle;
  final String emoji;

  static SectionType? fromString(String value) {
    for (final t in SectionType.values) {
      if (t.name == value) return t;
    }
    return null;
  }
}

/// A teaching block inside learn/grammar/pronunciation sections:
/// explanation text plus French/English example pairs and an optional tip.
class LearnBlock {
  const LearnBlock({
    this.heading = '',
    this.body = '',
    this.examples = const [],
    this.tip,
  });

  final String heading;
  final String body;
  final List<ExamplePair> examples;
  final String? tip;

  factory LearnBlock.fromJson(Map<String, dynamic> json) => LearnBlock(
    heading: json['heading'] as String? ?? '',
    body: json['body'] as String? ?? '',
    examples:
        (json['examples'] as List?)
            ?.map((e) => ExamplePair.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    tip: json['tip'] as String?,
  );
}

class ExamplePair {
  const ExamplePair({required this.french, required this.english, this.note});

  final String french;
  final String english;
  final String? note;

  factory ExamplePair.fromJson(Map<String, dynamic> json) => ExamplePair(
    french: json['french'] as String,
    english: json['english'] as String? ?? '',
    note: json['note'] as String?,
  );
}

/// A reading passage with optional translation and comprehension questions.
class ReadingPassage {
  const ReadingPassage({
    this.title = '',
    required this.french,
    this.english = '',
    this.questions = const [],
  });

  final String title;
  final String french;
  final String english;
  final List<Exercise> questions;

  factory ReadingPassage.fromJson(Map<String, dynamic> json) => ReadingPassage(
    title: json['title'] as String? ?? '',
    french: json['french'] as String,
    english: json['english'] as String? ?? '',
    questions:
        (json['questions'] as List?)
            ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );
}

/// One step of a lesson's journey. Only the payload matching [type] is set.
class LessonSection {
  const LessonSection({
    required this.type,
    required this.title,
    this.required = true,
    this.blocks = const [],
    this.vocabulary = const [],
    this.passage = const [],
    this.exercises = const [],
    this.videos = const [],
  });

  final SectionType type;
  final String title;

  /// Whether this section counts toward lesson completion. External video
  /// sections default to optional.
  final bool required;

  /// learn / grammar / pronunciation.
  final List<LearnBlock> blocks;

  /// vocabulary.
  final List<VocabItem> vocabulary;

  /// reading (usually a single passage; list allows multi-passage lessons).
  final List<ReadingPassage> passage;

  /// listening / speaking / writing / practice / quiz / review.
  final List<Exercise> exercises;

  /// video.
  final List<VideoContent> videos;

  bool get isEmpty =>
      blocks.isEmpty &&
      vocabulary.isEmpty &&
      passage.isEmpty &&
      exercises.isEmpty &&
      videos.isEmpty;

  static LessonSection? fromJson(Map<String, dynamic> json) {
    final type = SectionType.fromString(json['type'] as String? ?? '');
    if (type == null) return null; // Unknown type: skip gracefully.
    return LessonSection(
      type: type,
      title: json['title'] as String? ?? type.defaultTitle,
      required: json['required'] as bool? ?? (type != SectionType.video),
      blocks:
          (json['blocks'] as List?)
              ?.map((e) => LearnBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      vocabulary:
          (json['items'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .where((_) => type == SectionType.vocabulary)
              .map(VocabItem.fromJson)
              .toList() ??
          const [],
      passage:
          (json['passages'] as List?)
              ?.map((e) => ReadingPassage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      exercises: type == SectionType.vocabulary || type == SectionType.video
          ? const []
          : (json['items'] as List?)
                    ?.whereType<Map<String, dynamic>>()
                    .map(Exercise.fromJson)
                    .toList() ??
                const [],
      videos: type == SectionType.video
          ? (json['items'] as List?)
                    ?.whereType<Map<String, dynamic>>()
                    .map(VideoContent.fromJson)
                    .toList() ??
                const []
          : const [],
    );
  }
}

class Lesson {
  const Lesson({
    required this.id,
    required this.level,
    required this.unit,
    required this.title,
    this.description = '',
    this.estimatedMinutes = 10,
    this.sections = const [],
  });

  final String id;
  final String level;
  final int unit;
  final String title;
  final String description;
  final int estimatedMinutes;
  final List<LessonSection> sections;

  List<LessonSection> get requiredSections =>
      sections.where((s) => s.required && !s.isEmpty).toList();

  List<VocabItem> get allVocabulary => [
    for (final s in sections) ...s.vocabulary,
    for (final s in sections)
      for (final v in s.videos) ...v.vocabulary,
  ];

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] as String,
    level: json['level'] as String? ?? 'A1',
    unit: (json['unit'] as num?)?.toInt() ?? 1,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 10,
    sections:
        (json['sections'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(LessonSection.fromJson)
            .whereType<LessonSection>()
            .where((s) => !s.isEmpty)
            .toList() ??
        const [],
  );
}
