import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A dynamic background with animated, blurred, colorful blobs and a soft
/// gradient to give the whole app a liquid glass feel.
class LiquidBackground extends StatefulWidget {
  final Widget child;

  const LiquidBackground({super.key, required this.child});

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration:
              const BoxDecoration(gradient: AppTheme.backgroundGradient),
        ),
        // Animated blurred blobs using CustomPainter for performance
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _BlobPainter(
                  animation: _controller.value,
                  blobs: [
                    _BlobData(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                      size: 400,
                      basePosition: const Offset(-100, -80),
                      radius: 50,
                      speed: 1.0,
                    ),
                    _BlobData(
                      color: AppTheme.accentPink.withValues(alpha: 0.1),
                      size: 450,
                      basePosition: const Offset(200, 300),
                      radius: 70,
                      speed: 0.8,
                      offset: math.pi,
                    ),
                    _BlobData(
                      color: AppTheme.accentTeal.withValues(alpha: 0.08),
                      size: 300,
                      basePosition: const Offset(250, -50),
                      radius: 40,
                      speed: 1.2,
                      offset: math.pi / 2,
                    ),
                    _BlobData(
                      color: AppTheme.secondaryPurple.withValues(alpha: 0.06),
                      size: 350,
                      basePosition: const Offset(-50, 450),
                      radius: 60,
                      speed: 0.9,
                      offset: 3 * math.pi / 2,
                    ),
                  ],
                ),
                size: Size.infinite,
              );
            },
          ),
        ),
        // Frost overlay - Reduced blur for performance
        BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: const SizedBox.expand()),
        // App content
        widget.child,
      ],
    );
  }
}

class _BlobData {
  final Color color;
  final double size;
  final Offset basePosition;
  final double radius;
  final double speed;
  final double offset;

  _BlobData({
    required this.color,
    required this.size,
    required this.basePosition,
    this.radius = 50,
    this.speed = 1.0,
    this.offset = 0,
  });
}

class _BlobPainter extends CustomPainter {
  final double animation;
  final List<_BlobData> blobs;

  _BlobPainter({required this.animation, required this.blobs});

  @override
  void paint(Canvas canvas, Size size) {
    for (final blob in blobs) {
      final t = animation * 2 * math.pi * blob.speed + blob.offset;
      final dx = blob.basePosition.dx + math.cos(t) * blob.radius;
      final dy = blob.basePosition.dy + math.sin(t) * blob.radius;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [blob.color, blob.color.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(dx, dy, blob.size, blob.size));

      canvas.drawCircle(
        Offset(dx + blob.size / 2, dy + blob.size / 2),
        blob.size / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
