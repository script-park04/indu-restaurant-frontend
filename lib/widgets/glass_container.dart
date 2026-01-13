import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A reusable frosted glass container that applies a blur, subtle gradient
/// and rounded border to achieve a liquid-glass look.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Border? border;
  final double? width;
  final double? height;
  final bool useBlur;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.blur = 12,
    this.color,
    this.border,
    this.width,
    this.height,
    this.useBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (color ?? AppTheme.glassCard).withValues(alpha: 0.55),
            (color ?? AppTheme.glassCard).withValues(alpha: 0.28),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(color: Colors.white.withValues(alpha: 0.14), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: AppTheme.textPrimary),
        child: child,
      ),
    );

    if (useBlur) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    } else {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return RepaintBoundary(child: content);
  }
}
