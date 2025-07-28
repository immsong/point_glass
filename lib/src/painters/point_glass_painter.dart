import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_axis.dart';
import 'package:point_glass/src/models/point_glass_grid.dart';
import 'package:point_glass/src/painters/point_glass_axis_painter.dart';
import 'package:point_glass/src/painters/point_glass_grid_painter.dart';
import 'package:point_glass/src/utils/transform_3d.dart';

class PointGlassPainter extends CustomPainter {
  final Transform3D transform;
  final PointGlassGrid grid;
  final PointGlassAxis axis;

  late PointGlassGridPainter gridPainter;
  late PointGlassAxisPainter axisPainter;

  PointGlassPainter({
    required this.transform,
    required this.grid,
    required this.axis,
  }) {
    gridPainter = PointGlassGridPainter(transform: transform, grid: grid);
    axisPainter = PointGlassAxisPainter(transform: transform, axis: axis);
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

    canvas.restore();
  }

  @override
  bool shouldRepaint(PointGlassPainter oldDelegate) {
    return oldDelegate.transform != transform;
  }
}
