import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_transitions.dart';

class MilestoneRewardDialog extends StatefulWidget {
  const MilestoneRewardDialog({
    super.key,
    required this.title,
    required this.description,
    required this.xpEarned,
    this.badgeName = 'Guardian Trophy',
    this.onDismiss,
  });

  final String title;
  final String description;
  final int xpEarned;
  final String badgeName;
  final VoidCallback? onDismiss;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    required int xpEarned,
    String badgeName = 'Guardian Trophy',
    VoidCallback? onDismiss,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => MilestoneRewardDialog(
        title: title,
        description: description,
        xpEarned: xpEarned,
        badgeName: badgeName,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  State<MilestoneRewardDialog> createState() => _MilestoneRewardDialogState();
}

class _MilestoneRewardDialogState extends State<MilestoneRewardDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B26) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB800).withValues(alpha: 0.25),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
              const BoxShadow(
                color: Colors.black38,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Golden Trophy Badge matching Image 1
              _buildGoldenTrophyArtwork(),

              const SizedBox(height: 20),

              // Celebratory XP Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8C00).withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '+${widget.xpEarned} XP AWARDED',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.ink,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 24),

              // Claim & Continue Button
              SizedBox(
                width: double.infinity,
                child: BouncyTapWrapper(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    widget.onDismiss?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C853), Color(0xFF00B0FF)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00C853).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Claim Milestone Reward',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Custom vector-rendered Golden Trophy on Dark Circular Background (Exact match for Image 1)
  Widget _buildGoldenTrophyArtwork() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Dark Navy Circular Orb (Image 1 backdrop)
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(0.0, -0.2),
                  radius: 0.85,
                  colors: [
                    Color(0xFF1E3A8A), // Vibrant blue interior
                    Color(0xFF0B1329), // Deep dark navy rim
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.5),
                    blurRadius: 20 * _glowAnimation.value,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // Subtle base cast shadow under cup
            Positioned(
              bottom: 22,
              child: Container(
                width: 70,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Golden Trophy Graphic
            CustomPaint(
              size: const Size(100, 100),
              painter: _GoldenTrophyPainter(),
            ),
          ],
        );
      },
    );
  }
}

/// Custom Canvas Painter rendering the Golden Trophy with Star (Image 1 style)
class _GoldenTrophyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Golden Trophy Cup Body
    final cupPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFEA79), // Bright yellow gold highlight
          Color(0xFFFFC107), // Amber gold
          Color(0xFFFF9800), // Deep warm gold shadow
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final cupRimPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;

    // Cup Rim
    final rimRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, 22), width: 56, height: 10),
      const Radius.circular(5),
    );
    canvas.drawRRect(rimRect, cupRimPaint);

    // Cup Body Shape
    final cupPath = Path();
    cupPath.moveTo(center.dx - 26, 24);
    cupPath.lineTo(center.dx + 26, 24);
    cupPath.quadraticBezierTo(center.dx + 26, 52, center.dx + 12, 60);
    cupPath.lineTo(center.dx - 12, 60);
    cupPath.quadraticBezierTo(center.dx - 26, 52, center.dx - 26, 24);
    cupPath.close();
    canvas.drawPath(cupPath, cupPaint);

    // Cup Handles (Left & Right)
    final handlePaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;

    final leftHandle = Path()
      ..moveTo(center.dx - 25, 28)
      ..cubicTo(center.dx - 44, 28, center.dx - 44, 48, center.dx - 18, 52);
    canvas.drawPath(leftHandle, handlePaint);

    final rightHandle = Path()
      ..moveTo(center.dx + 25, 28)
      ..cubicTo(center.dx + 44, 28, center.dx + 44, 48, center.dx + 18, 52);
    canvas.drawPath(rightHandle, handlePaint);

    // Trophy Stem
    final stemPaint = Paint()..color = const Color(0xFFFFA000);
    final stemRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, 65), width: 14, height: 12),
      const Radius.circular(3),
    );
    canvas.drawRRect(stemRect, stemPaint);

    // Trophy Base Tier 1
    final baseTopRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, 72), width: 28, height: 6),
      const Radius.circular(3),
    );
    canvas.drawRRect(baseTopRect, stemPaint);

    // Trophy Base Tier 2 (Bottom Pedestal)
    final baseBottomRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, 82), width: 44, height: 14),
      const Radius.circular(5),
    );
    final basePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
      ).createShader(Rect.fromLTWH(0, 70, size.width, 20));
    canvas.drawRRect(baseBottomRect, basePaint);

    // Base Accent Line
    final baseAccentPaint = Paint()
      ..color = const Color(0xFFFF6F00)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - 12, 82),
      Offset(center.dx + 12, 82),
      baseAccentPaint,
    );

    // 2. Shining Center Star on Cup (Image 1 star)
    _drawStar(canvas, Offset(center.dx, 40), 5, 9.0, 4.2);
  }

  void _drawStar(Canvas canvas, Offset center, int points, double outerRadius, double innerRadius) {
    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final step = math.pi / points;
    double angle = -math.pi / 2;

    for (int i = 0; i < points * 2; i++) {
      final r = (i % 2 == 0) ? outerRadius : innerRadius;
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      angle += step;
    }
    path.close();
    canvas.drawPath(path, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
