import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_axis.dart';
import 'package:point_glass/src/utils/view_context.dart';

class PointGlassAxisPainter {
  final ViewContext viewContext;
  final PointGlassAxis axis;

  PointGlassAxisPainter({required this.viewContext, required this.axis});

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
    var prStart = viewContext.projectModel(0, 0, 0);
    var prEnd = viewContext.projectModel(axis.axisLength, 0, 0);

    if (prStart.p != null && prEnd.p != null) {
      canvas.drawLine(
        prStart.p!,
        prEnd.p!,
        xLinePaint,
      );
    }

    // Y축
    prStart = viewContext.projectModel(0, 0, 0);
    prEnd = viewContext.projectModel(0, axis.axisLength, 0);

    if (prStart.p != null && prEnd.p != null) {
      canvas.drawLine(
        prStart.p!,
        prEnd.p!,
        yLinePaint,
      );
    }

    // Z축
    prStart = viewContext.projectModel(0, 0, 0);
    prEnd = viewContext.projectModel(0, 0, axis.axisLength);

    if (prStart.p != null && prEnd.p != null) {
      canvas.drawLine(
        prStart.p!,
        prEnd.p!,
        zLinePaint,
      );
    }
  }
}
