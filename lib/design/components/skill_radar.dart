import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:flowstate/design/tokens.dart';

class SkillRadarMetric {
  const SkillRadarMetric({required this.label, required this.value});

  final String label;
  final double value;

  double get normalizedValue => value.clamp(0, 100).toDouble();
}

class SkillRadar extends StatelessWidget {
  const SkillRadar({
    required this.title,
    required this.metrics,
    super.key,
    this.size = FlowTokens.radarSize,
  });

  final String title;
  final List<SkillRadarMetric> metrics;
  final double size;

  @override
  Widget build(BuildContext context) {
    assert(metrics.length >= 3);
    final Color accent = Theme.of(context).colorScheme.primary;
    final String summary = metrics
        .map((SkillRadarMetric metric) {
          return '${metric.label}: ${metric.normalizedValue.round()}%';
        })
        .join(', ');

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: title,
      value: summary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ExcludeSemantics(
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _SkillRadarPainter(
                  metrics: metrics,
                  accent: accent,
                  gridColor: Theme.of(context).colorScheme.onSurface
                      .withValues(alpha: 0.22),
                ),
              ),
            ),
          ),
          const SizedBox(height: FlowTokens.space4),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: FlowTokens.space3,
            runSpacing: FlowTokens.space2,
            children: metrics.map((SkillRadarMetric metric) {
              final String value = '${metric.normalizedValue.round()}%';
              return Semantics(
                label: '${metric.label}: $value',
                child: Chip(
                  label: Text('${metric.label} $value'),
                  padding: EdgeInsets.zero,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SkillRadarPainter extends CustomPainter {
  const _SkillRadarPainter({
    required this.metrics,
    required this.accent,
    required this.gridColor,
  });

  final List<SkillRadarMetric> metrics;
  final Color accent;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) * 0.38;
    final double step = (math.pi * 2) / metrics.length;

    for (int level = 1; level <= 4; level++) {
      final Path grid = _polygon(center, radius * level / 4, step, 0);
      canvas.drawPath(
        grid,
        Paint()
          ..color = gridColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    for (int index = 0; index < metrics.length; index++) {
      final Offset end = _point(center, radius, step, index);
      canvas.drawLine(
        center,
        end,
        Paint()
          ..color = gridColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    final Path values = Path();
    for (int index = 0; index < metrics.length; index++) {
      final Offset point = _point(
        center,
        radius * metrics[index].normalizedValue / 100,
        step,
        index,
      );
      if (index == 0) {
        values.moveTo(point.dx, point.dy);
      } else {
        values.lineTo(point.dx, point.dy);
      }
    }
    values.close();
    canvas.drawPath(
      values,
      Paint()
        ..color = accent.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      values,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  Path _polygon(Offset center, double radius, double step, int start) {
    final Path path = Path();
    for (int index = 0; index < metrics.length; index++) {
      final Offset point = _point(center, radius, step, index + start);
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  Offset _point(Offset center, double radius, double step, int index) {
    final double angle = -math.pi / 2 + step * index;
    return Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
  }

  @override
  bool shouldRepaint(_SkillRadarPainter oldDelegate) {
    return oldDelegate.metrics != metrics ||
        oldDelegate.accent != accent ||
        oldDelegate.gridColor != gridColor;
  }
}
