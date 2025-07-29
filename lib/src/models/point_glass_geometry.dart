import 'package:flutter/material.dart';

abstract class PointGlassGeometry {
  // paint 여부
  bool enable;

  // 색상
  Color color;

  // 색상 투명도 0 - 255
  int alpha;

  // 선, 점 두께
  double strokeWidth;

  PointGlassGeometry({
    this.enable = false,
    this.color = Colors.white,
    this.alpha = 20,
    this.strokeWidth = 1.0,
  });
}
