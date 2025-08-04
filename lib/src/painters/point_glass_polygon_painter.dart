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

      if (polygon.selectedPolygon) {
        for (var i = 0; i < polygon.points.length - 1; i++) {
          final point1 = transform.transform(
            polygon.points[i].x,
            polygon.points[i].y,
            polygon.points[i].z,
          );
          final point2 = transform.transform(
            polygon.points[i + 1].x,
            polygon.points[i + 1].y,
            polygon.points[i + 1].z,
          );
          canvas.drawLine(
            Offset(point1.$1, point1.$2),
            Offset(point2.$1, point2.$2),
            Paint()
              ..color = polygon.color
              ..strokeWidth = polygon.strokeWidth * 2
              ..style = PaintingStyle.stroke,
          );
        }

        final point1 = transform.transform(
          polygon.points[polygon.points.length - 1].x,
          polygon.points[polygon.points.length - 1].y,
          polygon.points[polygon.points.length - 1].z,
        );
        final point2 = transform.transform(
          polygon.points[0].x,
          polygon.points[0].y,
          polygon.points[0].z,
        );
        canvas.drawLine(
          Offset(point1.$1, point1.$2),
          Offset(point2.$1, point2.$2),
          Paint()
            ..color = polygon.color
            ..strokeWidth = polygon.strokeWidth * 2
            ..style = PaintingStyle.stroke,
        );
      } else {
        polygon.hoveredVertexIndex = -1;
        polygon.selectedVertexIndex = -1;
      }

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
          polygon.pointSize * (polygon.hoveredVertexIndex == i ? 2 : 1),
          Paint()
            ..color = polygon.pointColor
            ..strokeWidth = polygon.pointSize
            ..style = PaintingStyle.fill,
        );
      }
    }
  }
}
