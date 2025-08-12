import 'dart:math';
import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_grid.dart';
import 'package:point_glass/src/utils/view_context.dart';

class PointGlassGridPainter {
  final ViewContext viewContext;
  final PointGlassGrid grid;

  PointGlassGridPainter({
    required this.viewContext,
    required this.grid,
  });

  void draw(Canvas canvas, Size size) {
    final gridLinePaint = Paint()
      ..color = grid.color.withAlpha(grid.alpha)
      ..strokeWidth = grid.strokeWidth;

    // 직선(사각) 그리드
    for (double pos = -grid.gridSize;
        pos <= grid.gridSize;
        pos += grid.gridStep) {
      final segments = (grid.gridSize / grid.gridStep).ceil();

      // 수직선 (X = pos)
      {
        final points = <Offset>[];
        final valid = <bool>[];
        for (var i = 0; i <= segments; i++) {
          final t = i / segments;
          final y = -grid.gridSize + (2 * grid.gridSize * t);
          final pr = viewContext.projectModel(pos, y, 0.0);
          points.add(pr.p ?? const Offset(double.nan, double.nan));
          valid.add(viewContext.isVisibleVz(pr.vz));
        }
        for (var i = 0; i < points.length - 1; i++) {
          if (valid[i] &&
              valid[i + 1] &&
              points[i].isFinite &&
              points[i + 1].isFinite) {
            canvas.drawLine(points[i], points[i + 1], gridLinePaint);
          }
        }
      }

      // 수평선 (Y = pos)
      {
        final points = <Offset>[];
        final valid = <bool>[];
        for (var i = 0; i <= segments; i++) {
          final t = i / segments;
          final x = -grid.gridSize + (2 * grid.gridSize * t);
          final pr = viewContext.projectModel(x, pos, 0.0);
          points.add(pr.p ?? const Offset(double.nan, double.nan));
          valid.add(viewContext.isVisibleVz(pr.vz));
        }
        for (var i = 0; i < points.length - 1; i++) {
          if (valid[i] &&
              valid[i + 1] &&
              points[i].isFinite &&
              points[i + 1].isFinite) {
            canvas.drawLine(points[i], points[i + 1], gridLinePaint);
          }
        }
      }
    }

    // 원형 그리드
    for (double radius = grid.gridStep;
        radius <= grid.gridSize;
        radius += grid.gridStep) {
      final points = <Offset>[];
      final valid = <bool>[];
      for (var deg = 0; deg <= 360; deg += 5) {
        final a = radians(deg.toDouble());
        final x = radius * cos(a);
        final y = radius * sin(a);
        final pr = viewContext.projectModel(x, y, 0.0);
        points.add(pr.p ?? const Offset(double.nan, double.nan));
        valid.add(viewContext.isVisibleVz(pr.vz));
      }
      for (var i = 0; i < points.length - 1; i++) {
        if (valid[i] &&
            valid[i + 1] &&
            points[i].isFinite &&
            points[i + 1].isFinite) {
          canvas.drawLine(points[i], points[i + 1], gridLinePaint);
        }
      }
    }

    // 레이블
    if (grid.enableLabel) {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      for (var i = grid.gridStep;
          i <= grid.gridSize;
          i += grid.gridStep.toInt()) {
        final pr = viewContext.projectModel(0.0, i.toDouble(), 0.0);
        if (!viewContext.isVisibleVz(pr.vz) || pr.p == null) continue;

        textPainter.text = TextSpan(text: i.toString(), style: grid.labelStyle);
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(pr.p!.dx - textPainter.width / 2,
              pr.p!.dy - textPainter.height / 2),
        );
      }
    }
  }
}
