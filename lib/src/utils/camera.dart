import 'package:vector_math/vector_math.dart';

/// 3D 모델의 변환 정보를 담는 클래스
class ModelTransform {
  /// 모델의 크기 배율 (기본값: 1.0)
  final double scale;

  /// X축 회전 각도 (도 단위)
  final double rotationX;

  /// Y축 회전 각도 (도 단위)
  final double rotationY;

  /// Z축 회전 각도 (도 단위)
  final double rotationZ;

  /// ModelTransform 인스턴스를 생성합니다
  const ModelTransform({
    this.scale = 1.0,
    this.rotationX = 0.0,
    this.rotationY = 0.0,
    this.rotationZ = 0.0,
  });

  /// 변환 행렬을 계산하여 반환합니다
  Matrix4 modelMatrix() {
    final m = Matrix4.identity();
    m.scale(scale, scale, scale);
    m.rotateY(radians(rotationY));
    m.rotateX(radians(rotationX));
    m.rotateZ(radians(rotationZ));
    return m;
  }
}

class PinholeCamera {
  final double cameraZ; // camera is at (0,0,cameraZ), looking toward -Z
  final double yaw; // Y
  final double pitch; // X
  final double roll; // Z
  const PinholeCamera({
    this.cameraZ = 500.0,
    this.yaw = 0.0,
    this.pitch = 0.0,
    this.roll = 0.0,
  });
  Matrix4 viewMatrix() {
    final v = Matrix4.identity();
    v.translate(0.0, 0.0, -cameraZ);
    v.rotateY(radians(yaw));
    v.rotateX(radians(pitch));
    v.rotateZ(radians(roll));
    return v;
  }

  PinholeCamera copyWith({
    double? cameraZ,
    double? yaw,
    double? pitch,
    double? roll,
  }) {
    return PinholeCamera(
      cameraZ: cameraZ ?? this.cameraZ,
      yaw: yaw ?? this.yaw,
      pitch: pitch ?? this.pitch,
      roll: roll ?? this.roll,
    );
  }
}

/// 핀홀 카메라 투영을 위한 클래스
class PinholeProjection {
  /// focal length in pixels
  final double focalPx;

  /// 근평면 거리 (near clipping plane)
  final double near;

  /// 원평면 거리 (far clipping plane)
  final double far;

  /// PinholeProjection 인스턴스를 생성합니다
  const PinholeProjection({
    required this.focalPx,
    required this.near,
    required this.far,
  });

  /// project view-space to screen (centered at cx, cy)
  ///
  /// [v] 뷰 공간의 3D 점
  /// [cx] 화면 중심 X 좌표
  /// [cy] 화면 중심 Y 좌표
  ///
  /// Returns 투영된 화면 좌표와 뷰 공간 Z 값
  ({double sx, double sy, double vz}) project(Vector3 v, double cx, double cy) {
    // view forward is -Z; visible if vz > near and vz < far where vz = -v.z
    final vz = -v.z;
    if (vz <= near || vz >= far) {
      return (sx: double.nan, sy: double.nan, vz: vz);
    }
    final sx = cx + focalPx * (v.x / -v.z);
    final sy = cy - focalPx * (v.y / -v.z);
    return (sx: sx, sy: sy, vz: vz);
  }
}
