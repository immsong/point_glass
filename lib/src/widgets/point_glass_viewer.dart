import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_axis.dart';
import 'package:point_glass/src/models/point_glass_grid.dart';
import 'package:point_glass/src/models/point_glass_polygon.dart';
import 'package:point_glass/src/models/point_glass_types.dart';
import 'package:point_glass/src/models/point_glass_annual_sector.dart';
import 'package:point_glass/src/utils/transform_3d.dart';

import 'point_glass_viewer_mobile.dart';
import 'point_glass_viewer_desktop.dart';

class PointGlassViewer extends StatelessWidget {
  const PointGlassViewer({
    super.key,
    required this.transform,
    this.contextStyle = const PopupMenuStyle(),
    this.minScale = 10.0,
    this.maxScale = 10000.0,
    this.mode = PointGlassViewerMode.rotate,
    this.grid,
    this.axis,
    this.polygons,
    this.annualSectors,
  });

  final ValueNotifier<Transform3D> transform;
  final PopupMenuStyle contextStyle;
  final double minScale;
  final double maxScale;
  final PointGlassViewerMode mode;
  final PointGlassGrid? grid;
  final PointGlassAxis? axis;
  final List<PointGlassPolygon>? polygons;
  final List<PointGlassAnnualSector>? annualSectors;

  @override
  Widget build(BuildContext context) {
    // 웹은 데스크톱 방식 사용
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return PointGlassViewerDesktop(
        transform: transform,
        contextStyle: contextStyle,
        minScale: minScale,
        maxScale: maxScale,
        mode: mode,
        grid: grid,
        axis: axis,
        polygons: polygons,
        annualSectors: annualSectors,
      );
    } else {
      return PointGlassViewerMobile(
        transform: transform,
        contextStyle: contextStyle,
        minScale: minScale,
        maxScale: maxScale,
        mode: mode,
        grid: grid,
        axis: axis,
        polygons: polygons,
        annualSectors: annualSectors,
      );
    }
  }
}
