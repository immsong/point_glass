import 'dart:math';

import 'package:flutter/material.dart';
import 'package:point_glass/src/models/point_glass_grid.dart';

import 'package:vector_math/vector_math.dart' as vm;

import 'package:point_glass/src/utils/transform_3d.dart';

class PointGlassPainter extends CustomPainter {
  final Transform3D transform;
  final PointGlassGrid grid;

  const PointGlassPainter({required this.transform, required this.grid});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(
      (size.width / 2) + transform.positionX,
      (size.height / 2) + transform.positionY,
    );

    if (grid.enable) {
      _drawGrid(canvas, size);
    }

    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridLinePaint = Paint()
      ..color = grid.color.withAlpha(grid.alpha)
      ..strokeWidth = grid.strokeWidth;

    // 직선(사각) 그리드
    for (
      double pos = -grid.gridSize;
      pos <= grid.gridSize;
      pos += grid.gridStep
    ) {
      // grid 개수만큼 선을 나눠서 그리기
      // 밑에서 Z-Fighting 방지를 위해 그리지 않는 부분이 있어 나눠서 그려야 함
      final segments = (grid.gridSize / grid.gridStep).ceil();
      final points = <Offset>[];
      final validSegments = <bool>[];

      // 수직선 (X = pos인 선)
      for (var i = 0; i <= segments; i++) {
        final t = i / segments;
        final y = -grid.gridSize + (2 * grid.gridSize * t);

        final transformed = transform.transform(pos, y, 0);
        points.add(
          Offset(
            transformed.$1 * transform.scale,
            transformed.$2 * transform.scale,
          ),
        );

        // Z 값이 perspective 보다 큰 경우 접히는 것 처럼 보여 그리지 않도록 설정 (Z Fighting 방지)
        validSegments.add(transformed.$3 < transform.perspective);
      }

      // 선 그리기
      for (var i = 0; i < points.length - 1; i++) {
        if (validSegments[i] && validSegments[i + 1]) {
          canvas.drawLine(points[i], points[i + 1], gridLinePaint);
        }
      }

      points.clear();
      validSegments.clear();

      // 수평선 (Y = pos인 선)
      for (var i = 0; i <= segments; i++) {
        final t = i / segments;
        final x = -grid.gridSize + (2 * grid.gridSize * t);

        final transformed = transform.transform(x, pos, 0);
        points.add(
          Offset(
            transformed.$1 * transform.scale,
            transformed.$2 * transform.scale,
          ),
        );

        // Z 값이 perspective 보다 큰 경우 접히는 것 처럼 보여 그리지 않도록 설정 (Z Fighting 방지)
        validSegments.add(transformed.$3 < transform.perspective);
      }

      // 선 그리기
      for (var i = 0; i < points.length - 1; i++) {
        if (validSegments[i] && validSegments[i + 1]) {
          canvas.drawLine(points[i], points[i + 1], gridLinePaint);
        }
      }
    }

    // 원형 그리드
    for (
      double radius = grid.gridStep;
      radius <= grid.gridSize;
      radius += grid.gridStep
    ) {
      final points = <Offset>[];

      // 5도 간격으로 선을 그려 원처럼 보이도록
      for (var i = 0; i <= 360; i += 5) {
        final angle = vm.radians(i.toDouble());
        final x = radius * cos(angle);
        final y = radius * sin(angle);

        final transformed = transform.transform(x, y, 0);
        points.add(
          Offset(
            transformed.$1 * transform.scale,
            transformed.$2 * transform.scale,
          ),
        );
      }

      for (var i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], gridLinePaint);
      }
    }

    if (grid.enableLabel) {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      // y축 레이블
      for (var i = 1; i <= grid.gridSize; i++) {
        final value = i * grid.gridStep;

        final yPos = transform.transform(0, value, 0);
        textPainter.text = TextSpan(
          text: value.toString(),
          style: grid.labelStyle,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            yPos.$1 * transform.scale - textPainter.width / 2,
            yPos.$2 * transform.scale - textPainter.height / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(PointGlassPainter oldDelegate) {
    return oldDelegate.transform != transform;
  }
}
