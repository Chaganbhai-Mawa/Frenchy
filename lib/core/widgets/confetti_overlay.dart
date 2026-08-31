import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lightweight confetti burst drawn with a CustomPainter — no external
/// dependency. Plays once for ~1.6s then removes itself visually.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key, this.pieceCount = 60});

  final int pieceCount;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  late final List<_Piece> _pieces;

  static const _colors = [
    Color(0xFF23408F),
    Color(0xFFE85D5D),
    Color(0xFFF2B24C),
    Color(0xFF3B9E64),
    Color(0xFF6A4FB6),
    Color(0xFF3A9EA5),
  ];

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _pieces = List.generate(widget.pieceCount, (i) {
      return _Piece(
        x: random.nextDouble(),
        speed: 0.5 + random.nextDouble() * 0.9,
        drift: (random.nextDouble() - 0.5) * 0.4,
        size: 5 + random.nextDouble() * 6,
        color: _colors[i % _colors.length],
        rotation: random.nextDouble() * math.pi * 2,
        spin: (random.nextDouble() - 0.5) * 10,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => _controller.isCompleted
            ? const SizedBox.shrink()
            : CustomPaint(
                size: Size.infinite,
                painter: _ConfettiPainter(
                  pieces: _pieces,
                  progress: _controller.value,
                ),
              ),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.speed,
    required this.drift,
    required this.size,
    required this.color,
    required this.rotation,
    required this.spin,
  });

  final double x;
  final double speed;
  final double drift;
  final double size;
  final Color color;
  final double rotation;
  final double spin;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.pieces, required this.progress});

  final List<_Piece> pieces;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final piece in pieces) {
      final y = (piece.speed * progress * 1.3 - 0.1) * size.height;
      if (y > size.height) continue;
      final x = (piece.x + piece.drift * progress) * size.width;
      final opacity = progress > 0.7 ? (1 - progress) / 0.3 : 1.0;
      paint.color = piece.color.withValues(alpha: opacity.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(piece.rotation + piece.spin * progress);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 0.6,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
