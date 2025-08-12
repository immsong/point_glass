import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_axis.dart';
import 'package:point_glass/src/models/point_glass_grid.dart';
import 'package:point_glass/src/models/point_glass_points.dart';
import 'package:point_glass/src/models/point_glass_polygon.dart';
import 'package:point_glass/src/models/point_glass_annual_sector.dart';
import 'package:point_glass/src/painters/point_glass_axis_painter.dart';
import 'package:point_glass/src/painters/point_glass_grid_painter.dart';
import 'package:point_glass/src/painters/point_glass_points_painter.dart';
import 'package:point_glass/src/painters/point_glass_polygon_painter.dart';
import 'package:point_glass/src/painters/point_glass_annual_sector_painter.dart';
import 'package:point_glass/src/utils/view_context.dart';

class PointGlassPainter extends CustomPainter {
  final ViewContext viewContext;
  final PointGlassGrid grid;
  final PointGlassAxis axis;
  final List<PointGlassPolygon> polygons;
  final List<PointGlassAnnualSector> annualSectors;
  final List<PointGlassPoints> pointsGroup;

  late PointGlassGridPainter gridPainter;
  late PointGlassAxisPainter axisPainter;
  late PointGlassPolygonPainter polygonPainter;
  late PointGlassAnnualSectorPainter annualSectorPainter;
  late PointGlassPointsPainter pointsGroupPainter;

  PointGlassPainter({
    required this.viewContext,
    required this.grid,
    required this.axis,
    required this.polygons,
    required this.annualSectors,
    required this.pointsGroup,
  }) {
    gridPainter = PointGlassGridPainter(
      grid: grid,
      viewContext: viewContext,
    );
    axisPainter = PointGlassAxisPainter(viewContext: viewContext, axis: axis);
    polygonPainter = PointGlassPolygonPainter(
      viewContext: viewContext,
      polygons: polygons,
    );
    annualSectorPainter = PointGlassAnnualSectorPainter(
      viewContext: viewContext,
      annualSectors: annualSectors,
    );
    pointsGroupPainter = PointGlassPointsPainter(
      viewContext: viewContext,
      pointsGroup: pointsGroup,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(
      (size.width / 2) + viewContext.canvasCenter.dx,
      (size.height / 2) + viewContext.canvasCenter.dy,
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

    if (annualSectors.isNotEmpty) {
      // 각 AnnualSector 안에서 enable 체크
      annualSectorPainter.draw(canvas, size);
    }

    if (pointsGroup.isNotEmpty) {
      // 각 PointsGroup 안에서 enable 체크
      pointsGroupPainter.draw(canvas, size);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(PointGlassPainter oldDelegate) {
    return oldDelegate.viewContext != viewContext;
  }
}
