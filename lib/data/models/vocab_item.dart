/// A single vocabulary entry.
class VocabItem {
  const VocabItem({
    required this.id,
    required this.french,
    required this.english,
    this.partOfSpeech = '',
    this.gender,
    this.plural,
    this.pronunciation,
    this.example,
    this.exampleEnglish,
    this.level = 'A1',
    this.category = '',
  });

  final String id;
  final String french;
  final String english;
  final String partOfSpeech;

  /// 'm' or 'f' for nouns, null otherwise.
  final String? gender;
  final String? plural;

  /// Simplified phonetic hint, e.g. "bohn-ZHOOR".
  final String? pronunciation;
  final String? example;
  final String? exampleEnglish;
  final String level;
  final String category;

  /// French word with its article for gendered nouns, e.g. "le pain".
  String get displayFrench {
    if (gender == null || partOfSpeech != 'noun') return french;
    final first = french.isEmpty ? '' : french[0].toLowerCase();
    const vowels = ['a', 'e', 'i', 'o', 'u', 'h', 'é', 'è', 'ê', 'â', 'î'];
    if (vowels.contains(first)) return "l'$french";
    return gender == 'f' ? 'la $french' : 'le $french';
  }

  factory VocabItem.fromJson(Map<String, dynamic> json) => VocabItem(
    id: json['id'] as String? ?? json['french'] as String,
    french: json['french'] as String,
    english: json['english'] as String,
    partOfSpeech: json['partOfSpeech'] as String? ?? '',
    gender: json['gender'] as String?,
    plural: json['plural'] as String?,
    pronunciation: json['pronunciation'] as String?,
    example: json['example'] as String?,
    exampleEnglish: json['exampleEnglish'] as String?,
    level: json['level'] as String? ?? 'A1',
    category: json['category'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'french': french,
    'english': english,
    'partOfSpeech': partOfSpeech,
    if (gender != null) 'gender': gender,
    if (plural != null) 'plural': plural,
    if (pronunciation != null) 'pronunciation': pronunciation,
    if (example != null) 'example': example,
    if (exampleEnglish != null) 'exampleEnglish': exampleEnglish,
    'level': level,
    'category': category,
  };
}
