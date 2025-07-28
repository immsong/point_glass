import 'package:flutter/material.dart';

abstract class PointGlassGeometry {
  // paint 여부
  final bool enable;

  // 색상
  final Color color;

  // 색상 투명도 0 - 255
  final int alpha;

  // 선, 점 두께
  final double strokeWidth;

  PointGlassGeometry({
    this.enable = false,
    this.color = Colors.white,
    this.alpha = 20,
    this.strokeWidth = 1.0,
  });
}
