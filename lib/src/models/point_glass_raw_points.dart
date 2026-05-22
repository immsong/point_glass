import 'dart:typed_data';

import 'package:point_glass/src/utils/color_map.dart';

/// Float32List 기반 raw 포인트 클라우드 데이터를 보관하는 클래스입니다.
class PointGlassRawPoints {
  /// 렌더링 활성화 여부
  final bool enable;

  /// stride 개의 float 값이 포인트 수만큼 연속 배치된 평탄화 버퍼
  final Float32List buf;

  /// 포인트 1개당 float 값 개수
  final int stride;

  /// 필드 이름 → 버퍼 내 인덱스 오프셋 맵 (예: {'x': 0, 'y': 1, 'z': 2})
  final Map<String, int> fields;

  /// 색상 맵
  final ColorMap colorMap;

  /// 색상 매핑에 사용할 필드 이름 (기본값 'distance')
  /// distance 의 경우  필드에 없어도 자동으로 계산하여 사용합니다. (거리 계산은 x, y, z 필드 필요)
  final String colorField;

  /// 색상 맵 최솟값
  final double colorMin;

  /// 색상 맵 최댓값
  final double colorMax;

  /// 포인트 크기
  final double strokeWidth;

  /// 투명도 (0~255)
  final int alpha;

  const PointGlassRawPoints({
    this.enable = true,
    required this.buf,
    required this.stride,
    required this.fields,
    this.colorMap = ColorMap.turbo,
    this.colorField = 'distance',
    this.colorMin = 0,
    this.colorMax = 255,
    this.strokeWidth = 2.0,
    this.alpha = 255,
  });
}
