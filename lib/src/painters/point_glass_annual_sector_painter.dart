import 'dart:math';

import 'package:flutter/material.dart';

import 'package:vector_math/vector_math.dart' as vm;

import 'package:point_glass/src/models/point_glass_annual_sector.dart';
import 'package:point_glass/src/utils/view_context.dart';

class PointGlassAnnualSectorPainter {
  final ViewContext viewContext;
  final List<PointGlassAnnualSector> annualSectors;

  PointGlassAnnualSectorPainter({
    required this.viewContext,
    required this.annualSectors,
  });

  void draw(Canvas canvas, Size size) {
    for (var annualSector in annualSectors) {
      if (!annualSector.enable) {
        continue;
      }

      final linePaint = Paint()
        ..color = annualSector.lineColor.withAlpha(annualSector.lineAlpha)
        ..strokeWidth = annualSector.strokeWidth;

      final planePaint = Paint()
        ..color = annualSector.color.withAlpha(annualSector.alpha)
        ..style = PaintingStyle.fill;

      final innerPoints = <Offset>[];
      final outerPoints = <Offset>[];

      // 5도 간격으로 선을 그려 원처럼 보이도록
      for (var i = annualSector.startAngle;
          i <= annualSector.endAngle;
          i += 5) {
        final angle = vm.radians(i.toDouble());
        final innerX = annualSector.innerRadius * cos(angle);
        final innerY = annualSector.innerRadius * sin(angle);
        final outerX = annualSector.outerRadius * cos(angle);
        final outerY = annualSector.outerRadius * sin(angle);

        final innerTransformed = viewContext.projectModel(innerX, innerY, 0);
        final outerTransformed = viewContext.projectModel(outerX, outerY, 0);

        if (innerTransformed.p == null || outerTransformed.p == null) {
          continue;
        }

        innerPoints.add(innerTransformed.p!);
        outerPoints.add(outerTransformed.p!);
      }

      if (innerPoints.isEmpty || outerPoints.isEmpty) {
        continue;
      }

      for (var i = 0; i < innerPoints.length - 1; i++) {
        canvas.drawLine(innerPoints[i], innerPoints[i + 1], linePaint);
      }

      for (var i = 0; i < outerPoints.length - 1; i++) {
        canvas.drawLine(outerPoints[i], outerPoints[i + 1], linePaint);
      }

      if (annualSector.startAngle != 0 || annualSector.endAngle != 360) {
        canvas.drawLine(innerPoints.first, outerPoints.first, linePaint);
        canvas.drawLine(innerPoints.last, outerPoints.last, linePaint);
      }

      Path path = Path();
      path.moveTo(innerPoints.first.dx, innerPoints.first.dy);
      for (var i = 1; i < innerPoints.length; i++) {
        path.lineTo(innerPoints[i].dx, innerPoints[i].dy);
      }

      for (var i = outerPoints.length - 1; i >= 0; i--) {
        path.lineTo(outerPoints[i].dx, outerPoints[i].dy);
      }

      path.lineTo(innerPoints.first.dx, innerPoints.first.dy);
      path.close();

      canvas.drawPath(path, planePaint);
    }
  }
}
