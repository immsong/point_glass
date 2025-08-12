import 'dart:math';

import 'package:flutter/material.dart';

import 'package:point_glass/src/utils/camera.dart';
import 'package:vector_math/vector_math.dart' as vm;

class ViewContext {
  final ModelTransform model;
  final PinholeCamera camera;
  final PinholeProjection proj;
  final Offset canvasCenter;

  // 캐시 변수들
  late vm.Matrix4 _cachedModelMatrix;
  late vm.Matrix4 _cachedViewMatrix;
  bool _modelDirty = true;
  bool _viewDirty = true;

  ViewContext({
    this.model = const ModelTransform(),
    this.camera = const PinholeCamera(cameraZ: 500.0),
    this.proj =
        const PinholeProjection(focalPx: 800.0, near: 1.0, far: 20000.0),
    this.canvasCenter = const Offset(0, 0),
  }) {
    // 캐싱 변수 초기화
    _cachedModelMatrix = vm.Matrix4.identity();
    _cachedViewMatrix = vm.Matrix4.identity();
    _modelDirty = true;
    _viewDirty = true;
  }

  ViewContext copyWith({
    ModelTransform? model,
    PinholeCamera? camera,
    PinholeProjection? proj,
    Offset? canvasCenter,
  }) {
    // 모델이나 카메라가 변경되면 dirty flag 설정
    final newModel = model ?? this.model;
    final newCamera = camera ?? this.camera;

    return ViewContext(
      model: newModel,
      camera: newCamera,
      proj: proj ?? this.proj,
      canvasCenter: canvasCenter ?? this.canvasCenter,
    ).._updateDirtyFlags(
        modelChanged: model != null && model != this.model, // 실제 변경 확인
        cameraChanged: camera != null && camera != this.camera, // 실제 변경 확인
      );
  }

  void _updateDirtyFlags({
    required bool modelChanged,
    required bool cameraChanged,
  }) {
    if (modelChanged) _modelDirty = true;
    if (cameraChanged) _viewDirty = true;
  }

  // 캐시된 행렬 접근자
  vm.Matrix4 get _m {
    if (_modelDirty) {
      _cachedModelMatrix = model.modelMatrix();
      _modelDirty = false;
    }
    return _cachedModelMatrix;
  }

  vm.Matrix4 get _v {
    if (_viewDirty) {
      _cachedViewMatrix = camera.viewMatrix();
      _viewDirty = false;
    }
    return _cachedViewMatrix;
  }

  // world -> screen
  ({Offset? p, double vz}) projectWorld(vm.Vector3 world) {
    final vv = _v.transform3(world);
    final pr = proj.project(vv, canvasCenter.dx, canvasCenter.dy);
    final p = pr.sx.isNaN ? null : Offset(pr.sx, pr.sy);
    return (p: p, vz: pr.vz);
  }

  // model -> screen (y 반전 기본)
  ({Offset? p, double vz}) projectModel(double x, double y, double z,
      {bool invertY = false}) {
    final wp = _m.transform3(vm.Vector3(x, invertY ? -y : y, z));
    return projectWorld(wp);
  }

  // 가시성(near/far) 체크
  bool isVisibleVz(double vz, {double eps = 1e-6}) {
    return vz > proj.near + eps && vz < proj.far - eps;
  }

  // 폴리곤 백페이스 컬링(모델 점 리스트 기준)
  bool isBackFaceModel(List<vm.Vector3> modelPts, {bool invertY = true}) {
    if (modelPts.length < 3) return true;
    final a = _v.transform3(_m.transform3(vm.Vector3(modelPts[0].x,
        invertY ? -modelPts[0].y : modelPts[0].y, modelPts[0].z)));
    final b = _v.transform3(_m.transform3(vm.Vector3(modelPts[1].x,
        invertY ? -modelPts[1].y : modelPts[1].y, modelPts[1].z)));
    final c = _v.transform3(_m.transform3(vm.Vector3(modelPts[2].x,
        invertY ? -modelPts[2].y : modelPts[2].y, modelPts[2].z)));
    final n = (b - a).cross(c - a);
    return n.z >= 0.0; // 카메라는 -Z를 본다고 가정
  }

  // 깊이 메트릭(평균/최대)
  double depthFromVzList(List<double> vzList, {bool useMax = false}) {
    if (vzList.isEmpty) return double.negativeInfinity;
    if (useMax) return vzList.reduce((a, b) => a > b ? a : b);
    final sum = vzList.reduce((a, b) => a + b);
    return sum / vzList.length;
  }

  // 레이 생성(화면 좌표 → world 레이)
  // sx, sy는 canvasCenter 기준 좌표여야 함
  ({vm.Vector3 origin, vm.Vector3 dir}) screenRay(
      {required double sx, required double sy}) {
    final f = proj.focalPx;
    final dirView = vm.Vector3(sx / f, -sy / f, -1.0)..normalize();
    final invV = vm.Matrix4.inverted(_v);
    final origin = invV.transform3(vm.Vector3.zero());
    final dirW4 =
        invV.transform(vm.Vector4(dirView.x, dirView.y, dirView.z, 0.0));
    final dir = vm.Vector3(dirW4.x, dirW4.y, dirW4.z)..normalize();
    return (origin: origin, dir: dir);
  }

  // 모델 z=0 평면과 교차하여 모델 좌표로 반환(픽킹용)
  vm.Vector3? screenToModelZ0({required double sx, required double sy}) {
    sx = sx - canvasCenter.dx;
    sy = sy - canvasCenter.dy;

    final planePointW = _m.transform3(vm.Vector3.zero());
    final nW4 = _m.transform(vm.Vector4(0.0, 0.0, 1.0, 0.0));
    final nW = vm.Vector3(nW4.x, nW4.y, nW4.z)..normalize();

    final ray = screenRay(sx: sx, sy: sy);
    const eps = 1e-8;
    final denom = nW.dot(ray.dir);
    if (denom.abs() < eps) return null;
    final t = nW.dot(planePointW - ray.origin) / denom;
    final hitW = ray.origin + ray.dir.scaled(t);

    final invM = vm.Matrix4.inverted(_m);
    final hitM = invM.transform3(hitW);
    return vm.Vector3(hitM.x, hitM.y, 0.0);
  }
}

double radians(double deg) => deg * (pi / 180.0);
double degrees(double radians) => radians * (180.0 / pi);
