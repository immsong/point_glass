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

  (double, double) inverseTransformToPlane(double screenX, double screenY) {
    // 반복적 근사를 통한 정확한 역변환
    double bestX = 0.0;
    double bestY = 0.0;

    // 원근 투영 적용
    final perspectiveMax = this.perspectiveMax ?? 1000.0;
    final perspectiveMin = this.perspectiveMin ?? 100.0;

    final logScale = log(scale / 100.0); // 100을 기준으로 로그 계산
    perspective =
        (perspectiveMax - logScale * (perspectiveMax - perspectiveMin) / 2)
            .clamp(perspectiveMin, perspectiveMax);

    // 초기 추정값 (변환 행렬 역변환으로 시작)
    final inverseTransform = Matrix4.inverted(_transformMatrix);
    final zeroVector = Vector4(0.0, 0.0, 0.0, 1.0);
    final transformedZero = _transformMatrix.transform(zeroVector);
    final zDistance = perspective - transformedZero.z;
    final minZ = 1.0;
    final projectionFactor = perspective / (perspective + max(zDistance, minZ));

    final unprojectedX = screenX / projectionFactor;
    final unprojectedY = screenY / projectionFactor;
    final vector = Vector4(unprojectedX, unprojectedY, 0.0, 1.0);
    final result = inverseTransform.transform(vector);

    // Newton-Raphson 반복으로 정밀도 향상
    bestX = result.x;
    bestY = result.y;

    for (int i = 0; i < 5; i++) {
      // 현재 추정값으로 정변환 수행
      final (forwardX, forwardY, _) = transform(bestX, bestY, 0.0);

      // 오차 계산
      final errorX = forwardX - screenX;
      final errorY = forwardY - screenY;
      final totalError = errorX * errorX + errorY * errorY;

      if (totalError < 1e-10) break; // 충분히 정확함

      // 기울기 계산 (수치 미분)
      const delta = 1e-6;
      final (fx1, fy1, _) = transform(bestX + delta, bestY, 0.0);
      final (fx2, fy2, _) = transform(bestX, bestY + delta, 0.0);

      final dxdx = (fx1 - forwardX) / delta;
      final dydx = (fy1 - forwardY) / delta;
      final dxdy = (fx2 - forwardX) / delta;
      final dydy = (fy2 - forwardY) / delta;

      // 자코비안 행렬의 역행렬로 보정
      final det = dxdx * dydy - dydx * dxdy;
      if (det.abs() < 1e-10) break; // 특이점

      final correctionX = (dydy * errorX - dxdy * errorY) / det;
      final correctionY = (-dydx * errorX + dxdx * errorY) / det;

      bestX -= correctionX;
      bestY -= correctionY;
    }

    return (bestX, bestY);
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
