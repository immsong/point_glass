import 'package:flutter/material.dart';

import 'package:vector_math/vector_math.dart' as vm;

import 'package:point_glass/src/models/point_glass_geometry.dart';

class PointGlassPolygon extends PointGlassGeometry {
  // 다각형 꼭지점
  List<vm.Vector3> points;

  // 꼭지점 크기
  double pointSize;

  // 꼭지점 색상
  Color pointColor;

  PointGlassPolygon({
    super.enable,
    super.color,
    super.alpha,
    super.strokeWidth,
    this.points = const [],
    this.pointSize = 0.0,
    this.pointColor = Colors.yellow,
  });
}
