import 'dart:math';

import 'package:vector_math/vector_math.dart';

class Transform3D {
  final double scale;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final double positionX;
  final double positionY;
  late Matrix4 _transformMatrix;
  double perspective = 0.0;
  double? perspectiveMax;
  double? perspectiveMin;

  Transform3D({
    this.scale = 100.0,
    this.rotationX = 0.0,
    this.rotationY = 0.0,
    this.rotationZ = 0.0,
    this.positionX = 0.0,
    this.positionY = 0.0,
    this.perspectiveMax,
    this.perspectiveMin,
  }) {
    _updateTransformMatrix();
  }

  void _updateTransformMatrix() {
    // 기본 변환 행렬
    _transformMatrix = Matrix4.identity();

    // 스케일 적용
    _transformMatrix.scale(scale, scale, scale);

    // 회전 적용 (순서: Y -> X -> Z)
    _transformMatrix.rotateY(radians(rotationY));
    _transformMatrix.rotateX(radians(rotationX));
    _transformMatrix.rotateZ(radians(rotationZ));
  }

  (double, double, double) transform(double x, double y, double z) {
    // Y 축이 위쪽 양수가 되도록 변경
    y = -y;

    final vector = Vector4(x, y, z, 1.0);
    final transformed = _transformMatrix.transform(vector);

    // 원근 투영 적용
    final perspectiveMax = this.perspectiveMax ?? 1000.0;
    final perspectiveMin = this.perspectiveMin ?? 100.0;

    final logScale = log(scale / 100.0); // 100을 기준으로 로그 계산
    perspective =
        (perspectiveMax - logScale * (perspectiveMax - perspectiveMin) / 2)
            .clamp(perspectiveMin, perspectiveMax);

    final minZ = 1.0;

    final zDistance = perspective - transformed.z;
    final projectionFactor = perspective / (perspective + max(zDistance, minZ));

    return (
      transformed.x * projectionFactor,
      transformed.y * projectionFactor,
      transformed.z,
    );
  }

  Transform3D copyWith({
    double? scale,
    double? rotationX,
    double? rotationY,
    double? rotationZ,
    double? positionX,
    double? positionY,
  }) {
    return Transform3D(
      scale: scale ?? this.scale,
      rotationX: rotationX ?? this.rotationX,
      rotationY: rotationY ?? this.rotationY,
      rotationZ: rotationZ ?? this.rotationZ,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
    );
  }

  double radians(double degrees) => degrees * (pi / 180.0);
  double degrees(double radians) => radians * (180.0 / pi);
}
