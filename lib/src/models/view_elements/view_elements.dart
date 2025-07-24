import 'package:point_glass/src/models/view_elements/view_grid.dart';
import 'package:point_glass/src/models/view_elements/view_axis.dart';
import 'package:point_glass/src/models/view_elements/view_polygon_plane.dart';
import 'package:point_glass/src/models/view_elements/view_range.dart';

class ViewElements {
  final ViewGrid grid;
  final ViewAxis axis;
  final ViewRange range;
  final List<ViewPolygonPlane> polygonPlanes;

  const ViewElements({
    this.grid = const ViewGrid(),
    this.axis = const ViewAxis(),
    this.range = const ViewRange(),
    this.polygonPlanes = const [],
  });
}
