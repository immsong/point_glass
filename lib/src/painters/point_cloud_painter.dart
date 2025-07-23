import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/point_cloud.dart';
import '../utils/transform_3d.dart';

class PointCloudPainter extends CustomPainter {
  final List<PointCloud> clouds;
  final Transform3D transform;

  const PointCloudPainter({required this.clouds, required this.transform});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    if (clouds.isEmpty) {
      canvas.restore();
      return;
    }

    for (int i = 0; i < clouds.length; i++) {
      final cloud = clouds[i];
      if (cloud.data.isEmpty) continue;

      List<(Offset, Color)> points = [];
      for (var point in cloud.data) {
        final transformed = transform.transform(point.x, point.y, point.z);
        final screenX = (transformed.$1 * transform.scale).round();
        final screenY = (transformed.$2 * transform.scale).round();
        points.add((
          Offset(screenX.toDouble(), screenY.toDouble()),
          point.color,
        ));
      }

      final sorted = points
        ..sort((a, b) {
          final pointA = transform.transform(
            a.$1.dx / transform.scale,
            a.$1.dy / transform.scale,
            0,
          );
          final pointB = transform.transform(
            b.$1.dx / transform.scale,
            b.$1.dy / transform.scale,
            0,
          );
          return pointB.$3.compareTo(pointA.$3);
        });

      canvas.drawPoints(
        PointMode.points,
        sorted.map((e) => e.$1).toList(),
        Paint()
          ..color = cloud.color ?? Colors.white
          ..strokeWidth = cloud.size ?? 1
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(PointCloudPainter oldDelegate) {
    return oldDelegate.transform != transform || oldDelegate.clouds != clouds;
  }
}
