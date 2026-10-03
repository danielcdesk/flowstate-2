import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flowstate/design/tokens.dart';

class FlowRing extends StatelessWidget {
  const FlowRing({
    required this.progress,
    required this.semanticLabel,
    super.key,
    this.centerLabel,
    this.size = FlowTokens.radarSize,
  });

  final double progress;
  final String semanticLabel;
  final String? centerLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final double clampedProgress = progress.clamp(0, 1).toDouble();
    final String? label = centerLabel;
    return Semantics(
      label: semanticLabel,
      value: '${(clampedProgress * 100).round()}%',
      child: ExcludeSemantics(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _FlowRingPainter(
              progress: clampedProgress,
              trackColor: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.14),
              progressColor: Theme.of(context).colorScheme.primary,
            ),
            child: label == null
                ? null
                : Center(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _FlowRingPainter extends CustomPainter {
  const _FlowRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    final double inset = size.shortestSide * 0.12;
    final Rect ring = bounds.deflate(inset);
    final Paint track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * 0.08;
    final Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * 0.08;
    canvas.drawArc(ring, -math.pi / 2, math.pi * 1.75, false, track);
    canvas.drawArc(
      ring,
      -math.pi / 2,
      math.pi * 1.75 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_FlowRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
