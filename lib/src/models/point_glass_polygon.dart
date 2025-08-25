import 'dart:io' if (dart.library.html) 'dart:html' as io;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:vector_math/vector_math.dart' as vm;

import 'package:point_glass/src/models/point_glass_geometry.dart';

/// 3D 다각형의 설정을 정의하는 클래스입니다.
class PointGlassPolygon extends PointGlassGeometry {
  /// 다각형 꼭지점
  List<vm.Vector3> points;

  /// 꼭지점 크기
  double pointSize;

  /// 꼭지점 색상
  Color pointColor;

  /// Line 색상
  Color lineColor;

  /// Line 투명도
  int lineAlpha;

  /// 수정 가능 여부, 수정 시 Z 값이 0이라고 가정 후 계산
  bool isEditable;

  /// 선택된 다각형 (Edit 모드에서 사용)
  bool selectedPolygon;

  /// 선택된 꼭지점 인덱스 (Edit 모드에서 사용)
  int selectedVertexIndex;

  /// 호버된 꼭지점 인덱스 (Edit 모드에서 사용)
  int hoveredVertexIndex;

  /// 라벨 그룹 인덱스
  int labelGroupIndex;

  /// 라벨 표시 여부
  bool enableLabel;

  PointGlassPolygon({
    super.enable,
    super.color,
    super.alpha,
    super.strokeWidth,
    this.points = const [],
    this.pointSize = 0.0,
    this.pointColor = Colors.yellow,
    this.lineColor = Colors.red,
    this.lineAlpha = 0,
    this.isEditable = false,
    this.selectedPolygon = false,
    this.selectedVertexIndex = -1,
    this.hoveredVertexIndex = -1,
    this.labelGroupIndex = 0,
    this.enableLabel = false,
  });

  // Z 값 0으로 가정
  bool isPointInPolygon(double x, double y) {
    int intersections = 0;
    int n = points.length;

    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;

      // 현재 점과 다음 점의 x, y 좌표 (z는 무시)
      double xi = points[i].x;
      double yi = points[i].y;
      double xj = points[j].x;
      double yj = points[j].y;

      // 수평선이 edge와 교차하는지 확인
      if (((yi > y) != (yj > y)) &&
          (x < (xj - xi) * (y - yi) / (yj - yi) + xi)) {
        intersections++;
      }
    }

    // 홀수 개의 교차점이면 내부
    return intersections % 2 == 1;
  }

  // Z 값 0으로 가정
  int? getClickedVertexIndex(double x, double y) {
    double threshold = 0.5;
    if (!kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS)) {
      threshold = 1;
    }

    for (int i = 0; i < points.length; i++) {
      double distance = sqrt(pow(points[i].x - x, 2) + pow(points[i].y - y, 2));

      if (distance <= threshold) {
        return i;
      }
    }
    return null;
  }

  // 현재 클릭된 위치에서 가장 가까운 변을 찾기 (점 추가 시 사용)
  int findClosestEdge(double x, double y) {
    double minDistance = double.infinity;
    int closestEdgeIndex = 0;

    for (int i = 0; i < points.length; i++) {
      int j = (i + 1) % points.length; // 다음 점 (마지막이면 처음으로)

      // 점 (x, y)에서 선분 (points[i], points[j])까지의 거리
      double distance = _distanceToLineSegment(
        x,
        y,
        points[i].x,
        points[i].y,
        points[j].x,
        points[j].y,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestEdgeIndex = i;
      }
    }

    return closestEdgeIndex;
  }

  // 점에서 선분까지의 거리 계산
  double _distanceToLineSegment(
    double px,
    double py,
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    // 선분의 길이의 제곱
    double segmentLengthSquared =
        (pow(x2 - x1, 2) + pow(y2 - y1, 2)).toDouble();

    if (segmentLengthSquared == 0) {
      // 선분이 점인 경우
      return sqrt(pow(px - x1, 2) + pow(py - y1, 2));
    }

    // 선분 위의 가장 가까운 점을 찾기 위한 매개변수 t
    double t =
        ((px - x1) * (x2 - x1) + (py - y1) * (y2 - y1)) / segmentLengthSquared;
    t = t.clamp(0.0, 1.0); // 선분 범위로 제한

    // 선분 위의 가장 가까운 점
    double closestX = x1 + t * (x2 - x1);
    double closestY = y1 + t * (y2 - y1);

    // 거리 반환
    return sqrt(pow(px - closestX, 2) + pow(py - closestY, 2));
  }
}
