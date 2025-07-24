import 'package:flutter/material.dart';
import 'package:point_glass/src/models/view_elements/view_element.dart';

class ViewAxis extends ViewElement {
  final double length;

  final Color xColor;
  final Color yColor;
  final Color zColor;

  const ViewAxis({
    super.enabled,
    super.color,
    super.alpha,
    super.width = 2,
    this.length = 50.0,
    this.xColor = Colors.red,
    this.yColor = Colors.green,
    this.zColor = Colors.blue,
  });
}
