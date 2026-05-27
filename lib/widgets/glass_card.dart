import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../config/theme.dart';

/// 부드러운 카드 표면. 얇은 hairline + 은은한 그림자로 깊이감.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final bool elevated;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 22,
    this.blur = 6,
    this.backgroundColor,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    final inner = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: backgroundColor ?? AppConstants.bgCard.withOpacity(0.78),
            border: Border.all(
              color: AppConstants.border,
              width: 0.6,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (!elevated) return inner;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: softShadow(),
      ),
      child: inner,
    );
  }
}
