import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WaveformVisualizer extends StatefulWidget {
  const WaveformVisualizer({
    super.key,
    required this.isRecording,
    this.barColor = AppColors.ink,
    this.barCount = 28,
    this.height = 70,
  });

  final bool isRecording;
  final Color barColor;
  final int barCount;
  final double height;

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    if (widget.isRecording) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _controller.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _controller.stop();
      _controller.value = 0.2;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(widget.barCount, (index) {
              double multiplier = 0.15;
              if (widget.isRecording) {
                final wave = math.sin((index / widget.barCount) * math.pi);
                final noise = _random.nextDouble() * 0.45;
                multiplier = (0.2 + (wave * 0.65) * _controller.value + noise)
                    .clamp(0.12, 1.0);
              }
              final barHeight = widget.height * multiplier;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.2),
                width: 3.5,
                height: barHeight,
                decoration: BoxDecoration(
                  color: widget.barColor.withValues(
                    alpha: widget.isRecording ? 0.9 : 0.35,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
