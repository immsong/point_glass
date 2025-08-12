import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_points.dart';
import 'package:point_glass/src/utils/view_context.dart';

class PointGlassPointsPainter {
  final ViewContext viewContext;
  final List<PointGlassPoints> pointsGroup;

  PointGlassPointsPainter({
    required this.viewContext,
    required this.pointsGroup,
  });

  void draw(Canvas canvas, Size size) {
    for (var points in pointsGroup) {
      if (!points.enable) {
        continue;
      }

      for (var point in points.points) {
        final pointPaint = Paint()
          ..color = point.color.withAlpha(point.alpha)
          ..style = PaintingStyle.fill;

        final transformed = viewContext.projectModel(
          point.point.x,
          point.point.y,
          point.point.z,
        );

        if (transformed.p == null) {
          continue;
        }

        canvas.drawCircle(
          transformed.p!,
          point.strokeWidth,
          pointPaint,
        );
      }
    }
  }
}
