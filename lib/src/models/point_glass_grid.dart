import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_geometry.dart';

class PointGlassGrid extends PointGlassGeometry {
  // 그리드 크기, gridSize x gridSize
  double gridSize;

  // 그리드 간격
  double gridStep;

  // 라벨 표시 여부
  bool enableLabel;

  // 라벨 스타일
  TextStyle labelStyle;

  PointGlassGrid({
    super.enable,
    super.color,
    super.alpha,
    super.strokeWidth,
    this.gridSize = 20,
    this.gridStep = 1,
    this.enableLabel = false,
    this.labelStyle = const TextStyle(color: Colors.white),
  });
}
