import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_brand_icon.dart';

/// Ultra-premium cyber-security animated Splash Screen for LifeVault AI v2.1.4
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _pulseGlowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.75, curve: Curves.easeIn),
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.12, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    _pulseGlowAnimation = Tween<double>(begin: 0.8, end: 1.25).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Trigger completion
    Future.delayed(const Duration(milliseconds: 2700), () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getStatusText(double progress) {
    if (progress < 0.28) {
      return 'INITIALIZING SECURE ENCLAVE...';
    } else if (progress < 0.58) {
      return 'ARMING AES-256 ZERO-KNOWLEDGE...';
    } else if (progress < 0.88) {
      return 'LOADING NEURAL AI & OCR MODELS...';
    } else {
      return 'BIOMETRIC ENCLAVE READY';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeExt = AppTheme.of(context);
    final accent = themeExt.primaryAccent;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.ink,
      body: Stack(
        children: [
          // Background ambient cyber grid & glow
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _CyberSplashBackgroundPainter(
                    accentColor: accent,
                    progress: _controller.value,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),

          // Central content
          SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final progress = _controller.value;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // Animated Shield Emblem with Multi-ring Glowing Orbit
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.rotate(
                          angle: _rotationAnimation.value * math.pi,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer expanding pulse aura
                              Container(
                                width: 170 * _pulseGlowAnimation.value,
                                height: 170 * _pulseGlowAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      accent.withValues(alpha: 0.30),
                                      accent.withValues(alpha: 0.08),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),

                              // Rotating decorative cyber rings
                              Transform.rotate(
                                angle: progress * math.pi * 2,
                                child: Container(
                                  width: 136,
                                  height: 136,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: accent.withValues(alpha: 0.35),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),

                              // Inner App Icon Container
                              const AppBrandIcon(size: 92, borderRadius: 28),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Title & AI Subtitle
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'lifevault',
                                  style: TextStyle(
                                    color: AppColors.canvas,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.2,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        accent,
                                        accent.withValues(alpha: 0.75),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withValues(alpha: 0.4),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'AI',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.35),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'AI-POWERED PRIVACY VAULT',
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 52),

                      // Animated Progress Bar & Dynamic Security Status
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 180,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: _controller.value,
                                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _getStatusText(progress),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Footer Version Badge
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shield_rounded,
                                size: 13,
                                color: accent.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'v2.1.4 • Zero-Knowledge Local Enclave',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Tap to Skip button in top right
          Positioned(
            top: 48,
            right: 20,
            child: TextButton(
              onPressed: widget.onFinished,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text(
                'SKIP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CyberSplashBackgroundPainter extends CustomPainter {
  _CyberSplashBackgroundPainter({
    required this.accentColor,
    required this.progress,
    required this.isDark,
  });

  final Color accentColor;
  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Radial gradient glow behind emblem
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withValues(alpha: 0.15 * progress),
          accentColor.withValues(alpha: 0.03 * progress),
          Colors.transparent,
        ],
        radius: 0.75,
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.8));

    canvas.drawCircle(center, size.width * 0.8, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _CyberSplashBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor;
  }
}
