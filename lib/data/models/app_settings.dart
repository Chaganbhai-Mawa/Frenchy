import 'package:flutter/material.dart';

import '../../app/constants/app_constants.dart';

/// User preferences persisted locally.
class AppSettings {
  const AppSettings({
    this.name = '',
    this.onboardingComplete = false,
    this.dailyGoalMinutes = AppConstants.defaultDailyGoalMinutes,
    this.showTranslations = true,
    this.soundEnabled = true,
    this.speechRate = 0.45,
    this.themeMode = ThemeMode.system,
    this.reducedAnimations = false,
    this.favoriteWords = const [],
    this.favoriteLessons = const [],
  });

  final String name;
  final bool onboardingComplete;
  final int dailyGoalMinutes;

  /// Progressive-reduction support: learners can hide English help.
  final bool showTranslations;
  final bool soundEnabled;

  /// TTS rate: 0.3 (slow) – 0.7 (natural).
  final double speechRate;
  final ThemeMode themeMode;
  final bool reducedAnimations;
  final List<String> favoriteWords;
  final List<String> favoriteLessons;

  AppSettings copyWith({
    String? name,
    bool? onboardingComplete,
    int? dailyGoalMinutes,
    bool? showTranslations,
    bool? soundEnabled,
    double? speechRate,
    ThemeMode? themeMode,
    bool? reducedAnimations,
    List<String>? favoriteWords,
    List<String>? favoriteLessons,
  }) => AppSettings(
    name: name ?? this.name,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    showTranslations: showTranslations ?? this.showTranslations,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    speechRate: speechRate ?? this.speechRate,
    themeMode: themeMode ?? this.themeMode,
    reducedAnimations: reducedAnimations ?? this.reducedAnimations,
    favoriteWords: favoriteWords ?? this.favoriteWords,
    favoriteLessons: favoriteLessons ?? this.favoriteLessons,
  );

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    name: json['name'] as String? ?? '',
    onboardingComplete: json['onboardingComplete'] as bool? ?? false,
    dailyGoalMinutes:
        (json['dailyGoalMinutes'] as num?)?.toInt() ??
        AppConstants.defaultDailyGoalMinutes,
    showTranslations: json['showTranslations'] as bool? ?? true,
    soundEnabled: json['soundEnabled'] as bool? ?? true,
    speechRate: (json['speechRate'] as num?)?.toDouble() ?? 0.45,
    themeMode: ThemeMode.values.firstWhere(
      (m) => m.name == json['themeMode'],
      orElse: () => ThemeMode.system,
    ),
    reducedAnimations: json['reducedAnimations'] as bool? ?? false,
    favoriteWords:
        (json['favoriteWords'] as List?)?.map((e) => e as String).toList() ??
        const [],
    favoriteLessons:
        (json['favoriteLessons'] as List?)?.map((e) => e as String).toList() ??
        const [],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'onboardingComplete': onboardingComplete,
    'dailyGoalMinutes': dailyGoalMinutes,
    'showTranslations': showTranslations,
    'soundEnabled': soundEnabled,
    'speechRate': speechRate,
    'themeMode': themeMode.name,
    'reducedAnimations': reducedAnimations,
    'favoriteWords': favoriteWords,
    'favoriteLessons': favoriteLessons,
  };
}
