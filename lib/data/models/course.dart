import 'cefr_level.dart';
import 'lesson.dart';

/// A topic-centric unit: everything about one theme (greetings, food, …)
/// lives together — vocabulary, grammar, reading, listening, speaking,
/// writing, video and quizzes.
class CourseUnit {
  const CourseUnit({
    required this.id,
    required this.level,
    required this.unit,
    required this.title,
    this.subtitle = '',
    this.icon = '📘',
    this.lessons = const [],
  });

  final String id;
  final String level;
  final int unit;
  final String title;
  final String subtitle;
  final String icon;
  final List<Lesson> lessons;

  factory CourseUnit.fromJson(Map<String, dynamic> json) => CourseUnit(
    id: json['id'] as String,
    level: json['level'] as String? ?? 'A1',
    unit: (json['unit'] as num?)?.toInt() ?? 1,
    title: json['title'] as String,
    subtitle: json['subtitle'] as String? ?? '',
    icon: json['icon'] as String? ?? '📘',
    lessons:
        (json['lessons'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(Lesson.fromJson)
            .toList() ??
        const [],
  );
}

/// One CEFR level of the course with its units.
class CourseLevel {
  const CourseLevel({required this.level, required this.units});

  final CefrLevel level;
  final List<CourseUnit> units;

  int get lessonCount => units.fold(0, (sum, u) => sum + u.lessons.length);
}
