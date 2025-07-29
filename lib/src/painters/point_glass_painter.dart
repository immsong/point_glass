import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_axis.dart';
import 'package:point_glass/src/models/point_glass_grid.dart';
import 'package:point_glass/src/models/point_glass_polygon.dart';
import 'package:point_glass/src/painters/point_glass_axis_painter.dart';
import 'package:point_glass/src/painters/point_glass_grid_painter.dart';
import 'package:point_glass/src/painters/point_glass_polygon_painter.dart';
import 'package:point_glass/src/utils/transform_3d.dart';

class PointGlassPainter extends CustomPainter {
  final Transform3D transform;
  final PointGlassGrid grid;
  final PointGlassAxis axis;
  final List<PointGlassPolygon> polygons;

  late PointGlassGridPainter gridPainter;
  late PointGlassAxisPainter axisPainter;
  late PointGlassPolygonPainter polygonPainter;

  PointGlassPainter({
    required this.transform,
    required this.grid,
    required this.axis,
    required this.polygons,
  }) {
    gridPainter = PointGlassGridPainter(transform: transform, grid: grid);
    axisPainter = PointGlassAxisPainter(transform: transform, axis: axis);
    polygonPainter = PointGlassPolygonPainter(
      transform: transform,
      polygons: polygons,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(
      (size.width / 2) + transform.positionX,
      (size.height / 2) + transform.positionY,
    );

    if (grid.enable) {
      gridPainter.draw(canvas, size);
    }

    if (axis.enable) {
      axisPainter.draw(canvas, size);
    }

    if (polygons.isNotEmpty) {
      // 각 Polygon 안에서 enble 체크
      polygonPainter.draw(canvas, size);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(PointGlassPainter oldDelegate) {
    return oldDelegate.transform != transform;
  }
}
