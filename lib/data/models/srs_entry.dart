/// Spaced-repetition state for one vocabulary word (Leitner-style boxes).
///
/// Box intervals: 0 → same day, 1 → 1 day, 2 → 3 days, 3 → 7 days,
/// 4 → 14 days, 5 → 30 days. Wrong answers drop the word one box so it
/// comes back sooner; correct answers promote it.
class SrsEntry {
  const SrsEntry({
    required this.wordId,
    this.box = 0,
    this.timesSeen = 0,
    this.timesCorrect = 0,
    this.timesIncorrect = 0,
    this.lastReviewed,
    this.nextReview,
  });

  static const List<int> boxIntervalDays = [0, 1, 3, 7, 14, 30];
  static const int maxBox = 5;

  final String wordId;
  final int box;
  final int timesSeen;
  final int timesCorrect;
  final int timesIncorrect;
  final DateTime? lastReviewed;
  final DateTime? nextReview;

  bool isDue(DateTime now) => nextReview == null || !nextReview!.isAfter(now);

  /// A word is "learned" once it has left the first two boxes.
  bool get isLearned => box >= 2;

  /// A word is "weak" when it keeps being missed.
  bool get isWeak => timesIncorrect > 0 && timesIncorrect >= timesCorrect;

  SrsEntry review({required bool correct, required DateTime now}) {
    final newBox = correct
        ? (box + 1).clamp(0, maxBox)
        : (box - 1).clamp(0, maxBox);
    return SrsEntry(
      wordId: wordId,
      box: newBox,
      timesSeen: timesSeen + 1,
      timesCorrect: timesCorrect + (correct ? 1 : 0),
      timesIncorrect: timesIncorrect + (correct ? 0 : 1),
      lastReviewed: now,
      nextReview: now.add(Duration(days: boxIntervalDays[newBox])),
    );
  }

  factory SrsEntry.fromJson(Map<String, dynamic> json) => SrsEntry(
    wordId: json['wordId'] as String,
    box: (json['box'] as num?)?.toInt() ?? 0,
    timesSeen: (json['timesSeen'] as num?)?.toInt() ?? 0,
    timesCorrect: (json['timesCorrect'] as num?)?.toInt() ?? 0,
    timesIncorrect: (json['timesIncorrect'] as num?)?.toInt() ?? 0,
    lastReviewed: json['lastReviewed'] != null
        ? DateTime.tryParse(json['lastReviewed'] as String)
        : null,
    nextReview: json['nextReview'] != null
        ? DateTime.tryParse(json['nextReview'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'wordId': wordId,
    'box': box,
    'timesSeen': timesSeen,
    'timesCorrect': timesCorrect,
    'timesIncorrect': timesIncorrect,
    if (lastReviewed != null) 'lastReviewed': lastReviewed!.toIso8601String(),
    if (nextReview != null) 'nextReview': nextReview!.toIso8601String(),
  };
}
