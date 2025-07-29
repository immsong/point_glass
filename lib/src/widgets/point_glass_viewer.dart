import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:point_glass/src/models/point_glass_axis.dart';
import 'package:point_glass/src/models/point_glass_grid.dart';
import 'package:point_glass/src/models/point_glass_polygon.dart';
import 'package:point_glass/src/painters/point_glass_painter.dart';
import 'package:point_glass/src/utils/transform_3d.dart';

enum PointGlassViewerMode { none, rotate, translate, spin }

class PointGlassViewer extends StatefulWidget {
  const PointGlassViewer({
    super.key,
    this.initialScale = 50.0,
    this.initialRotationX = 0.0,
    this.initialRotationY = 0.0,
    this.initialRotationZ = 0.0,
    this.minScale = 10.0,
    this.maxScale = 10000.0,
    this.mode = PointGlassViewerMode.rotate,
    this.grid,
    this.axis,
    this.polygons,
  });

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

  @override
  State<PointGlassViewer> createState() => _PointGlassViewerState();
}

class _PointGlassViewerState extends State<PointGlassViewer> {
  late Transform3D _transform;

  // shift 키를 누르고 있는 동안에는 translate 모드로 변경
  bool _isShiftPressed = false;

  // ctrl 키를 누르고 있는 동안에는 spin 모드로 변경
  bool _isCtrlPressed = false;

  @override
  void initState() {
    super.initState();
    _transform = Transform3D(
      scale: widget.initialScale,
      rotationX: widget.initialRotationX,
      rotationY: widget.initialRotationY,
      rotationZ: widget.initialRotationZ,
    );

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
    return Listener(
      onPointerSignal: _handlePointerSignal, // 마우스 스크롤
      child: GestureDetector(
        onScaleUpdate: _handleScaleUpdate, // 핀치 줌, 드레그 앤 드롭
        child: SizedBox.expand(
          child: CustomPaint(
            painter: PointGlassPainter(
              transform: _transform,
              grid: widget.grid ?? PointGlassGrid(),
              axis: widget.axis ?? PointGlassAxis(),
                  polygons: widget.polygons ?? [],
            ),
          ),
        ),
      ),
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final scrollFactor = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
      _scaleUpdate(scrollFactor);
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_isShiftPressed || widget.mode == PointGlassViewerMode.translate) {
      // 화면 이동
      if (details.focalPointDelta != Offset.zero) {
        _translate(details.focalPointDelta);
      }
    } else if (_isCtrlPressed || widget.mode == PointGlassViewerMode.spin) {
      // Z축 기준 회전 (X축 방향으로 이동 시 동작)
      if (details.focalPointDelta != Offset.zero) {
        _rotateZ(_transform.radians(details.focalPointDelta.dx * 0.1));
      }
    } else {
      // 화면 회전
      if (details.rotation != 0) {
        _rotateZ(details.rotation);
      }

      if (details.focalPointDelta != Offset.zero) {
        _rotateXY(details.focalPointDelta);
      }
    }

    // 모든 요청에서 scale 확인
    if (details.scale != 1.0) {
      _scaleUpdate(details.scale);
    }
  }

  void _rotateZ(double rotation) {
    setState(() {
      _transform = _transform.copyWith(
        rotationZ: _transform.rotationZ + _transform.degrees(rotation),
      );
    });
  }

  void _rotateXY(Offset delta) {
    setState(() {
      _transform = _transform.copyWith(
        rotationY: _transform.rotationY + delta.dx * 0.5,
        rotationX: _transform.rotationX + delta.dy * -0.5,
      );
    });
  }

  void _scaleUpdate(double scale) {
    final newScale = (_transform.scale * scale).clamp(
      widget.minScale,
      widget.maxScale,
    );
    setState(() {
      _transform = _transform.copyWith(scale: newScale);
    });
  }

  void _translate(Offset delta) {
    setState(() {
      _transform = _transform.copyWith(
        positionX: _transform.positionX + delta.dx,
        positionY: _transform.positionY + delta.dy,
      );
    });
  }
}
