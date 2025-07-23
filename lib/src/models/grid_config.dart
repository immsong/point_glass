import 'package:flutter/material.dart';

class GridConfig {
  /// 그리드 활성화 여부
  final bool enabled;

  /// 그리드 크기
  final double size;

  /// 그리드 간격
  final double step;

  /// 그리드 선 색상
  final Color lineColor;

  /// 그리드 선 투명도
  final int lineAlpha;

  /// 그리드 선 두께
  final double lineWidth;

  /// 축 표시 여부
  final bool showAxis;

  /// 축 레이블 표시 여부
  final bool showAxisLabels;

  /// 축 레이블 스타일
  final TextStyle? axisLabelStyle;

  const GridConfig({
    this.enabled = true,
    this.size = 50.0,
    this.step = 1.0,
    this.lineColor = Colors.white,
    this.lineAlpha = 15,
    this.lineWidth = 1.0,
    this.showAxis = true,
    this.showAxisLabels = true,
    this.axisLabelStyle,
  });

  /// 그리드 선 Paint 객체
  Paint get linePaint => Paint()
    ..color = lineColor.withAlpha(lineAlpha)
    ..strokeWidth = lineWidth;

  /// 축 Paint 객체 (더 진한 색상)
  Paint get axisPaint => Paint()
    ..color = lineColor.withAlpha(lineAlpha * 3)
    ..strokeWidth = lineWidth * 2;

  /// 레이블 스타일
  TextStyle get labelStyle =>
      axisLabelStyle ??
      TextStyle(color: lineColor.withAlpha(150), fontSize: 10);

  GridConfig copyWith({
    bool? enabled,
    double? size,
    Color? lineColor,
    int? lineAlpha,
    double? lineWidth,
    bool? showAxis,
    bool? showAxisLabels,
    TextStyle? axisLabelStyle,
  }) {
    return GridConfig(
      enabled: enabled ?? this.enabled,
      size: size ?? this.size,
      lineColor: lineColor ?? this.lineColor,
      lineAlpha: lineAlpha ?? this.lineAlpha,
      lineWidth: lineWidth ?? this.lineWidth,
      showAxis: showAxis ?? this.showAxis,
      showAxisLabels: showAxisLabels ?? this.showAxisLabels,
      axisLabelStyle: axisLabelStyle ?? this.axisLabelStyle,
    );
  }
}
