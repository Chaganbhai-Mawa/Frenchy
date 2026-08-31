import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';

/// The app's standard soft rounded card with optional tap handling and a
/// gentle press-scale micro-interaction.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = widget.borderRadius ?? AppRadius.medium;

    Widget card = AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: AppAnimations.fast,
      child: Container(
        decoration: BoxDecoration(
          color: widget.color ?? theme.colorScheme.surface,
          borderRadius: radius,
          boxShadow: AppShadows.card(theme.brightness),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: widget.onTap,
            onHighlightChanged: widget.onTap == null
                ? null
                : (value) => setState(() => _pressed = value),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
    return card;
  }
}
