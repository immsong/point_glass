import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_grid.dart';
import 'package:point_glass/src/painters/point_glass_grid_painter.dart';
import 'package:point_glass/src/utils/transform_3d.dart';

class PointGlassPainter extends CustomPainter {
  final Transform3D transform;
  final PointGlassGrid grid;

  late PointGlassGridPainter gridPainter;

  PointGlassPainter({required this.transform, required this.grid}) {
    gridPainter = PointGlassGridPainter(transform: transform, grid: grid);
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

    canvas.restore();
  }

  @override
  bool shouldRepaint(PointGlassPainter oldDelegate) {
    return oldDelegate.transform != transform;
  }
}
