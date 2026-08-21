import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AppBrandIcon extends StatelessWidget {
  const AppBrandIcon({
    super.key,
    this.size = 38,
    this.borderRadius = 12,
    this.color,
    this.gradient,
  });

  final double size;
  final double borderRadius;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final themeExt = AppTheme.of(context);
    final effectiveAccent = color ?? themeExt.primaryAccent;
    final effectiveGradient = gradient ?? (color == null ? themeExt.accentGradient : null);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: effectiveGradient,
        color: effectiveGradient == null ? effectiveAccent : null,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: effectiveAccent.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/images/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.shield_outlined,
                color: AppColors.ink,
                size: size * 0.58,
              ),
            );
          },
        ),
      ),
    );
  }
}
