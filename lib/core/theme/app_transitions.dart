import 'dart:ui';
import 'package:flutter/material.dart';

/// Ultra-smooth, spring-driven page transition inspired by Telegram & Netflix
class VaultFadeSlideRoute<T> extends PageRouteBuilder<T> {
  VaultFadeSlideRoute({
    required this.builder,
    super.settings,
    this.offsetBegin = const Offset(0, 0.04),
    super.fullscreenDialog = false,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final entranceCurve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final exitCurve = CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeOutQuad,
            );

            return RepaintBoundary(
              child: FadeTransition(
                opacity: entranceCurve,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: offsetBegin,
                    end: Offset.zero,
                  ).animate(entranceCurve),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 1.0, end: 0.88).animate(exitCurve),
                    child: child,
                  ),
                ),
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 260),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          maintainState: true,
          allowSnapshotting: true,
        );

  final WidgetBuilder builder;
  final Offset offsetBegin;
}

/// Smooth scaling modal route for dialogs & detail overlays (Telegram/Spotify style)
class VaultScaleModalRoute<T> extends PageRouteBuilder<T> {
  VaultScaleModalRoute({
    required this.builder,
    super.settings,
  }) : super(
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black.withValues(alpha: 0.55),
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
              reverseCurve: Curves.easeInCubic,
            );
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5 * animation.value,
                sigmaY: 5 * animation.value,
              ),
              child: RepaintBoundary(
                child: FadeTransition(
                  opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.90, end: 1.0).animate(curved),
                    child: child,
                  ),
                ),
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          maintainState: true,
        );

  final WidgetBuilder builder;
}

/// Global PageTransitionsBuilder for ThemeData
class VaultPageTransitionsBuilder extends PageTransitionsBuilder {
  const VaultPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInQuad,
    );

    return RepaintBoundary(
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      ),
    );
  }
}

/// Tactile bouncy tap micro-interaction wrapper (Telegram / Spotify tactile feel)
class BouncyTapWrapper extends StatefulWidget {
  const BouncyTapWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.95,
    this.duration = const Duration(milliseconds: 140),
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final Duration duration;

  @override
  State<BouncyTapWrapper> createState() => _BouncyTapWrapperState();
}

class _BouncyTapWrapperState extends State<BouncyTapWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap != null) _controller.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
