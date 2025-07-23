import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:point_glass/src/models/point_cloud.dart';
import 'package:point_glass/src/painters/point_cloud_painter.dart';
import 'package:point_glass/src/utils/transform_3d.dart';
import 'package:point_glass/src/painters/grid_painter.dart';
import 'package:point_glass/src/models/grid_config.dart';

class PointCloudViewer extends StatefulWidget {
  final List<PointCloud> clouds;
  final double initialScale;
  final double initialRotationX;
  final double initialRotationY;
  final double initialRotationZ;
  final double minScale;
  final double maxScale;
  final GridConfig gridConfig;

  const PointCloudViewer({
    super.key,
    required this.clouds,
    this.initialScale = 100.0,
    this.initialRotationX = 0.0,
    this.initialRotationY = 0.0,
    this.initialRotationZ = 0.0,
    this.minScale = 5.0,
    this.maxScale = 1000.0,
    this.gridConfig = const GridConfig(),
  });

  @override
  State<PointCloudViewer> createState() => _PointCloudViewerState();
}

class _PointCloudViewerState extends State<PointCloudViewer> {
  late Transform3D _transform;
  final _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _transform = Transform3D(
      scale: widget.initialScale,
      rotationX: widget.initialRotationX,
      rotationY: widget.initialRotationY,
      rotationZ: widget.initialRotationZ,
    );
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // 회전 처리
      if (details.rotation != 0) {
        _transform = _transform.copyWith(
          rotationZ: _transform.rotationZ + details.rotation * (180 / 3.14),
        );
      }

      // 이동 처리
      if (details.focalPointDelta != Offset.zero) {
        _transform = _transform.copyWith(
          rotationY: _transform.rotationY + details.focalPointDelta.dx * 0.5,
          rotationX: _transform.rotationX + details.focalPointDelta.dy * -0.5,
        );
      }

      // 확대/축소 처리
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
          painter: GridPainter(
            config: widget.gridConfig,
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
    _transformationController.dispose();
    super.dispose();
  }
}
