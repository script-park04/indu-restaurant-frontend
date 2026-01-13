import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LiquidButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double borderRadius;

  const LiquidButton(
      {super.key,
      required this.onPressed,
      required this.child,
      this.borderRadius = 14});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppTheme.primaryRed,
                  AppTheme.primaryRed.withValues(alpha: 0.85)
                ]),
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: DefaultTextStyle.merge(
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
