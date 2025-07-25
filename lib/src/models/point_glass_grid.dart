import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_geometry.dart';

class PointGlassGrid extends PointGlassGeometry {
  double gridSize;

  double gridStep;

  bool enableLabel;

  TextStyle labelStyle;

  PointGlassGrid({
    super.enable,
    super.color,
    super.alpha,
    super.strokeWidth,
    this.gridSize = 100,
    this.gridStep = 10,
    this.enableLabel = false,
    this.labelStyle = const TextStyle(color: Colors.white),
  });
}
