import 'package:flutter/material.dart';

class PopupMenuStyle {
  final Color backgroundColor;
  final TextStyle textStyle;

  const PopupMenuStyle({
    this.backgroundColor = Colors.white,
    this.textStyle = const TextStyle(color: Colors.black),
  });
}

enum PointGlassViewerMode { none, rotate, translate, spin, editPolygon }
