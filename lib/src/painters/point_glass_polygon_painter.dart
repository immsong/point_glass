import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_polygon.dart';
import 'package:point_glass/src/utils/transform_3d.dart';

class PointGlassPolygonPainter {
  final Transform3D transform;
  final List<PointGlassPolygon> polygons;

  PointGlassPolygonPainter({required this.transform, required this.polygons});

  void draw(Canvas canvas, Size size) {
    for (var polygon in polygons) {
      if (!polygon.enable) {
        continue;
      }

      if (polygon.points.length < 3) {
        continue;
      }

      final planePaint = Paint()
        ..color = polygon.color.withAlpha(polygon.alpha)
        ..strokeWidth = polygon.strokeWidth
        ..style = PaintingStyle.fill;

      final path = Path();

      final first = transform.transform(
        polygon.points.first.x,
        polygon.points.first.y,
        polygon.points.first.z,
      );

      path.moveTo(first.$1, first.$2);
      for (var i = 1; i < polygon.points.length; i++) {
        final point = transform.transform(
          polygon.points[i].x,
          polygon.points[i].y,
          polygon.points[i].z,
        );
        path.lineTo(point.$1, point.$2);
      }

      path.close();

      canvas.drawPath(path, planePaint);

      if (polygon.pointSize <= 0.0) {
        continue;
      }

      for (var i = 0; i < polygon.points.length; i++) {
        final point = transform.transform(
          polygon.points[i].x,
          polygon.points[i].y,
          polygon.points[i].z,
        );

        canvas.drawCircle(
          Offset(point.$1, point.$2),
          polygon.pointSize,
          Paint()
            ..color = polygon.pointColor
            ..strokeWidth = polygon.pointSize
            ..style = PaintingStyle.fill,
        );
      }
    }
  }
}
