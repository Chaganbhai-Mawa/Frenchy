import 'package:flutter/material.dart';

/// Spacing scale. Use these instead of magic numbers.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets screen = EdgeInsets.all(md);
  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: md);
}

/// Corner radius scale.
abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double pill = 100;

  static final BorderRadius small = BorderRadius.circular(sm);
  static final BorderRadius medium = BorderRadius.circular(md);
  static final BorderRadius large = BorderRadius.circular(lg);
}

/// Shared animation durations (150–400ms for micro, 500–800ms for major).
abstract final class AppAnimations {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration major = Duration(milliseconds: 600);

  static const Curve curve = Curves.easeOutCubic;
  static const Curve bounce = Curves.easeOutBack;
}

/// Soft shadows for cards.
abstract final class AppShadows {
  static List<BoxShadow> card(Brightness brightness) => [
    BoxShadow(
      color: brightness == Brightness.light
          ? const Color(0x14233048)
          : const Color(0x40000000),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
