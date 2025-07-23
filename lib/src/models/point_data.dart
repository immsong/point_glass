import 'package:flutter/material.dart';

class Point3D {
  /// x 좌표
  final double x;

  /// y 좌표
  final double y;

  /// z 좌표
  final double z;

  /// 포인트 색상
  final Color color;

  const Point3D({
    required this.x,
    required this.y,
    required this.z,
    this.color = Colors.white,
  });

  /// 객체 복사본 생성 with 새로운 값
  Point3D copyWith({double? x, double? y, double? z, Color? color}) {
    return Point3D(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      color: color ?? this.color,
    );
  }
}
