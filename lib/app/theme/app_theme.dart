import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';

/// Material 3 themes, heavily customized so screens don't look stock.
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    final Color ink = isLight ? AppColors.inkLight : AppColors.inkDark;
    final Color inkMuted = isLight
        ? AppColors.inkMutedLight
        : AppColors.inkMutedDark;
    final Color background = isLight
        ? AppColors.cream
        : AppColors.backgroundDark;
    final Color surface = isLight
        ? AppColors.surfaceLight
        : AppColors.surfaceDark;
    final Color surfaceVariant = isLight
        ? AppColors.surfaceVariantLight
        : AppColors.surfaceVariantDark;
    final Color outline = isLight
        ? AppColors.outlineLight
        : AppColors.outlineDark;
    final Color primary = isLight ? AppColors.primary : AppColors.primaryLight;

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: isLight
          ? const Color(0xFFDDE4F6)
          : AppColors.primaryDark,
      onPrimaryContainer: isLight ? AppColors.primaryDark : Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: isLight
          ? AppColors.accentSoft
          : const Color(0xFF4A2A2A),
      onSecondaryContainer: isLight
          ? const Color(0xFF7A2C2C)
          : const Color(0xFFF6C9C9),
      tertiary: AppColors.gold,
      onTertiary: const Color(0xFF4A3410),
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: ink,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: inkMuted,
      outline: outline,
      outlineVariant: outline,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: isLight ? AppColors.inkLight : AppColors.cream,
      onInverseSurface: isLight ? Colors.white : AppColors.inkLight,
      inversePrimary: AppColors.primaryLight,
    );

    final TextTheme textTheme = AppTypography.textTheme(ink, inkMuted);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 54),
          textStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(64, 54),
          side: BorderSide(color: outline, width: 1.5),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: scheme.primaryContainer,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.small),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.large),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        labelStyle: textTheme.labelMedium?.copyWith(color: ink),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        side: BorderSide.none,
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
        iconColor: inkMuted,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? Colors.white : inkMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? primary : surfaceVariant,
        ),
      ),
    );
  }
}
