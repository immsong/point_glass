import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:point_glass/src/models/grid_config.dart';
import 'package:point_glass/src/utils/transform_3d.dart';

class GridPainter extends CustomPainter {
  final GridConfig config;
  final Transform3D transform;

  const GridPainter({required this.config, required this.transform});

  @override
  void paint(Canvas canvas, Size size) {
    if (!config.enabled) return;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    _drawGrid(canvas, size);
    if (config.showAxis) {
      _drawAxis(canvas, size);
    }
    if (config.showAxisLabels) {
      _drawAxisLabels(canvas);
    }

    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size) {
    // 직교 그리드
    for (double pos = -config.size; pos <= config.size; pos += config.step) {
      final segments = (config.size / config.step).ceil();
      final points = <Offset>[];
      final validSegments = <bool>[]; // 각 선분의 유효성 저장

      // 수직선 (X = pos인 선)
      for (var i = 0; i <= segments; i++) {
        final t = i / segments;
        final y = -config.size + (2 * config.size * t);

        final transformed = _transformPoint(pos, y, 0);
        points.add(
          Offset(
            transformed.$1 * transform.scale,
            transformed.$2 * transform.scale,
          ),
        );
        validSegments.add(
          transformed.$3 < transform.perspective,
        ); // perspective로 비교
      }

      // 선 그리기
      for (var i = 0; i < points.length - 1; i++) {
        if (validSegments[i] && validSegments[i + 1]) {
          canvas.drawLine(points[i], points[i + 1], config.linePaint);
        }
      }

      points.clear();
      validSegments.clear();

      // 수평선 (Y = pos인 선)
      for (var i = 0; i <= segments; i++) {
        final t = i / segments;
        final x = -config.size + (2 * config.size * t);

        final transformed = _transformPoint(x, pos, 0);
        points.add(
          Offset(
            transformed.$1 * transform.scale,
            transformed.$2 * transform.scale,
          ),
        );
        validSegments.add(
          transformed.$3 < transform.perspective,
        ); // perspective로 비교
      }

      // 선 그리기
      for (var i = 0; i < points.length - 1; i++) {
        if (validSegments[i] && validSegments[i + 1]) {
          canvas.drawLine(points[i], points[i + 1], config.linePaint);
        }
      }
    }

    // 원형 그리드는 그대로 유지
    for (
      double radius = config.step;
      radius <= config.size;
      radius += config.step
    ) {
      final points = <Offset>[];
      final segments = 72;

      for (var i = 0; i <= segments; i++) {
        final angle = (2 * pi * i) / segments;
        final x = radius * cos(angle);
        final y = radius * sin(angle);

        final transformed = _transformPoint(x, y, 0);
        points.add(
          Offset(
            transformed.$1 * transform.scale,
            transformed.$2 * transform.scale,
          ),
        );
      }

      for (var i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], config.linePaint);
      }
    }
  }

  void _drawAxis(Canvas canvas, Size size) {
    // X축 (빨간색)
    final xStart = _transformPoint(0, 0, 0);
    final xEnd = _transformPoint(0.2, 0, 0);
    canvas.drawLine(
      Offset(xStart.$1 * transform.scale, xStart.$2 * transform.scale),
      Offset(xEnd.$1 * transform.scale, xEnd.$2 * transform.scale),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 2.0,
    );

    // Y축 (초록색)
    final yStart = _transformPoint(0, 0, 0);
    final yEnd = _transformPoint(0, 0.2, 0);
    canvas.drawLine(
      Offset(yStart.$1 * transform.scale, yStart.$2 * transform.scale),
      Offset(yEnd.$1 * transform.scale, yEnd.$2 * transform.scale),
      Paint()
        ..color = Colors.green
        ..strokeWidth = 2.0,
    );

    // Z축 (파란색)
    final zStart = _transformPoint(0, 0, 0);
    final zEnd = _transformPoint(0, 0, 0.2);
    canvas.drawLine(
      Offset(zStart.$1 * transform.scale, zStart.$2 * transform.scale),
      Offset(zEnd.$1 * transform.scale, zEnd.$2 * transform.scale),
      Paint()
        ..color = Colors.blue
        ..strokeWidth = 2.0,
    );
  }

  void _drawAxisLabels(Canvas canvas) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (var i = 1; i <= config.size; i++) {
      final value = i * config.step;

      // Y축 레이블
      final yPos = _transformPoint(0, i * config.step, 0);
      textPainter.text = TextSpan(
        text: value.toString(),
        style: config.labelStyle,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          yPos.$1 * transform.scale - textPainter.width - 10,
          yPos.$2 * transform.scale - textPainter.height / 2,
        ),
      );
    }
  }

  (double, double, double) _transformPoint(double x, double y, double z) {
    return transform.transform(x, y, z);
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.transform != transform || oldDelegate.config != config;
  }
}
