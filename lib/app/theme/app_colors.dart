import 'package:flutter/material.dart';

/// Frenchly color system.
///
/// A modern French-inspired palette: deep "French blue" primary, soft red
/// accent, cream backgrounds. Intentionally NOT a tricolore flag UI.
abstract final class AppColors {
  // Brand.
  static const Color primary = Color(0xFF23408F); // deep French blue
  static const Color primaryLight = Color(0xFF4A66B5);
  static const Color primaryDark = Color(0xFF16295F);
  static const Color accent = Color(0xFFE85D5D); // soft red accent
  static const Color accentSoft = Color(0xFFFBE4E4);
  static const Color gold = Color(0xFFF2B24C);

  // Light surfaces.
  static const Color cream = Color(0xFFFAF7F2);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1EDE6);
  static const Color outlineLight = Color(0xFFE4DFD6);

  // Dark surfaces (designed, not inverted).
  static const Color backgroundDark = Color(0xFF141824);
  static const Color surfaceDark = Color(0xFF1D2333);
  static const Color surfaceVariantDark = Color(0xFF272E42);
  static const Color outlineDark = Color(0xFF39415A);

  // Text.
  static const Color inkLight = Color(0xFF23283A);
  static const Color inkMutedLight = Color(0xFF6C7285);
  static const Color inkDark = Color(0xFFEDEFF6);
  static const Color inkMutedDark = Color(0xFF9AA1B8);

  // Semantic.
  static const Color success = Color(0xFF3B9E64);
  static const Color successSoft = Color(0xFFE0F2E7);
  static const Color warning = Color(0xFFE8A23D);
  static const Color error = Color(0xFFD9534F);
  static const Color streakFlame = Color(0xFFF07A3B);

  // CEFR level identity colors.
  static const Map<String, Color> levelColors = {
    'A1': Color(0xFF3B9E64),
    'A2': Color(0xFF3A9EA5),
    'B1': Color(0xFF23408F),
    'B2': Color(0xFF6A4FB6),
    'C1': Color(0xFFB6497A),
    'C2': Color(0xFFE85D5D),
  };

  static Color levelColor(String level) => levelColors[level] ?? primary;
}
