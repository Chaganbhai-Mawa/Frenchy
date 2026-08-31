/// CEFR proficiency levels, the backbone of the course progression.
enum CefrLevel {
  a1('A1', 'Beginner'),
  a2('A2', 'Elementary'),
  b1('B1', 'Intermediate'),
  b2('B2', 'Upper Intermediate'),
  c1('C1', 'Advanced'),
  c2('C2', 'Expert');

  const CefrLevel(this.code, this.label);

  final String code;
  final String label;

  static CefrLevel fromCode(String code) => CefrLevel.values.firstWhere(
    (l) => l.code.toLowerCase() == code.toLowerCase(),
    orElse: () => CefrLevel.a1,
  );

  bool operator <(CefrLevel other) => index < other.index;
  bool operator >=(CefrLevel other) => index >= other.index;

  CefrLevel? get next =>
      index + 1 < CefrLevel.values.length ? CefrLevel.values[index + 1] : null;
}
