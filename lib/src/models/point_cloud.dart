import 'package:flutter/material.dart';
import 'point_data.dart';

class PointCloud {
  /// 3D 포인트 데이터 리스트
  final List<Point3D> data;

  /// 포인트 클라우드의 기본 색상 (개별 포인트의 색상이 없을 경우 사용)
  final Color? color;

  /// 포인트의 크기
  final double? size;

  const PointCloud({required this.data, this.color, this.size = 1.0});

  /// 빈 포인트 클라우드 생성
  factory PointCloud.empty() {
    return const PointCloud(data: []);
  }

  /// 객체 복사본 생성 with 새로운 값
  PointCloud copyWith({List<Point3D>? data, Color? color, double? size}) {
    return PointCloud(
      data: data ?? this.data,
      color: color ?? this.color,
      size: size ?? this.size,
    );
  }

  /// 포인트 클라우드가 비어있는지 확인
  bool get isEmpty => data.isEmpty;

  /// 포인트 클라우드의 포인트 개수
  int get length => data.length;
}
