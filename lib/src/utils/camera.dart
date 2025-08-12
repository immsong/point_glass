import 'package:vector_math/vector_math.dart';

class ModelTransform {
  final double scale;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  const ModelTransform({
    this.scale = 1.0,
    this.rotationX = 0.0,
    this.rotationY = 0.0,
    this.rotationZ = 0.0,
  });
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

class PinholeProjection {
  final double focalPx; // focal length in pixels
  final double near;
  final double far;
  const PinholeProjection({
    required this.focalPx,
    required this.near,
    required this.far,
  });
  // project view-space to screen (centered at cx, cy)
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
