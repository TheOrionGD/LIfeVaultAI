import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SoftPanel extends StatelessWidget {
  const SoftPanel({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.border,
    this.onTap,
    this.elevation = true,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final BoxBorder? border;
  final VoidCallback? onTap;
  final bool elevation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = color ?? (isDark ? AppColors.darkSurface : AppColors.surface);

    final boxDecoration = BoxDecoration(
      color: effectiveColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ??
          Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.6),
            width: 1,
          ),
      boxShadow: elevation
          ? [
              BoxShadow(
                color: isDark
                    ? AppColors.shadowDark.withValues(alpha: 0.5)
                    : AppColors.shadowLight.withValues(alpha: 0.4),
                offset: const Offset(4, 4),
                blurRadius: 10,
              ),
              if (!isDark)
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(-3, -3),
                  blurRadius: 8,
                ),
            ]
          : null,
    );

    if (onTap != null) {
      return Container(
        decoration: boxDecoration,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: boxDecoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
