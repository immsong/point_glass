import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_geometry.dart';

/// 3D 원형 섹터의 설정을 정의하는 클래스입니다.
class PointGlassAnnualSector extends PointGlassGeometry {
  /// 시작 각 (0 ~ 360)
  double startAngle;

  /// 끝 각 (0 ~ 360)
  double endAngle;

  /// 내부 반지름
  double innerRadius;

  /// 외부 반지름
  double outerRadius;

  /// 선 색상
  Color lineColor;

  /// 선 투명도
  int lineAlpha;

  /// innder 선 표시 여부
  bool showInnerLine;

  /// outer 선 표시 여부
  bool showOuterLine;

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
    this.showInnerLine = true,
    this.showOuterLine = true,
  });
}
