import 'package:flutter/material.dart';

/// Typography hierarchy. Uses the platform default sans (Roboto on Android)
/// with carefully tuned weights and sizes; large readable lesson text is the
/// priority. A bundled font (e.g. Inter) can be dropped in later by setting
/// [fontFamily].
abstract final class AppTypography {
  static const String? fontFamily = null;

  static TextTheme textTheme(Color ink, Color inkMuted) => TextTheme(
    displayLarge: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      height: 1.1,
      letterSpacing: -0.5,
      color: ink,
    ),
    displayMedium: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -0.5,
      color: ink,
    ),
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: ink,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: ink,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: ink,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: ink,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: ink,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: ink,
    ),
    bodyLarge: TextStyle(fontSize: 17, height: 1.45, color: ink),
    bodyMedium: TextStyle(fontSize: 15, height: 1.45, color: ink),
    bodySmall: TextStyle(fontSize: 13, height: 1.4, color: inkMuted),
    labelLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: ink,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: inkMuted,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: inkMuted,
    ),
  );

  /// Extra-large style for French words on learning cards.
  static const TextStyle frenchDisplay = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.3,
  );
}
