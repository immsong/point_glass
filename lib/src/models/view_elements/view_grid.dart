import 'package:flutter/material.dart';
import 'package:point_glass/src/models/view_elements/view_element.dart';

class ViewGrid extends ViewElement {
  /// 그리드 크기
  final double size;

  /// 그리드 간격
  final double step;

  /// 축 레이블 표시 여부
  final bool showAxisLabels;

  /// 축 레이블 스타일
  final TextStyle? axisLabelStyle;

  const ViewGrid({
    super.enabled,
    super.color,
    super.alpha,
    super.width,
    this.size = 50.0,
    this.step = 1.0,
    this.showAxisLabels = true,
    this.axisLabelStyle,
  });

  /// 그리드 선 Paint 객체
  Paint get linePaint => Paint()
    ..color = color.withAlpha(alpha)
    ..strokeWidth = width;

  /// 레이블 스타일
  TextStyle get labelStyle =>
      axisLabelStyle ?? TextStyle(color: color.withAlpha(150), fontSize: 10);

  ViewGrid copyWith({
    bool? enabled,
    double? size,
    Color? color,
    int? alpha,
    double? width,
    bool? showAxisLabels,
    TextStyle? axisLabelStyle,
  }) {
    return ViewGrid(
      enabled: enabled ?? this.enabled,
      size: size ?? this.size,
      color: color ?? this.color,
      alpha: alpha ?? this.alpha,
      width: width ?? this.width,
      showAxisLabels: showAxisLabels ?? this.showAxisLabels,
      axisLabelStyle: axisLabelStyle ?? this.axisLabelStyle,
    );
  }
}
