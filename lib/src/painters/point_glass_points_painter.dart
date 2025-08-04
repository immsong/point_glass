import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_points.dart';
import 'package:point_glass/src/utils/transform_3d.dart';

class PointGlassPointsPainter {
  final Transform3D transform;
  final List<PointGlassPoints> pointsGroup;

  PointGlassPointsPainter({required this.transform, required this.pointsGroup});

  void draw(Canvas canvas, Size size) {
    for (var points in pointsGroup) {
      if (!points.enable) {
        continue;
      }

      for (var point in points.points) {
        final pointPaint = Paint()
          ..color = point.color.withAlpha(point.alpha)
          ..style = PaintingStyle.fill;

        final transformed = transform.transform(
          point.point.x,
          point.point.y,
          point.point.z,
        );

        canvas.drawCircle(
          Offset(transformed.$1, transformed.$2),
          point.strokeWidth,
          pointPaint,
        );
      }
    }
  }
}
