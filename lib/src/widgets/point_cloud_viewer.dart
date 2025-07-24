import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 추가: 키보드 이벤트를 위해

import 'package:point_glass/src/models/point_cloud/point_cloud.dart';
import 'package:point_glass/src/painters/point_cloud_painter.dart';
import 'package:point_glass/src/utils/transform_3d.dart';
import 'package:point_glass/src/painters/view_elements_painter.dart';
import 'package:point_glass/src/models/view_elements/view_elements.dart';

enum PointCloudViewerMode { normal, translate }

class PointCloudViewer extends StatefulWidget {
  final List<PointCloud> clouds;
  final double initialScale;
  final double initialRotationX;
  final double initialRotationY;
  final double initialRotationZ;
  final double minScale;
  final double maxScale;
  final ViewElements viewElements;
  final PointCloudViewerMode mode;

  const PointCloudViewer({
    super.key,
    required this.clouds,
    this.initialScale = 100.0,
    this.initialRotationX = 0.0,
    this.initialRotationY = 0.0,
    this.initialRotationZ = 0.0,
    this.maxScale = 1000.0,
    this.minScale = 5.0,
    this.viewElements = const ViewElements(),
    this.mode = PointCloudViewerMode.normal,
  });

  @override
  State<PointCloudViewer> createState() => _PointCloudViewerState();
}

class _PointCloudViewerState extends State<PointCloudViewer> {
  late Transform3D _transform;
  final _transformationController = TransformationController();
  bool _isShiftPressed = false; // 추가: shift 키 상태 추적

  @override
  void initState() {
    super.initState();
    ServicesBinding.instance.keyboard.addHandler(_handleKeyEvent);
    _transform = Transform3D(
      scale: widget.initialScale,
      rotationX: widget.initialRotationX,
      rotationY: widget.initialRotationY,
      rotationZ: widget.initialRotationZ,
    );
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
        event.logicalKey == LogicalKeyboardKey.shiftRight) {
      setState(() {
        _isShiftPressed = event is KeyDownEvent;
      });
      return true;
    }
    return false;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // widget.mode가 translate이거나 shift가 눌렸을 때 translate 모드로 동작
      if (widget.mode == PointCloudViewerMode.translate || _isShiftPressed) {
        // 이동 모드
        if (details.focalPointDelta != Offset.zero) {
          _transform = _transform.copyWith(
            positionX: _transform.positionX + details.focalPointDelta.dx,
            positionY: _transform.positionY + details.focalPointDelta.dy,
          );
        }
      } else {
        // 기존 회전 모드
        if (details.rotation != 0) {
          _transform = _transform.copyWith(
            rotationZ: _transform.rotationZ + details.rotation * (180 / 3.14),
          );
        }

        if (details.focalPointDelta != Offset.zero) {
          _transform = _transform.copyWith(
            rotationY: _transform.rotationY + details.focalPointDelta.dx * 0.5,
            rotationX: _transform.rotationX + details.focalPointDelta.dy * -0.5,
          );
        }
      }

      // 확대/축소 처리 (모든 모드에서 동작)
      if (details.scale != 1.0) {
        final newScale = (_transform.scale * details.scale).clamp(
          widget.minScale,
          widget.maxScale,
        );
        _transform = _transform.copyWith(scale: newScale);
      }
    });
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final scaleFactor = event.scrollDelta.dy > 0 ? 0.9 : 1.1;

      setState(() {
        final newScale = (_transform.scale * scaleFactor).clamp(
          widget.minScale,
          widget.maxScale,
        );
        _transform = _transform.copyWith(scale: newScale);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: GestureDetector(
        onScaleUpdate: _handleScaleUpdate,
        child: CustomPaint(
          painter: ViewElementsPainter(
            viewElements: widget.viewElements,
            transform: _transform,
          ),
          foregroundPainter: PointCloudPainter(
            clouds: widget.clouds,
            transform: _transform,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_handleKeyEvent);
    _transformationController.dispose();
    super.dispose();
  }
}
