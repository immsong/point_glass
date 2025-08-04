import 'package:vector_math/vector_math.dart' as vm;

import 'package:point_glass/src/models/point_glass_geometry.dart';

class PointGlassPoint extends PointGlassGeometry {
  final vm.Vector3 point;

  PointGlassPoint({
    super.enable,
    super.color,
    super.alpha,
    super.strokeWidth,
    required this.point,
  });
}
