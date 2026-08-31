/// Every interactive question type in the app is an [Exercise].
///
/// One unified model keeps the quiz engine, listening, writing and practice
/// sections reusable: each section simply carries a list of exercises and the
/// renderer picks the right widget for [type].
enum ExerciseType {
  /// Hear French audio (TTS), pick the correct meaning.
  listenChoose,

  /// Hear French audio, type what you heard.
  listenType,

  /// Arrange scrambled words into a sentence.
  arrangeWords,

  /// Hear a sentence, write it down (harder listenType, no prompt shown).
  dictation,

  /// Classic multiple choice.
  multipleChoice,

  /// True / false statement.
  trueFalse,

  /// Fill in the blank: "Je ___ français."
  fillBlank,

  /// Translate a sentence (EN→FR or FR→EN based on [prompt]).
  translate,

  /// Match French words to English meanings.
  match,

  /// Pronounce a phrase, evaluated with speech recognition.
  speak;

  static ExerciseType fromString(String value) =>
      ExerciseType.values.firstWhere(
        (t) => t.name == value,
        orElse: () => ExerciseType.multipleChoice,
      );
}

class MatchPair {
  const MatchPair({required this.french, required this.english});

  final String french;
  final String english;

  factory MatchPair.fromJson(Map<String, dynamic> json) => MatchPair(
    french: json['french'] as String,
    english: json['english'] as String,
  );

  Map<String, dynamic> toJson() => {'french': french, 'english': english};
}

class Exercise {
  const Exercise({
    required this.id,
    required this.type,
    this.prompt = '',
    this.french,
    this.english,
    this.options = const [],
    this.answer = '',
    this.acceptedAnswers = const [],
    this.words = const [],
    this.pairs = const [],
    this.hint,
    this.tip,
  });

  final String id;
  final ExerciseType type;

  /// Instruction or question shown to the user.
  final String prompt;

  /// French text — spoken via TTS for audio exercises.
  final String? french;

  /// English support text / translation.
  final String? english;

  /// Choices for choice-based types. For [ExerciseType.trueFalse] it is
  /// implicit (Vrai / Faux) and may be empty.
  final List<String> options;

  /// The canonical correct answer.
  final String answer;

  /// Additional accepted spellings/phrasings for typed answers.
  final List<String> acceptedAnswers;

  /// Word bank for [ExerciseType.arrangeWords].
  final List<String> words;

  /// Pairs for [ExerciseType.match].
  final List<MatchPair> pairs;

  /// Optional hint shown on demand.
  final String? hint;

  /// Teaching note shown after answering.
  final String? tip;

  bool get usesAudio =>
      type == ExerciseType.listenChoose ||
      type == ExerciseType.listenType ||
      type == ExerciseType.dictation;

  bool get usesTyping =>
      type == ExerciseType.listenType ||
      type == ExerciseType.dictation ||
      type == ExerciseType.fillBlank ||
      type == ExerciseType.translate;

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'] as String? ?? '',
    type: ExerciseType.fromString(json['type'] as String),
    prompt: json['prompt'] as String? ?? '',
    french: json['french'] as String?,
    english: json['english'] as String?,
    options:
        (json['options'] as List?)?.map((e) => e as String).toList() ??
        const [],
    answer: json['answer'] as String? ?? '',
    acceptedAnswers:
        (json['acceptedAnswers'] as List?)?.map((e) => e as String).toList() ??
        const [],
    words:
        (json['words'] as List?)?.map((e) => e as String).toList() ?? const [],
    pairs:
        (json['pairs'] as List?)
            ?.map((e) => MatchPair.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    hint: json['hint'] as String?,
    tip: json['tip'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    if (prompt.isNotEmpty) 'prompt': prompt,
    if (french != null) 'french': french,
    if (english != null) 'english': english,
    if (options.isNotEmpty) 'options': options,
    if (answer.isNotEmpty) 'answer': answer,
    if (acceptedAnswers.isNotEmpty) 'acceptedAnswers': acceptedAnswers,
    if (words.isNotEmpty) 'words': words,
    if (pairs.isNotEmpty) 'pairs': pairs.map((p) => p.toJson()).toList(),
    if (hint != null) 'hint': hint,
    if (tip != null) 'tip': tip,
  };
}
