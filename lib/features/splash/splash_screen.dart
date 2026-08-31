import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants/app_constants.dart';
import '../../app/providers.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/frenchly_logo.dart';

/// Launch animation: logo fades in and settles with a soft overshoot,
/// accent particles drift up, tagline appears. Kept short (~1.9s) on first
/// launch and much shorter (~0.7s) for returning users.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _taglineFade;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    final returning = settings.onboardingComplete;
    final reduced = settings.reducedAnimations;
    final duration = reduced || returning
        ? const Duration(milliseconds: 700)
        : const Duration(milliseconds: 1900);

    _controller = AnimationController(vsync: this, duration: duration);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.35, curve: Curves.easeOut),
    );
    _scale =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.05), weight: 60),
          TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 40),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0, 0.55, curve: Curves.easeOutCubic),
          ),
        );
    _taglineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.8, curve: Curves.easeOut),
    );

    _controller.forward().whenComplete(_goNext);
  }

  void _goNext() {
    if (_navigated || !mounted) return;
    _navigated = true;
    // Cold-start app-open impression; resumes-from-background are handled
    // by the app-wide lifecycle observer in FrenchlyApp.
    if (ref.read(adsEnabledProvider)) {
      ref.read(adsServiceProvider).appOpen.showAdIfAvailable();
    }
    final onboarded = ref.read(settingsProvider).onboardingComplete;
    context.go(onboarded ? '/home' : '/onboarding');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: GestureDetector(
        // Splash is always skippable.
        onTap: _goNext,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Stack(
            children: [
              _Particles(progress: _controller.value),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _fade,
                      child: ScaleTransition(
                        scale: _scale,
                        child: const FrenchlyLogo(size: 120),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _taglineFade,
                      child: Column(
                        children: [
                          Text(
                            AppConstants.appName,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppConstants.tagline,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small drifting French accents (é à ç) — subtle, low-count particles.
class _Particles extends StatelessWidget {
  const _Particles({required this.progress});

  final double progress;

  static const List<String> _glyphs = ['é', 'à', 'ç', 'ê', 'œ', 'ï'];

  @override
  Widget build(BuildContext context) {
    final random = math.Random(7);
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: List.generate(_glyphs.length, (i) {
          final x = random.nextDouble();
          final startY = 0.55 + random.nextDouble() * 0.4;
          final drift = 0.25 + random.nextDouble() * 0.2;
          final appear = 0.3 + i * 0.06;
          final local = ((progress - appear) / (1 - appear)).clamp(0.0, 1.0);
          return Positioned(
            left: x * constraints.maxWidth,
            top: (startY - drift * local) * constraints.maxHeight,
            child: Opacity(
              opacity: (local < 0.5 ? local * 2 : (1 - local) * 2).clamp(0, 1),
              child: Text(
                _glyphs[i],
                style: TextStyle(
                  fontSize: 18 + random.nextDouble() * 12,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
