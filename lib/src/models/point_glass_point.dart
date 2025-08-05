import 'package:vector_math/vector_math.dart' as vm;

import 'package:point_glass/src/models/point_glass_geometry.dart';

/// 3D Point의 설정을 정의하는 클래스입니다.
class PointGlassPoint extends PointGlassGeometry {
  /// 3D Point 좌표
  final vm.Vector3 point;

  PointGlassPoint({
    super.enable,
    super.color,
    super.alpha,
    super.strokeWidth,
    required this.point,
  });
}
