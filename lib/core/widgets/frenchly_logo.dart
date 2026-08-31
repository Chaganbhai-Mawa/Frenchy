import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// The Frenchly brand mark: the app's illustrated character logo, used on the
/// splash screen, profile and empty states.
///
/// Decoded at the requested display size (`cacheWidth`) so low-end devices
/// never hold the full-resolution bitmap in memory. If the asset is missing
/// the widget degrades to a simple monogram rather than showing an error box.
class FrenchlyLogo extends StatelessWidget {
  const FrenchlyLogo({super.key, this.size = 96});

  static const String assetPath = 'assets/branding/app_logo.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: ui.FilterQuality.medium,
      cacheWidth: (size * devicePixelRatio).round(),
      errorBuilder: (context, _, _) => _LogoFallback(size: size),
    );
  }
}

/// Drawn in code so a missing or unreadable asset can never break a screen.
class _LogoFallback extends StatelessWidget {
  const _LogoFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(size * 0.24),
      ),
      alignment: Alignment.center,
      child: Text(
        'F',
        style: TextStyle(
          fontSize: size * 0.5,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}
