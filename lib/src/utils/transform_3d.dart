import 'dart:math';
import 'package:vector_math/vector_math.dart';

class Transform3D {
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final double scale;
  late Matrix4 _transformMatrix;
  double perspective;

  Transform3D({
    this.rotationX = 0.0,
    this.rotationY = 0.0,
    this.rotationZ = 0.0,
    this.scale = 1.0,
    this.perspective = 100.0,
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
    final perspectiveMax = 100.0;
    final perspectiveMin = 50.0;
    perspective =
        (perspectiveMax -
                (scale - 10) * (perspectiveMax - perspectiveMin) / 600)
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
    double? rotationX,
    double? rotationY,
    double? rotationZ,
    double? scale,
  }) {
    return Transform3D(
      rotationX: rotationX ?? this.rotationX,
      rotationY: rotationY ?? this.rotationY,
      rotationZ: rotationZ ?? this.rotationZ,
      scale: scale ?? this.scale,
    );
  }

  double radians(double degrees) => degrees * (pi / 180.0);
}
