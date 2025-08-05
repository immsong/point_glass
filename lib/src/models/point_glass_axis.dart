import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_geometry.dart';

/// 3D 축의 설정을 정의하는 클래스입니다.
class PointGlassAxis extends PointGlassGeometry {
  /// X 축 색상
  Color xColor;

  /// Y 축 색상
  Color yColor;

  /// Z 축 색상
  Color zColor;

  /// 축 길이
  double axisLength;

  PointGlassAxis({
    super.enable,
    super.alpha = 255,
    super.strokeWidth,
    this.xColor = Colors.red,
    this.yColor = Colors.green,
    this.zColor = Colors.blue,
    this.axisLength = 0.5,
  });
}
