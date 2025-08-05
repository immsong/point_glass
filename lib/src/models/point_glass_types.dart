import 'package:flutter/material.dart';

class PopupMenuStyle {
  final Color backgroundColor;
  final TextStyle textStyle;

  const PopupMenuStyle({
    this.backgroundColor = Colors.white,
    this.textStyle = const TextStyle(color: Colors.black),
  });
}

/// Point Glass 뷰어의 사용자 동작 모드를 정의합니다.
enum PointGlassViewerMode {
  /// 사용자 동작 모드가 없는 모드
  none,

  /// 뷰어를 회전할 수 있는 모드
  rotate,

  /// 뷰어를 이동할 수 있는 모드
  translate,

  /// 뷰어를 Z 축 기준으로 회전할 수 있는 모드
  spin,

  /// 다각형을 편집할 수 있는 모드
  editPolygon,
}
