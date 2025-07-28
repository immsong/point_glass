import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_geometry.dart';

class PointGlassAxis extends PointGlassGeometry {
  // 축 색상
  Color xColor;
  Color yColor;
  Color zColor;

  // 축 길이
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
