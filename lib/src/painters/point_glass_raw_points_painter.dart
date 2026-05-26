import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_glass_raw_points.dart';
import 'package:point_glass/src/utils/color_map.dart';
import 'package:point_glass/src/utils/view_context.dart';

class PointGlassRawPointsPainter {
  final ViewContext viewContext;
  final List<PointGlassRawPoints> rawPointsGroup;

  PointGlassRawPointsPainter({
    required this.viewContext,
    required this.rawPointsGroup,
  });

  void draw(Canvas canvas, Size size) {
    // Float32List 기반 raw 포인트 클라우드
    for (final rawGroup in rawPointsGroup) {
      if (!rawGroup.enable || rawGroup.buf.isEmpty) {
        continue;
      }

      final xIdx = rawGroup.fields['x'];
      final yIdx = rawGroup.fields['y'];
      final zIdx = rawGroup.fields['z'];
      if (xIdx == null || yIdx == null || zIdx == null) {
        continue;
      }

      if (rawGroup.stride <= 0) {
        continue;
      }

      int? colorFieldIdx;
      if (rawGroup.colorField != 'distance') {
        colorFieldIdx = rawGroup.fields[rawGroup.colorField];
      }

      final numPoints = rawGroup.buf.length ~/ rawGroup.stride;
      const baseColor = Color(0xB3FFFFFF);

      final Map<(Color, double), List<double>> rawCoordBuckets = {};
      for (int i = 0; i < numPoints; i++) {
        final base = i * rawGroup.stride;
        final x = rawGroup.buf[base + xIdx];
        final y = rawGroup.buf[base + yIdx];
        final z = rawGroup.buf[base + zIdx];

        final transformed = viewContext.projectModel(x, y, z);
        final projected = transformed.p;
        if (projected == null) {
          continue;
        }

        final radius = rawGroup.strokeWidth;
        Color color = baseColor;
        if (colorFieldIdx != null) {
          final fieldValue = rawGroup.buf[base + colorFieldIdx];
          color = colorMapToColor(
            fieldValue,
            rawGroup.colorMap,
            min: rawGroup.colorMin,
            max: rawGroup.colorMax,
          );
        } else {
          // distance 기반 색상 매핑
          final distance = sqrt(x * x + y * y + z * z);
          color = colorMapToColor(
            distance,
            rawGroup.colorMap,
            min: rawGroup.colorMin,
            max: rawGroup.colorMax,
          );
        }
        color = color.withAlpha(rawGroup.alpha);

        final key = (color, radius);
        (rawCoordBuckets[key] ??= <double>[])
          ..add(projected.dx)
          ..add(projected.dy);
      }

      for (final entry in rawCoordBuckets.entries) {
        final (color, radius) = entry.key;
        final coords = entry.value;

        if (coords.isEmpty) {
          continue;
        }

        canvas.drawRawPoints(
          ui.PointMode.points,
          Float32List.fromList(coords),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..color = color
            ..strokeWidth = radius * 2,
        );
      }
    }
  }
}
