import 'package:flutter/material.dart';

import 'package:vector_math/vector_math.dart' as vm;

import 'package:point_glass/src/models/point_glass_axis.dart';
import 'package:point_glass/src/models/point_glass_grid.dart';
import 'package:point_glass/src/models/point_glass_polygon.dart';
import 'package:point_glass/src/models/point_glass_types.dart';
import 'package:point_glass/src/painters/point_glass_painter.dart';
import 'package:point_glass/src/utils/transform_3d.dart';

abstract class PointGlassViewerBase extends StatefulWidget {
  const PointGlassViewerBase({
    super.key,
    required this.contextStyle,
    required this.initialScale,
    required this.initialRotationX,
    required this.initialRotationY,
    required this.initialRotationZ,
    required this.minScale,
    required this.maxScale,
    required this.mode,
    this.grid,
    this.axis,
    this.polygons,
  });

  final PopupMenuStyle contextStyle;
  final double initialScale;
  final double initialRotationX;
  final double initialRotationY;
  final double initialRotationZ;
  final double minScale;
  final double maxScale;
  final PointGlassViewerMode mode;
  final PointGlassGrid? grid;
  final PointGlassAxis? axis;
  final List<PointGlassPolygon>? polygons;
}

abstract class PointGlassViewerBaseState<T extends PointGlassViewerBase>
    extends State<T> {
  late Transform3D transform;
  bool isDraggingPolygon = false;

  @override
  void initState() {
    super.initState();
    transform = Transform3D(
      scale: widget.initialScale,
      rotationX: widget.initialRotationX,
      rotationY: widget.initialRotationY,
      rotationZ: widget.initialRotationZ,
    );
  }

  // 공통 메서드들
  void rotateZ(double rotation) {
    setState(() {
      transform = transform.copyWith(
        rotationZ: transform.rotationZ + transform.degrees(rotation),
      );
    });
  }

  void rotateXY(Offset delta) {
    setState(() {
      transform = transform.copyWith(
        rotationY: transform.rotationY + delta.dx * 0.5,
        rotationX: transform.rotationX + delta.dy * -0.5,
      );
    });
  }

  void scaleUpdate(double scale) {
    final newScale = (transform.scale * scale).clamp(
      widget.minScale,
      widget.maxScale,
    );
    setState(() {
      transform = transform.copyWith(scale: newScale);
    });
  }

  void translate(Offset delta) {
    setState(() {
      transform = transform.copyWith(
        positionX: transform.positionX + delta.dx,
        positionY: transform.positionY + delta.dy,
      );
    });
  }

  void editPolygon(Offset delta) {
    if (widget.polygons == null) return;

    for (var polygon in widget.polygons!) {
      if (!polygon.selectedPolygon) {
        continue;
      }

      final (worldDeltaX, worldDeltaY) = transform.inverseTransformToPlane(
        delta.dx,
        delta.dy,
      );
      final (originX, originY) = transform.inverseTransformToPlane(0.0, 0.0);

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
          transform: transform,
          grid: widget.grid ?? PointGlassGrid(),
          axis: widget.axis ?? PointGlassAxis(),
          polygons: widget.polygons ?? [],
        ),
      ),
    );
  }
}
