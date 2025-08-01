import 'package:flutter/material.dart';

import 'package:vector_math/vector_math.dart' as vm;

import 'package:point_glass/src/models/point_glass_types.dart';
import 'point_glass_viewer_base.dart';

class PointGlassViewerMobile extends PointGlassViewerBase {
  const PointGlassViewerMobile({
    super.key,
    required super.transform,
    required super.contextStyle,
    required super.minScale,
    required super.maxScale,
    required super.mode,
    super.grid,
    super.axis,
    super.polygons,
    super.annualSectors,
  });

  @override
  State<PointGlassViewerMobile> createState() => _PointGlassViewerMobileState();
}

class _PointGlassViewerMobileState
    extends PointGlassViewerBaseState<PointGlassViewerMobile> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final center = Offset(
          size.width / 2 + widget.transform.value.positionX,
          size.height / 2 + widget.transform.value.positionY,
        );

        return GestureDetector(
          onDoubleTapDown: (details) {
            _handleMobileDoubleTap(details.localPosition, center);
          },
          onLongPressStart: (details) {
            _handleMobileLongPress(details.localPosition, center);
          },
          onScaleStart: (details) {
            _handleMobileScaleStart(details.localFocalPoint, center);
          },
          onScaleUpdate: (details) {
            _handleMobileScaleUpdate(details, center);
          },
          onScaleEnd: (details) {
            isDraggingPolygon = false;
          },
          child: buildCanvas(),
        );
      },
    );
  }

  // Polygon 선택을 위한 더블탭
  void _handleMobileDoubleTap(Offset localPosition, Offset center) {
    final x = localPosition.dx - center.dx;
    final y = localPosition.dy - center.dy;
    final point = widget.transform.value.inverseTransformToPlane(x, y);

    for (var i = 0; i < widget.polygons!.length; i++) {
      var polygon = widget.polygons![i];
      if (!polygon.isEditable) {
        continue;
      }

      if (polygon.isPointInPolygon(point.$1, point.$2)) {
        setState(() {
          if (polygon.selectedPolygon) {
            polygon.selectedPolygon = false;
          } else {
            polygon.selectedPolygon = true;
          }
        });
        return;
      }
    }

    for (var polygon in widget.polygons!) {
      setState(() {
        polygon.selectedPolygon = false;
      });
    }
  }

  // Polygon 편집 메뉴 표시를 위한 길게 누르기
  void _handleMobileLongPress(Offset localPosition, Offset center) {
    if (widget.mode != PointGlassViewerMode.editPolygon) {
      return;
    }

    if (widget.polygons == null) {
      return;
    }

    final x = localPosition.dx - center.dx;
    final y = localPosition.dy - center.dy;
    final point = widget.transform.value.inverseTransformToPlane(x, y);

    int targetPolygonIndex = -1;
    int targetVertexIndex = -1;

    for (var polygon in widget.polygons!) {
      if (!polygon.selectedPolygon) {
        continue;
      }

      int? vertexIdx = polygon.getClickedVertexIndex(
        point.$1,
        point.$2,
        widget.transform.value.scale,
      );

      if (vertexIdx != null && polygon.points.length <= 3) {
        continue;
      }

      targetPolygonIndex = widget.polygons!.indexOf(polygon);
      targetVertexIndex = vertexIdx ?? -1;
      break;
    }

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        localPosition.dx,
        localPosition.dy,
        localPosition.dx,
        localPosition.dy,
      ),
      color: widget.contextStyle.backgroundColor,
      items: [
        ...(targetVertexIndex == -1
            ? [
                PopupMenuItem(
                  value: 0,
                  child: Text(
                    'Add Point',
                    style: widget.contextStyle.textStyle,
                  ),
                ),
              ]
            : [
                PopupMenuItem(
                  value: 1,
                  child: Text(
                    'Delete Point',
                    style: widget.contextStyle.textStyle,
                  ),
                ),
              ]),
      ],
    ).then((value) {
      switch (value) {
        // add point
        case 0:
          final edgeIndex = widget.polygons![targetPolygonIndex]
              .findClosestEdge(point.$1, point.$2);

          setState(() {
            widget.polygons![targetPolygonIndex].points.insert(
              edgeIndex + 1,
              vm.Vector3(point.$1, point.$2, 0.0),
            );
          });
          break;
        // delete point
        case 1:
          setState(() {
            widget.polygons![targetPolygonIndex].points.removeAt(
              targetVertexIndex,
            );
          });
          break;
      }
    });
  }

  // Polygon 편집을 위한 드래그 시작
  void _handleMobileScaleStart(Offset localPosition, Offset center) {
    final x = localPosition.dx - center.dx;
    final y = localPosition.dy - center.dy;
    final point = widget.transform.value.inverseTransformToPlane(x, y);

    isDraggingPolygon = false;
    for (var i = 0; i < widget.polygons!.length; i++) {
      var polygon = widget.polygons![i];
      if (!polygon.isEditable) {
        continue;
      }

      if (!polygon.selectedPolygon) {
        continue;
      }

      int? vertexIdx = polygon.getClickedVertexIndex(
        point.$1,
        point.$2,
        widget.transform.value.scale,
      );
      if (vertexIdx != null) {
        isDraggingPolygon = true;
        polygon.selectedVertexIndex = vertexIdx;
        break;
      } else {
        if (polygon.isPointInPolygon(point.$1, point.$2)) {
          isDraggingPolygon = true;
          polygon.selectedVertexIndex = -1;
          break;
        }
      }
    }
  }

  // 드래그 업데이트
  // 화면 확대/축소, 화면 이동, 화면 회전, Polygon 편집
  void _handleMobileScaleUpdate(ScaleUpdateDetails details, Offset center) {
    if (details.scale != 1.0) {
      final scrollFactor = details.scale > 1.0 ? 1.02 : 0.98;
      scaleUpdate(scrollFactor);
      return;
    }

    if (widget.mode == PointGlassViewerMode.translate) {
      // 화면 이동
      if (details.focalPointDelta != Offset.zero) {
        translate(details.focalPointDelta);
      }
    } else if (widget.mode == PointGlassViewerMode.spin) {
      // Z축 기준 회전 (X축 방향으로 이동 시 동작)
      if (details.focalPointDelta != Offset.zero) {
        rotateZ(
          widget.transform.value.radians(details.focalPointDelta.dx * 0.1),
        );
      }
    } else if (widget.mode == PointGlassViewerMode.editPolygon) {
      // 폴리곤 편집
      if (isDraggingPolygon) {
        if (details.focalPointDelta != Offset.zero) {
          editPolygon(details.focalPointDelta);
        }
      }
    } else {
      // 화면 회전
      if (details.rotation != 0) {
        rotateZ(details.rotation);
      }

      if (details.focalPointDelta != Offset.zero) {
        rotateXY(details.focalPointDelta);
      }
    }
  }
}
