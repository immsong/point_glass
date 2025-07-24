import 'package:flutter/material.dart';
import 'package:point_glass/point_glass.dart';
import 'package:point_glass/src/models/view_elements/view_element.dart';

class ViewPolygonPlane extends ViewElement {
  final List<Point3D> points;

  final double pointSize;

  final int pointAlpha;

  const ViewPolygonPlane({
    super.enabled = true,
    super.color,
    super.alpha = 100,
    super.width,
    required this.points,
    this.pointSize = 1,
    this.pointAlpha = 100,
  });
}
