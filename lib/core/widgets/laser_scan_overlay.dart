import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LaserScanOverlay extends StatefulWidget {
  const LaserScanOverlay({
    super.key,
    required this.isScanning,
    this.lineColor,
  });

  final bool isScanning;
  final Color? lineColor;

  @override
  State<LaserScanOverlay> createState() => _LaserScanOverlayState();
}

class _LaserScanOverlayState extends State<LaserScanOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.isScanning) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant LaserScanOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _controller.repeat(reverse: true);
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.lineColor ?? AppTheme.of(context).primaryAccent;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Target Reticle Corners
            Positioned(
              top: 20,
              left: 20,
              child: _CornerMarker(
                color: effectiveColor,
                alignment: Alignment.topLeft,
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: _CornerMarker(
                color: effectiveColor,
                alignment: Alignment.topRight,
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: _CornerMarker(
                color: effectiveColor,
                alignment: Alignment.bottomLeft,
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: _CornerMarker(
                color: effectiveColor,
                alignment: Alignment.bottomRight,
              ),
            ),

            // Animated Laser Line
            if (widget.isScanning)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final topOffset =
                      24.0 + (constraints.maxHeight - 48.0) * _controller.value;
                  return Positioned(
                    top: topOffset,
                    left: 24,
                    right: 24,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            effectiveColor.withValues(alpha: 0.1),
                            effectiveColor,
                            effectiveColor.withValues(alpha: 0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: effectiveColor.withValues(alpha: 0.7),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _CornerMarker extends StatelessWidget {
  const _CornerMarker({required this.color, required this.alignment});
  final Color color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    const size = 28.0;
    const thickness = 3.5;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          color: color,
          alignment: alignment,
          thickness: thickness,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({
    required this.color,
    required this.alignment,
    required this.thickness,
  });

  final Color color;
  final Alignment alignment;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (alignment == Alignment.topLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (alignment == Alignment.topRight) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (alignment == Alignment.bottomLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else if (alignment == Alignment.bottomRight) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.alignment != alignment ||
      oldDelegate.thickness != thickness;
}
