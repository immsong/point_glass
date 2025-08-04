import 'package:flutter/material.dart';

import 'package:vector_math/vector_math.dart' as vm;

import 'package:point_glass/src/models/point_glass_axis.dart';
import 'package:point_glass/src/models/point_glass_grid.dart';
import 'package:point_glass/src/models/point_glass_polygon.dart';
import 'package:point_glass/src/models/point_glass_types.dart';
import 'package:point_glass/src/models/point_glass_annual_sector.dart';
import 'package:point_glass/src/painters/point_glass_painter.dart';
import 'package:point_glass/src/models/point_glass_points.dart';
import 'package:point_glass/src/utils/transform_3d.dart';

abstract class PointGlassViewerBase extends StatefulWidget {
  const PointGlassViewerBase({
    super.key,
    required this.transform,
    required this.contextStyle,
    required this.minScale,
    required this.maxScale,
    required this.mode,
    this.grid,
    this.axis,
    this.polygons,
    this.annualSectors,
    this.pointsGroup,
  });

  final ValueNotifier<Transform3D> transform;
  final PopupMenuStyle contextStyle;
  final double minScale;
  final double maxScale;
  final PointGlassViewerMode mode;
  final PointGlassGrid? grid;
  final PointGlassAxis? axis;
  final List<PointGlassPolygon>? polygons;
  final List<PointGlassAnnualSector>? annualSectors;
  final List<PointGlassPoints>? pointsGroup;
}

abstract class PointGlassViewerBaseState<T extends PointGlassViewerBase>
    extends State<T> {
  bool isDraggingPolygon = false;

  @override
  void initState() {
    super.initState();
  }

  // 공통 메서드들
  void rotateZ(double rotation) {
    setState(() {
      widget.transform.value = widget.transform.value.copyWith(
        rotationZ:
            widget.transform.value.rotationZ +
            widget.transform.value.degrees(rotation),
      );
    });
  }

  void rotateXY(Offset delta) {
    setState(() {
      widget.transform.value = widget.transform.value.copyWith(
        rotationY: widget.transform.value.rotationY + delta.dx * 0.5,
        rotationX: widget.transform.value.rotationX + delta.dy * -0.5,
      );
    });
  }

  void scaleUpdate(double scale) {
    final newScale = (widget.transform.value.scale * scale).clamp(
      widget.minScale,
      widget.maxScale,
    );
    setState(() {
      widget.transform.value = widget.transform.value.copyWith(scale: newScale);
    });
  }

  void translate(Offset delta) {
    setState(() {
      widget.transform.value = widget.transform.value.copyWith(
        positionX: widget.transform.value.positionX + delta.dx,
        positionY: widget.transform.value.positionY + delta.dy,
      );
    });
  }

  void editPolygon(Offset delta) {
    if (widget.polygons == null) return;

    for (var polygon in widget.polygons!) {
      if (!polygon.selectedPolygon) {
        continue;
      }

      final (worldDeltaX, worldDeltaY) = widget.transform.value
          .inverseTransformToPlane(delta.dx, delta.dy);
      final (originX, originY) = widget.transform.value.inverseTransformToPlane(
        0.0,
        0.0,
      );

      // 실제 이동량 계산
      final realDeltaX = worldDeltaX - originX;
      final realDeltaY = worldDeltaY - originY;

      int selectedVertexIndex = polygon.selectedVertexIndex;
      if (selectedVertexIndex == -1) {
        setState(() {
          polygon.points = polygon.points
              .map((point) => point + vm.Vector3(realDeltaX, realDeltaY, 0.0))
              .toList();
        });
      } else {
        setState(() {
          polygon.points[selectedVertexIndex] =
              polygon.points[selectedVertexIndex] +
              vm.Vector3(realDeltaX, realDeltaY, 0.0);
        });
      }
    }
  }

  // 공통 캔버스
  Widget buildCanvas() {
    return SizedBox.expand(
      child: CustomPaint(
        painter: PointGlassPainter(
          transform: widget.transform.value,
          grid: widget.grid ?? PointGlassGrid(),
          axis: widget.axis ?? PointGlassAxis(),
          polygons: widget.polygons ?? [],
          annualSectors: widget.annualSectors ?? [],
          pointsGroup: widget.pointsGroup ?? [],
        ),
      ),
    );
  }
}
