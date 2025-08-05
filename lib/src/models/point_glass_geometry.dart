import 'package:flutter/material.dart';

/// 3D 객체의 기본 설정을 정의하는 클래스입니다.
abstract class PointGlassGeometry {
  /// 객체 표시 여부
  bool enable;

  /// 색상
  Color color;

  /// 색상 투명도 0 - 255
  int alpha;

  /// 선, 점등 객체 두께
  double strokeWidth;

  PointGlassGeometry({
    this.enable = false,
    this.color = Colors.white,
    this.alpha = 20,
    this.strokeWidth = 1.0,
  });
}
