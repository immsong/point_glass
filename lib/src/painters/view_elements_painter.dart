import 'dart:math';

import 'package:flutter/material.dart';
import 'package:point_glass/src/models/view_elements/view_elements.dart';
import 'package:point_glass/src/utils/transform_3d.dart';
import 'package:vector_math/vector_math_64.dart';

class ViewElementsPainter extends CustomPainter {
  final ViewElements viewElements;
  final Transform3D transform;

  const ViewElementsPainter({
    required this.viewElements,
    required this.transform,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(
      size.width / 2 + transform.positionX,
      size.height / 2 + transform.positionY,
    );

    if (viewElements.grid.enabled) {
      _drawGrid(canvas, size);
    }

    if (viewElements.axis.enabled) {
      _drawAxis(canvas, size);
    }

    if (viewElements.range.enabled) {
      _drawRange(canvas, size);
    }

    if (viewElements.polygonPlanes.isNotEmpty) {
      _drawPolygonPlane(canvas, size);
    }

    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size) {
    final grid = viewElements.grid;

    // 직교 그리드
    for (double pos = -grid.size; pos <= grid.size; pos += grid.step) {
      final segments = (grid.size / grid.step).ceil();
      final points = <Offset>[];
      final validSegments = <bool>[]; // 각 선분의 유효성 저장

      // 수직선 (X = pos인 선)
      for (var i = 0; i <= segments; i++) {
        final t = i / segments;
        final y = -grid.size + (2 * grid.size * t);

        final transformed = _transformPoint(pos, y, 0);
        points.add(
          Offset(
            transformed.$1 * transform.scale,
            transformed.$2 * transform.scale,
          ),
        );
        validSegments.add(
          transformed.$3 < transform.perspective,
        ); // perspective로 비교
      }

      // 선 그리기
      for (var i = 0; i < points.length - 1; i++) {
        if (validSegments[i] && validSegments[i + 1]) {
          canvas.drawLine(points[i], points[i + 1], grid.linePaint);
        }
      }

      points.clear();
      validSegments.clear();

      // 수평선 (Y = pos인 선)
      for (var i = 0; i <= segments; i++) {
        final t = i / segments;
        final x = -grid.size + (2 * grid.size * t);

        final transformed = _transformPoint(x, pos, 0);
        points.add(
          Offset(
            transformed.$1 * transform.scale,
            transformed.$2 * transform.scale,
          ),
        );
        validSegments.add(
          transformed.$3 < transform.perspective,
        ); // perspective로 비교
      }

      // 선 그리기
      for (var i = 0; i < points.length - 1; i++) {
        if (validSegments[i] && validSegments[i + 1]) {
          canvas.drawLine(points[i], points[i + 1], grid.linePaint);
        }
      }
    }

    // 원형 그리드
    for (double radius = grid.step; radius <= grid.size; radius += grid.step) {
      final points = <Offset>[];
      final segments = 72;

      for (var i = 0; i <= segments; i++) {
        final angle = (2 * pi * i) / segments;
        final x = radius * cos(angle);
        final y = radius * sin(angle);

        final transformed = _transformPoint(x, y, 0);
        points.add(
          Offset(
            transformed.$1 * transform.scale,
            transformed.$2 * transform.scale,
          ),
        );
      }

      for (var i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], grid.linePaint);
      }
    }

    if (grid.showAxisLabels) {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      for (var i = 1; i <= grid.size; i++) {
        final value = i * grid.step;

        // Y축 레이블
        final yPos = _transformPoint(0, i * grid.step, 0);
        textPainter.text = TextSpan(
          text: value.toString(),
          style: grid.labelStyle,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            yPos.$1 * transform.scale - textPainter.width / 2,
            yPos.$2 * transform.scale - textPainter.height / 2,
          ),
        );
      }
    }
  }

  void _drawAxis(Canvas canvas, Size size) {
    final axis = viewElements.axis;

    // X축
    final xStart = _transformPoint(0, 0, 0);
    final xEnd = _transformPoint(axis.length, 0, 0);
    canvas.drawLine(
      Offset(xStart.$1 * transform.scale, xStart.$2 * transform.scale),
      Offset(xEnd.$1 * transform.scale, xEnd.$2 * transform.scale),
      Paint()
        ..color = axis.xColor
        ..strokeWidth = axis.width,
    );

    // Y축
    final yStart = _transformPoint(0, 0, 0);
    final yEnd = _transformPoint(0, axis.length, 0);
    canvas.drawLine(
      Offset(yStart.$1 * transform.scale, yStart.$2 * transform.scale),
      Offset(yEnd.$1 * transform.scale, yEnd.$2 * transform.scale),
      Paint()
        ..color = axis.yColor
        ..strokeWidth = axis.width,
    );

    // Z축
    final zStart = _transformPoint(0, 0, 0);
    final zEnd = _transformPoint(0, 0, axis.length);
    canvas.drawLine(
      Offset(zStart.$1 * transform.scale, zStart.$2 * transform.scale),
      Offset(zEnd.$1 * transform.scale, zEnd.$2 * transform.scale),
      Paint()
        ..color = axis.zColor
        ..strokeWidth = axis.width,
    );
  }

  void _drawRange(Canvas canvas, Size size) {
    final range = viewElements.range;
    if (range.enableHorizontalRange) {
      var xPos = range.distanceEnd * sin(radians(range.horizontalStart));
      var yPos = range.distanceEnd * cos(radians(range.horizontalStart));

      var xStart = _transformPoint(0, 0, 0);
      var xEnd = _transformPoint(xPos, yPos, 0);
      canvas.drawLine(
        Offset(xStart.$1 * transform.scale, xStart.$2 * transform.scale),
        Offset(xEnd.$1 * transform.scale, xEnd.$2 * transform.scale),
        Paint()
          ..color = range.horizontalStartColor.withAlpha(range.alpha)
          ..strokeWidth = range.width,
      );

      xPos = range.distanceEnd * sin(radians(range.horizontalEnd));
      yPos = range.distanceEnd * cos(radians(range.horizontalEnd));
      xStart = _transformPoint(0, 0, 0);
      xEnd = _transformPoint(xPos, yPos, 0);
      canvas.drawLine(
        Offset(xStart.$1 * transform.scale, xStart.$2 * transform.scale),
        Offset(xEnd.$1 * transform.scale, xEnd.$2 * transform.scale),
        Paint()
          ..color = range.horizontalEndColor.withAlpha(range.alpha)
          ..strokeWidth = range.width,
      );
    }

    if (range.enableDistanceRange) {
      // 시작점과 끝점 사이의 원호 그리기
      final segments = 36; // 부드러운 곡선을 위한 분할 수
      final points = <Offset>[];

      // 밖깥쪽 원호
      for (var i = 0; i <= segments; i++) {
        final t = i / segments;
        final angle =
            range.horizontalStart +
            (range.horizontalEnd - range.horizontalStart) * t;

        final x = range.distanceEnd * sin(radians(angle));
        final y = range.distanceEnd * cos(radians(angle));

        final transformed = _transformPoint(x, y, 0);
        points.add(
          Offset(
            transformed.$1 * transform.scale,
            transformed.$2 * transform.scale,
          ),
        );
      }

      // 점들을 연결하여 원호 그리기
      for (var i = 0; i < points.length - 1; i++) {
        canvas.drawLine(
          points[i],
          points[i + 1],
          Paint()
            ..color = range.distanceStartColor.withAlpha(range.alpha)
            ..strokeWidth = range.width,
        );
      }

      points.clear();

      // 안쪽 원호
      if (range.distanceStart > 0) {
        for (var i = 0; i <= segments; i++) {
          final t = i / segments;
          final angle =
              range.horizontalStart +
              (range.horizontalEnd - range.horizontalStart) * t;

          final x = range.distanceStart * sin(radians(angle));
          final y = range.distanceStart * cos(radians(angle));

          final transformed = _transformPoint(x, y, 0);
          points.add(
            Offset(
              transformed.$1 * transform.scale,
              transformed.$2 * transform.scale,
            ),
          );
        }
      }

      // 점들을 연결하여 원호 그리기
      for (var i = 0; i < points.length - 1; i++) {
        canvas.drawLine(
          points[i],
          points[i + 1],
          Paint()
            ..color = range.distanceStartColor.withAlpha(range.alpha)
            ..strokeWidth = range.width,
        );
      }
    }
  }

  void _drawPolygonPlane(Canvas canvas, Size size) {
    final polygonPlanes = viewElements.polygonPlanes;
    for (var polygonPlane in polygonPlanes) {
      final path = Path();

      // 첫 점으로 이동
      if (polygonPlane.points.isNotEmpty) {
        final firstPoint = polygonPlane.points.first;
        final transformedFirst = _transformPoint(
          firstPoint.x,
          firstPoint.y,
          firstPoint.z,
        );
        path.moveTo(
          transformedFirst.$1 * transform.scale,
          transformedFirst.$2 * transform.scale,
        );

        // 나머지 점들을 연결
        for (var i = 1; i < polygonPlane.points.length; i++) {
          final point = polygonPlane.points[i];
          final transformed = _transformPoint(point.x, point.y, point.z);
          path.lineTo(
            transformed.$1 * transform.scale,
            transformed.$2 * transform.scale,
          );
        }

        path.close();

        canvas.drawPath(
          path,
          Paint()
            ..color = polygonPlane.color.withAlpha(polygonPlane.alpha)
            ..style = PaintingStyle.fill,
        );
      }

      // 꼭지점 그리기
      for (var point in polygonPlane.points) {
        final transformed = _transformPoint(point.x, point.y, point.z);
        canvas.drawCircle(
          Offset(
            transformed.$1 * transform.scale,
            transformed.$2 * transform.scale,
          ),
          polygonPlane.pointSize,
          Paint()
            ..color = point.color.withAlpha(polygonPlane.pointAlpha)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  (double, double, double) _transformPoint(double x, double y, double z) {
    return transform.transform(x, y, z);
  }

  @override
  bool shouldRepaint(ViewElementsPainter oldDelegate) {
    return oldDelegate.transform != transform ||
        oldDelegate.viewElements != viewElements;
  }
}
