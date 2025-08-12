import 'package:flutter/material.dart';

import 'package:vector_math/vector_math.dart' as vm;

import 'package:point_glass/src/models/point_glass_axis.dart';
import 'package:point_glass/src/models/point_glass_grid.dart';
import 'package:point_glass/src/models/point_glass_polygon.dart';
import 'package:point_glass/src/models/point_glass_types.dart';
import 'package:point_glass/src/models/point_glass_annual_sector.dart';
import 'package:point_glass/src/painters/point_glass_painter.dart';
import 'package:point_glass/src/models/point_glass_points.dart';
import 'package:point_glass/src/utils/view_context.dart';

abstract class PointGlassViewerBase extends StatefulWidget {
  const PointGlassViewerBase({
    super.key,
    required this.viewContext,
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

  final ValueNotifier<ViewContext> viewContext;
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
      widget.viewContext.value = widget.viewContext.value.copyWith(
        camera: widget.viewContext.value.camera.copyWith(
          roll: widget.viewContext.value.camera.roll + degrees(rotation),
        ),
      );
    });
  }

  void rotateXY(Offset delta) {
    // 민감도
    const double degPerPx = 0.25;
    setState(() {
      final newYaw =
          widget.viewContext.value.camera.yaw + delta.dx * degPerPx; // 민감도
      final newPitch =
          (widget.viewContext.value.camera.pitch - delta.dy * -degPerPx);
      widget.viewContext.value = widget.viewContext.value.copyWith(
        camera: widget.viewContext.value.camera
            .copyWith(yaw: newYaw, pitch: newPitch),
      );
    });
  }

  void scaleUpdate(double scale) {
    setState(() {
      final newZ = (widget.viewContext.value.camera.cameraZ / scale)
          .clamp(widget.minScale, widget.maxScale);
      widget.viewContext.value = widget.viewContext.value.copyWith(
        camera: widget.viewContext.value.camera.copyWith(cameraZ: newZ),
      );
    });
  }

  void translate(Offset delta) {
    setState(() {
      widget.viewContext.value = widget.viewContext.value.copyWith(
        canvasCenter: widget.viewContext.value.canvasCenter + delta,
      );
    });
  }

  void editPolygon(Offset delta) {
    if (widget.polygons == null) return;

    for (var polygon in widget.polygons!) {
      if (!polygon.selectedPolygon) {
        continue;
      }

      final worldDelta =
          widget.viewContext.value.screenToModelZ0(sx: delta.dx, sy: delta.dy);
      final origin = widget.viewContext.value.screenToModelZ0(
        sx: 0.0,
        sy: 0.0,
      );

      if (worldDelta == null || origin == null) {
        continue;
      }

      // 실제 이동량 계산
      final realDeltaX = worldDelta.x - origin.x;
      final realDeltaY = worldDelta.y - origin.y;

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
          viewContext: widget.viewContext.value,
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
