import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_axis.dart';
import 'package:point_glass/src/utils/transform_3d.dart';

class PointGlassAxisPainter {
  final Transform3D transform;
  final PointGlassAxis axis;

  PointGlassAxisPainter({required this.transform, required this.axis});

  void draw(Canvas canvas, Size size) {
    final xLinePaint = Paint()
      ..color = axis.xColor.withAlpha(axis.alpha)
      ..strokeWidth = axis.strokeWidth;
    final yLinePaint = Paint()
      ..color = axis.yColor.withAlpha(axis.alpha)
      ..strokeWidth = axis.strokeWidth;
    final zLinePaint = Paint()
      ..color = axis.zColor.withAlpha(axis.alpha)
      ..strokeWidth = axis.strokeWidth;

    // X축
    final xStart = transform.transform(0, 0, 0);
    final xEnd = transform.transform(axis.axisLength, 0, 0);
    canvas.drawLine(
      Offset(xStart.$1 * transform.scale, xStart.$2 * transform.scale),
      Offset(xEnd.$1 * transform.scale, xEnd.$2 * transform.scale),
      xLinePaint,
    );

    // Y축
    final yStart = transform.transform(0, 0, 0);
    final yEnd = transform.transform(0, axis.axisLength, 0);
    canvas.drawLine(
      Offset(yStart.$1 * transform.scale, yStart.$2 * transform.scale),
      Offset(yEnd.$1 * transform.scale, yEnd.$2 * transform.scale),
      yLinePaint,
    );

    // Z축
    final zStart = transform.transform(0, 0, 0);
    final zEnd = transform.transform(0, 0, axis.axisLength);
    canvas.drawLine(
      Offset(zStart.$1 * transform.scale, zStart.$2 * transform.scale),
      Offset(zEnd.$1 * transform.scale, zEnd.$2 * transform.scale),
      zLinePaint,
    );
  }
}
