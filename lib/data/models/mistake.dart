/// A wrong answer saved to the mistake notebook for later review.
class Mistake {
  const Mistake({
    required this.exerciseId,
    required this.lessonId,
    required this.prompt,
    required this.correctAnswer,
    required this.userAnswer,
    required this.timestamp,
  });

  final String exerciseId;
  final String lessonId;
  final String prompt;
  final String correctAnswer;
  final String userAnswer;
  final DateTime timestamp;

  factory Mistake.fromJson(Map<String, dynamic> json) => Mistake(
    exerciseId: json['exerciseId'] as String,
    lessonId: json['lessonId'] as String? ?? '',
    prompt: json['prompt'] as String? ?? '',
    correctAnswer: json['correctAnswer'] as String? ?? '',
    userAnswer: json['userAnswer'] as String? ?? '',
    timestamp:
        DateTime.tryParse(json['timestamp'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'lessonId': lessonId,
    'prompt': prompt,
    'correctAnswer': correctAnswer,
    'userAnswer': userAnswer,
    'timestamp': timestamp.toIso8601String(),
  };
}
