import 'package:point_glass/src/models/point_glass_geometry.dart';
import 'package:point_glass/src/models/point_glass_point.dart';

/// 3D Point 클라우드의 설정을 정의하는 클래스입니다.
class PointGlassPoints extends PointGlassGeometry {
  /// 3D Point 클라우드 리스트
  List<PointGlassPoint> points;

  PointGlassPoints({
    super.enable,
    super.color,
    super.alpha,
    super.strokeWidth,
    this.points = const [],
  });
}
