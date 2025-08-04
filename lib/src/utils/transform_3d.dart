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

    try {
      // 1단계: 간단한 역변환으로 초기 추정
      final inverseTransform = Matrix4.inverted(_transformMatrix);
      final zeroVector = Vector4(0.0, 0.0, 0.0, 1.0);
      final transformedZero = _transformMatrix.transform(zeroVector);
      final zDistance = perspective - transformedZero.z;
      final minZ = 1.0;
      final projectionFactor =
          perspective / (perspective + max(zDistance, minZ));

      // 스크린 좌표를 3D 공간으로 역투영
      final unprojectedX = screenX / projectionFactor;
      final unprojectedY = screenY / projectionFactor;
      final vector = Vector4(unprojectedX, unprojectedY, 0.0, 1.0);
      final result = inverseTransform.transform(vector);

      bestX = result.x;
      bestY = result.y;

      // 2단계: Newton-Raphson 반복
      const double epsilon = 1e-8;
      const int maxIterations = 8;

      for (int i = 0; i < maxIterations; i++) {
        // 현재 추정값으로 정변환
        final (forwardX, forwardY, _) = transform(bestX, bestY, 0.0);

        // 오차 계산
        final errorX = forwardX - screenX;
        final errorY = forwardY - screenY;
        final totalError = errorX * errorX + errorY * errorY;

        if (totalError < epsilon) {
          break; // 충분히 정확함
        }

        // 수치 미분으로 기울기 계산
        const double delta = 1e-4;
        final (fx1, fy1, _) = transform(bestX + delta, bestY, 0.0);
        final (fx2, fy2, _) = transform(bestX, bestY + delta, 0.0);

        final dxdx = (fx1 - forwardX) / delta;
        final dydx = (fy1 - forwardY) / delta;
        final dxdy = (fx2 - forwardX) / delta;
        final dydy = (fy2 - forwardY) / delta;

        // 자코비안 행렬식 계산
        final det = dxdx * dydy - dydx * dxdy;

        // 특이점 체크
        if (det.abs() < 1e-6) {
          // 특이점인 경우 이전 결과 사용하거나 안전한 기본값 반환
          if (i == 0) {
            return (0.0, 0.0); // 초기 반복에서 특이점이면 안전한 기본값
          }
          break; // 중간에 특이점이면 현재 결과 사용
        }

        // 보정값 계산
        final correctionX = (dydy * errorX - dxdy * errorY) / det;
        final correctionY = (-dydx * errorX + dxdx * errorY) / det;

        // 보정값이 너무 크면 스케일링
        final maxCorrection = 10.0;
        final scaleFactor = min(
          1.0,
          maxCorrection / max(correctionX.abs(), correctionY.abs()),
        );

        bestX -= correctionX * scaleFactor;
        bestY -= correctionY * scaleFactor;

        // 발산 방지: 값이 너무 커지면 중단
        if (bestX.abs() > 1000.0 || bestY.abs() > 1000.0) {
          return (0.0, 0.0);
        }
      }

      // 최종 검증
      final (finalX, finalY, _) = transform(bestX, bestY, 0.0);
      final finalError = sqrt(
        pow(finalX - screenX, 2) + pow(finalY - screenY, 2),
      );

      // 오차가 너무 크면 안전한 기본값 반환
      if (finalError > 100.0) {
        return (0.0, 0.0);
      }

      return (bestX, bestY);
    } catch (e) {
      // 예외 발생 시 안전한 기본값 반환
      print('Inverse transform error: $e');
      return (0.0, 0.0);
    }
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
