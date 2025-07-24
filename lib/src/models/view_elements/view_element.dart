import 'package:flutter/material.dart';

abstract class ViewElement {
  final bool enabled;
  final Color color;
  final int alpha;
  final double width;

  const ViewElement({
    this.enabled = true,
    this.color = Colors.white,
    this.alpha = 15,
    this.width = 1.0,
  });

  Paint get paint => Paint()
    ..color = color.withAlpha(alpha)
    ..strokeWidth = width;
}
