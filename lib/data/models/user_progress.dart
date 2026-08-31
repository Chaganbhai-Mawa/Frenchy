import 'cefr_level.dart';

/// Persistent record of everything the learner has accomplished.
///
/// Dates are stored as `yyyy-MM-dd` strings so streak logic is
/// timezone-stable and easily testable.
class UserProgress {
  const UserProgress({
    this.xp = 0,
    this.level = CefrLevel.a1,
    this.completedLessons = const {},
    this.sectionProgress = const {},
    this.activeDays = const [],
    this.xpByDay = const {},
    this.minutesByDay = const {},
    this.skillCounts = const {},
    this.videoPositions = const {},
    this.unlockedAchievements = const {},
    this.dailyChallengeCompletedOn,
    this.dailyGoalCompletedOn,
    this.adUnlockedLessons = const [],
  });

  final int xp;
  final CefrLevel level;

  /// lessonId → best quiz score 0–100.
  final Map<String, int> completedLessons;

  /// lessonId → set of completed section indexes (resume mid-lesson).
  final Map<String, Set<int>> sectionProgress;

  /// Days with any learning activity, as yyyy-MM-dd, ascending.
  final List<String> activeDays;

  /// yyyy-MM-dd → XP earned that day.
  final Map<String, int> xpByDay;

  /// yyyy-MM-dd → minutes studied that day.
  final Map<String, int> minutesByDay;

  /// Lifetime counters per skill: 'listening', 'speaking', 'reading',
  /// 'writing', 'quiz', 'vocabulary'.
  final Map<String, int> skillCounts;

  /// videoId → last watched position in seconds.
  final Map<String, int> videoPositions;

  /// achievementId → yyyy-MM-dd unlocked.
  final Map<String, String> unlockedAchievements;

  /// yyyy-MM-dd of the last completed daily challenge.
  final String? dailyChallengeCompletedOn;

  /// yyyy-MM-dd on which the daily minutes goal was last reached (the
  /// bonus is awarded once per day).
  final String? dailyGoalCompletedOn;

  /// Ids of lessons unlocked ahead of their normal sequence by watching a
  /// rewarded ad, bypassing the "finish the previous lesson first" gate.
  final List<String> adUnlockedLessons;

  bool isLessonComplete(String lessonId) =>
      completedLessons.containsKey(lessonId);

  Set<int> sectionsDone(String lessonId) =>
      sectionProgress[lessonId] ?? const {};

  /// Consecutive-day streak ending today or yesterday.
  int streak(DateTime now) {
    if (activeDays.isEmpty) return 0;
    final days = activeDays.map(_parseDay).toSet();
    var cursor = DateTime(now.year, now.month, now.day);
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!days.contains(cursor)) return 0;
    }
    var count = 0;
    while (days.contains(cursor)) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  static DateTime _parseDay(String day) {
    final parts = day.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static String dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  UserProgress copyWith({
    int? xp,
    CefrLevel? level,
    Map<String, int>? completedLessons,
    Map<String, Set<int>>? sectionProgress,
    List<String>? activeDays,
    Map<String, int>? xpByDay,
    Map<String, int>? minutesByDay,
    Map<String, int>? skillCounts,
    Map<String, int>? videoPositions,
    Map<String, String>? unlockedAchievements,
    String? dailyChallengeCompletedOn,
    String? dailyGoalCompletedOn,
    List<String>? adUnlockedLessons,
  }) => UserProgress(
    xp: xp ?? this.xp,
    level: level ?? this.level,
    completedLessons: completedLessons ?? this.completedLessons,
    sectionProgress: sectionProgress ?? this.sectionProgress,
    activeDays: activeDays ?? this.activeDays,
    xpByDay: xpByDay ?? this.xpByDay,
    minutesByDay: minutesByDay ?? this.minutesByDay,
    skillCounts: skillCounts ?? this.skillCounts,
    videoPositions: videoPositions ?? this.videoPositions,
    unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    dailyChallengeCompletedOn:
        dailyChallengeCompletedOn ?? this.dailyChallengeCompletedOn,
    dailyGoalCompletedOn: dailyGoalCompletedOn ?? this.dailyGoalCompletedOn,
    adUnlockedLessons: adUnlockedLessons ?? this.adUnlockedLessons,
  );

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
    xp: (json['xp'] as num?)?.toInt() ?? 0,
    level: CefrLevel.fromCode(json['level'] as String? ?? 'A1'),
    completedLessons:
        (json['completedLessons'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ) ??
        const {},
    sectionProgress:
        (json['sectionProgress'] as Map<String, dynamic>?)?.map(
          (k, v) =>
              MapEntry(k, (v as List).map((e) => (e as num).toInt()).toSet()),
        ) ??
        const {},
    activeDays:
        (json['activeDays'] as List?)?.map((e) => e as String).toList() ??
        const [],
    xpByDay:
        (json['xpByDay'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ) ??
        const {},
    minutesByDay:
        (json['minutesByDay'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ) ??
        const {},
    skillCounts:
        (json['skillCounts'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ) ??
        const {},
    videoPositions:
        (json['videoPositions'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ) ??
        const {},
    unlockedAchievements:
        (json['unlockedAchievements'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as String),
        ) ??
        const {},
    dailyChallengeCompletedOn: json['dailyChallengeCompletedOn'] as String?,
    dailyGoalCompletedOn: json['dailyGoalCompletedOn'] as String?,
    adUnlockedLessons:
        (json['adUnlockedLessons'] as List?)?.map((e) => e as String).toList() ??
        const [],
  );

  Map<String, dynamic> toJson() => {
    'xp': xp,
    'level': level.code,
    'completedLessons': completedLessons,
    'sectionProgress': sectionProgress.map(
      (k, v) => MapEntry(k, v.toList()..sort()),
    ),
    'activeDays': activeDays,
    'xpByDay': xpByDay,
    'minutesByDay': minutesByDay,
    'skillCounts': skillCounts,
    'videoPositions': videoPositions,
    'unlockedAchievements': unlockedAchievements,
    if (dailyChallengeCompletedOn != null)
      'dailyChallengeCompletedOn': dailyChallengeCompletedOn,
    if (dailyGoalCompletedOn != null)
      'dailyGoalCompletedOn': dailyGoalCompletedOn,
    if (adUnlockedLessons.isNotEmpty) 'adUnlockedLessons': adUnlockedLessons,
  };
}
