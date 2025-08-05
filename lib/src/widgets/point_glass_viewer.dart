import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_axis.dart';
import 'package:point_glass/src/models/point_glass_grid.dart';
import 'package:point_glass/src/models/point_glass_points.dart';
import 'package:point_glass/src/models/point_glass_polygon.dart';
import 'package:point_glass/src/models/point_glass_types.dart';
import 'package:point_glass/src/models/point_glass_annual_sector.dart';
import 'package:point_glass/src/utils/transform_3d.dart';

import 'point_glass_viewer_mobile.dart';
import 'point_glass_viewer_desktop.dart';

/// Point Glass의 메인 뷰어 위젯입니다.
///
/// 이 위젯은 3D 포인트 클라우드, 그리드, 축, 다각형 등을 표시하고
/// 사용자 동작을 처리합니다.
///
/// 기본 사용 예시:
/// ```dart
/// PointGlassViewer(
///   transform: ValueNotifier(Transform3D(scale: 50)),
///   mode: PointGlassViewerMode.rotate,
///   grid: PointGlassGrid(enable: true),
/// )
/// ```
///
class PointGlassViewer extends StatelessWidget {
  const PointGlassViewer({
    super.key,
    required this.transform,
    this.contextStyle = const PopupMenuStyle(),
    this.minScale = 10.0,
    this.maxScale = 10000.0,
    this.mode = PointGlassViewerMode.rotate,
    this.grid,
    this.axis,
    this.polygons,
    this.annualSectors,
    this.pointsGroup,
  });

  /// 3D 객체의 현재 변환 상태를 저장하는 ValueNotifier입니다.
  /// 이 값을 변경하여 3D 객체의 위치, 회전, 확대/축소를 조정할 수 있습니다.
  final ValueNotifier<Transform3D> transform;

  /// Polygon Edit 시 팝업 컨텍스트 메뉴의 스타일을 정의하는 클래스입니다.
  final PopupMenuStyle contextStyle;

  /// 최소 확대/축소 비율입니다.
  final double minScale;

  /// 최대 확대/축소 비율입니다.
  final double maxScale;

  /// 뷰어의 사용자 동작 모드를 정의합니다.
  final PointGlassViewerMode mode;

  /// 3D 그리드의 설정을 정의하는 클래스입니다.
  final PointGlassGrid? grid;

  /// 3D 축의 설정을 정의하는 클래스입니다.
  final PointGlassAxis? axis;

  /// 3D 다각형의 설정을 정의하는 클래스입니다.
  final List<PointGlassPolygon>? polygons;

  /// 3D 원형 섹터의 설정을 정의하는 클래스입니다.
  final List<PointGlassAnnualSector>? annualSectors;

  /// 3D 포인트 클라우드의 설정을 정의하는 클래스입니다.
  final List<PointGlassPoints>? pointsGroup;

  @override
  Widget build(BuildContext context) {
    // 웹은 데스크톱 방식 사용
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return PointGlassViewerDesktop(
        transform: transform,
        contextStyle: contextStyle,
        minScale: minScale,
        maxScale: maxScale,
        mode: mode,
        grid: grid,
        axis: axis,
        polygons: polygons,
        annualSectors: annualSectors,
        pointsGroup: pointsGroup,
      );
    } else {
      return PointGlassViewerMobile(
        transform: transform,
        contextStyle: contextStyle,
        minScale: minScale,
        maxScale: maxScale,
        mode: mode,
        grid: grid,
        axis: axis,
        polygons: polygons,
        annualSectors: annualSectors,
        pointsGroup: pointsGroup,
      );
    }
  }
}
