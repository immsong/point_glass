import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vector_math/vector_math.dart' as vm;

import 'package:point_glass/src/models/point_glass_types.dart';
import 'point_glass_viewer_base.dart';

class PointGlassViewerDesktop extends PointGlassViewerBase {
  const PointGlassViewerDesktop({
    super.key,
    required super.viewContext,
    required super.contextStyle,
    required super.minScale,
    required super.maxScale,
    required super.mode,
    super.grid,
    super.axis,
    super.polygons,
    super.annualSectors,
    super.pointsGroup,
  });

  @override
  State<PointGlassViewerDesktop> createState() =>
      _PointGlassViewerDesktopState();
}

class _PointGlassViewerDesktopState
    extends PointGlassViewerBaseState<PointGlassViewerDesktop> {
  DateTime _lastPointerDownTime = DateTime.now();

  Offset _lastPointerDownPosition = Offset.zero;

  Timer? _hoverTimer;

  Timer? _longPressTimer;

  bool _isShiftPressed = false;
  bool _isCtrlPressed = false;

  @override
  void initState() {
    super.initState();

    ServicesBinding.instance.keyboard.addHandler((event) {
      if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
          event.logicalKey == LogicalKeyboardKey.shiftRight) {
        setState(() {
          _isShiftPressed = event is KeyDownEvent;
        });
        return true;
      }

      if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight) {
        setState(() {
          _isCtrlPressed = event is KeyDownEvent;
        });
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final center = Offset(
          size.width / 2 + widget.viewContext.value.canvasCenter.dx,
          size.height / 2 + widget.viewContext.value.canvasCenter.dy,
        );

        return Listener(
          onPointerSignal: _handlePointerSignal,
          onPointerDown: (details) => _handlePointerDown(details, center),
          onPointerMove: (details) => _handlePointerMove(details, center),
          onPointerHover: (details) => _handlePointerHover(details, center),
          onPointerUp: (details) => _handlePointerUp(details, center),
          child: buildCanvas(),
        );
      },
    );
  }

  // 마우스 휠 스크롤 처리
  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final scrollFactor = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
      scaleUpdate(scrollFactor);
    }
  }

  // 마우스 오른쪽, 왼쪽 클릭, 더블 클릭, 길게 누르기
  void _handlePointerDown(PointerDownEvent details, Offset center) {
    if (details.buttons != kPrimaryMouseButton) {
      if (details.buttons == kSecondaryMouseButton) {
        // web의 경우 오른쪽 클릭 시 웹의 기본 메뉴가 표시되므로 Long Press 로 처리
        if (!kIsWeb) {
          _handleMouseSecondaryClick(details.localPosition, center);
        }
      }

      return;
    }

    _longPressTimer?.cancel();
    _longPressTimer = Timer(Duration(milliseconds: 500), () {
      _handleMouseSecondaryClick(details.localPosition, center);
    });

    Offset localPosition = details.localPosition;
    DateTime now = DateTime.now();
    if (localPosition == _lastPointerDownPosition) {
      int duration = now.difference(_lastPointerDownTime).inMilliseconds;

      _lastPointerDownPosition = localPosition;
      _lastPointerDownTime = now;

      if (duration < 500) {
        _handleMouseDoubleClick(localPosition, center);
        _lastPointerDownTime = _lastPointerDownTime.add(
          Duration(milliseconds: -500),
        );
        return;
      }
    }

    _lastPointerDownPosition = localPosition;
    _lastPointerDownTime = now;
    _handleMouseDragStart(localPosition, center);
  }

  void _handlePointerUp(PointerUpEvent details, Offset center) {
    _longPressTimer?.cancel();
  }

  // 마우스 드래그 처리
  void _handlePointerMove(PointerMoveEvent details, Offset center) {
    _longPressTimer?.cancel();

    if (_isShiftPressed || widget.mode == PointGlassViewerMode.translate) {
      // 화면 이동
      if (details.delta != Offset.zero) {
        translate(details.delta);
      }
    } else if (_isCtrlPressed || widget.mode == PointGlassViewerMode.spin) {
      // Z축 기준 회전 (X축 방향으로 이동 시 동작)
      if (details.delta != Offset.zero) {
        rotateZ(details.delta.dx > 0 ? 0.1 : -0.1);
      }
    } else if (widget.mode == PointGlassViewerMode.editPolygon) {
      // 폴리곤 편집
      if (isDraggingPolygon) {
        if (details.delta != Offset.zero) {
          editPolygon(details.delta);
        }
      }
    } else {
      // 화면 회전
      if (details.delta != Offset.zero) {
        rotateXY(details.delta);
      }
    }
  }

  // 마우스 커서 호버, 100ms 동안 마우스 커서가 움직이지 않으면 호버 처리
  void _handlePointerHover(PointerHoverEvent details, Offset center) {
    // 이전 타이머 취소
    _hoverTimer?.cancel();

    // 100ms 후에 실행 (너무 빈번한 호출 방지)
    _hoverTimer = Timer(Duration(milliseconds: 100), () {
      _handleMouseHover(details.localPosition, center);
    });
  }

  // Polygon 선택을 위한 더블 클릭
  void _handleMouseDoubleClick(Offset localPosition, Offset center) {
    if (widget.polygons == null) {
      return;
    }

    for (var i = 0; i < widget.polygons!.length; i++) {
      var polygon = widget.polygons![i];
      if (!polygon.isEditable) {
        continue;
      }

      final x = localPosition.dx - center.dx;
      final y = localPosition.dy - center.dy;
      final point = widget.viewContext.value.screenToModelZ0(sx: x, sy: y);

      if (point == null) {
        continue;
      }

      if (polygon.isPointInPolygon(point.x, point.y)) {
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

  // Polygon 편집 메뉴 표시를 위한 오른쪽 클릭
  // Web 에서는 오른쪽 클릭 시 웹의 기본 메뉴가 표시되므로 Long Press 로 처리
  void _handleMouseSecondaryClick(Offset localPosition, Offset center) {
    if (widget.mode != PointGlassViewerMode.editPolygon) {
      return;
    }

    if (widget.polygons == null) {
      return;
    }

    final x = localPosition.dx - center.dx;
    final y = localPosition.dy - center.dy;
    final point = widget.viewContext.value.screenToModelZ0(sx: x, sy: y);

    if (point == null) {
      return;
    }

    int targetPolygonIndex = -1;
    int targetVertexIndex = -1;

    for (var polygon in widget.polygons!) {
      if (!polygon.selectedPolygon) {
        continue;
      }

      int? vertexIdx = polygon.getClickedVertexIndex(
        point.x,
        point.y,
      );

      if (vertexIdx != null && polygon.points.length <= 3) {
        continue;
      }

      targetPolygonIndex = widget.polygons!.indexOf(polygon);
      targetVertexIndex = vertexIdx ?? -1;
      break;
    }

    if (targetPolygonIndex == -1) {
      return;
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
                  value: 'add_point',
                  child: Text(
                    'Add Point',
                    style: widget.contextStyle.textStyle,
                  ),
                ),
              ]
            : [
                PopupMenuItem(
                  value: 'delete_point',
                  child: Text(
                    'Delete Point',
                    style: widget.contextStyle.textStyle,
                  ),
                ),
              ]),
      ],
    ).then((value) {
      if (value == 'add_point') {
        final edgeIndex = widget.polygons![targetPolygonIndex].findClosestEdge(
          point.x,
          point.y,
        );

        setState(() {
          widget.polygons![targetPolygonIndex].points.insert(
            edgeIndex + 1,
            vm.Vector3(point.x, point.y, 0.0),
          );
        });
      } else if (value == 'delete_point') {
        setState(() {
          widget.polygons![targetPolygonIndex].points.removeAt(
            targetVertexIndex,
          );
        });
      }
    });
  }

  // Polygon 편집을 위한 드래그 시작
  void _handleMouseDragStart(Offset localPosition, Offset center) {
    final x = localPosition.dx - center.dx;
    final y = localPosition.dy - center.dy;
    final point = widget.viewContext.value.screenToModelZ0(sx: x, sy: y);

    isDraggingPolygon = false;
    if (widget.polygons == null) {
      return;
    }

    for (var i = 0; i < widget.polygons!.length; i++) {
      var polygon = widget.polygons![i];
      if (!polygon.isEditable) {
        continue;
      }

      if (!polygon.selectedPolygon) {
        continue;
      }

      if (point == null) {
        continue;
      }

      int? vertexIdx = polygon.getClickedVertexIndex(
        point.x,
        point.y,
      );
      if (vertexIdx != null) {
        isDraggingPolygon = true;
        polygon.selectedVertexIndex = vertexIdx;
        break;
      } else {
        if (polygon.isPointInPolygon(point.x, point.y)) {
          isDraggingPolygon = true;
          polygon.selectedVertexIndex = -1;
          break;
        }
      }
    }
  }

  // Polygon 편집 중일 때, 꼭지점에 마우스를 호버시키면 꼭지점이 2배 커짐
  void _handleMouseHover(Offset localPosition, Offset center) {
    if (widget.mode != PointGlassViewerMode.editPolygon) {
      return;
    }

    int targetPolygonIndex = -1;
    for (var polygon in widget.polygons!) {
      if (!polygon.selectedPolygon) {
        continue;
      }

      targetPolygonIndex = widget.polygons!.indexOf(polygon);
      break;
    }

    if (targetPolygonIndex == -1) {
      return;
    }

    final x = localPosition.dx - center.dx;
    final y = localPosition.dy - center.dy;
    final point = widget.viewContext.value.screenToModelZ0(sx: x, sy: y);

    if (point == null) {
      return;
    }

    int? vertexIdx = widget.polygons![targetPolygonIndex].getClickedVertexIndex(
      point.x,
      point.y,
    );

    setState(() {
      if (vertexIdx != null) {
        widget.polygons![targetPolygonIndex].hoveredVertexIndex = vertexIdx;
      } else {
        if (widget.polygons != null) {
          for (var polygon in widget.polygons!) {
            polygon.hoveredVertexIndex = -1;
          }
        }
      }
    });
  }
}
