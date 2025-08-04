import 'package:point_glass/src/models/point_glass_geometry.dart';
import 'package:point_glass/src/models/point_glass_point.dart';

class PointGlassPoints extends PointGlassGeometry {
  List<PointGlassPoint> points;

  PointGlassPoints({
    super.enable,
    super.color,
    super.alpha,
    super.strokeWidth,
    this.points = const [],
  });
}
