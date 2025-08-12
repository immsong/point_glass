import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_polygon.dart';
import 'package:point_glass/src/utils/view_context.dart';

class PointGlassPolygonPainter {
  final ViewContext viewContext;
  final List<PointGlassPolygon> polygons;

  PointGlassPolygonPainter({required this.viewContext, required this.polygons});

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

      final first = viewContext.projectModel(
        polygon.points.first.x,
        polygon.points.first.y,
        polygon.points.first.z,
      );

      if (first.p == null) {
        continue;
      }

      path.moveTo(first.p!.dx, first.p!.dy);
      for (var i = 1; i < polygon.points.length; i++) {
        final point = viewContext.projectModel(
          polygon.points[i].x,
          polygon.points[i].y,
          polygon.points[i].z,
        );

        if (point.p == null) {
          continue;
        }

        path.lineTo(point.p!.dx, point.p!.dy);
      }

      path.close();

      canvas.drawPath(path, planePaint);

      if (polygon.selectedPolygon) {
        for (var i = 0; i < polygon.points.length - 1; i++) {
          final point1 = viewContext.projectModel(
            polygon.points[i].x,
            polygon.points[i].y,
            polygon.points[i].z,
          );
          final point2 = viewContext.projectModel(
            polygon.points[i + 1].x,
            polygon.points[i + 1].y,
            polygon.points[i + 1].z,
          );

          if (point1.p == null || point2.p == null) {
            continue;
          }

          canvas.drawLine(
            point1.p!,
            point2.p!,
            Paint()
              ..color = polygon.color
              ..strokeWidth = polygon.strokeWidth * 2
              ..style = PaintingStyle.stroke,
          );
        }

        final point1 = viewContext.projectModel(
          polygon.points[polygon.points.length - 1].x,
          polygon.points[polygon.points.length - 1].y,
          polygon.points[polygon.points.length - 1].z,
        );

        if (point1.p == null) {
          continue;
        }

        final point2 = viewContext.projectModel(
          polygon.points[0].x,
          polygon.points[0].y,
          polygon.points[0].z,
        );

        if (point1.p == null || point2.p == null) {
          continue;
        }

        canvas.drawLine(
          point1.p!,
          point2.p!,
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
        final point = viewContext.projectModel(
          polygon.points[i].x,
          polygon.points[i].y,
          polygon.points[i].z,
        );

        if (point.p == null) {
          continue;
        }

        canvas.drawCircle(
          point.p!,
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
