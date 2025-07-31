import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_geometry.dart';

class PointGlassAnnualSector extends PointGlassGeometry {
  // 시작 각 (0 ~ 360)
  double startAngle;

  // 끝 각 (0 ~ 360)
  double endAngle;

  // 내부 반지름
  double innerRadius;

  // 외부 반지름
  double outerRadius;

  // 선 색상
  Color lineColor;

  // 선 투명도
  int lineAlpha;

  PointGlassAnnualSector({
    super.enable,
    super.color, // 면 색상
    super.alpha, // 면 투명도
    super.strokeWidth, // 선 두께
    this.startAngle = 0.0,
    this.endAngle = 0.0,
    this.innerRadius = 0.0,
    this.outerRadius = 0.0,
    this.lineColor = Colors.white,
    this.lineAlpha = 255,
  });
}
