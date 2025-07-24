import 'package:flutter/material.dart';
import 'package:point_glass/src/models/view_elements/view_element.dart';

class ViewRange extends ViewElement {
  final bool enableHorizontalRange;
  final bool enableDistanceRange;

  final double horizontalStart;
  final Color horizontalStartColor;

  final double horizontalEnd;
  final Color horizontalEndColor;

  final double distanceStart;
  final Color distanceStartColor;

  final double distanceEnd;
  final Color distanceEndColor;

  const ViewRange({
    super.enabled,
    super.color,
    super.alpha = 80,
    super.width,
    this.enableHorizontalRange = true,
    this.enableDistanceRange = true,
    this.horizontalStart = -50,
    this.horizontalStartColor = Colors.purple,
    this.horizontalEnd = 50,
    this.horizontalEndColor = Colors.orange,
    this.distanceStart = 3,
    this.distanceStartColor = Colors.yellow,
    this.distanceEnd = 20,
    this.distanceEndColor = Colors.yellow,
  });
}
