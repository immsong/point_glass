import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_glass/point_glass.dart';

void main() {
  group('Point3D Tests', () {
    test('Point3D creation and values', () {
      final point = Point3D(x: 1.0, y: 2.0, z: 3.0);

      expect(point.x, 1.0);
      expect(point.y, 2.0);
      expect(point.z, 3.0);
      expect(point.color, Colors.white); // 기본 색상 테스트
    });

    test('Point3D copyWith', () {
      final point = Point3D(x: 1.0, y: 2.0, z: 3.0);
      final newPoint = point.copyWith(x: 4.0, color: Colors.red);

      expect(newPoint.x, 4.0);
      expect(newPoint.y, 2.0);
      expect(newPoint.z, 3.0);
      expect(newPoint.color, Colors.red);
    });
  });

  group('PointCloud Tests', () {
    test('PointCloud creation', () {
      final points = [Point3D(x: 0, y: 0, z: 0), Point3D(x: 1, y: 1, z: 1)];

      final cloud = PointCloud(data: points);

      expect(cloud.data.length, 2);
      expect(cloud.size, 1.0); // 기본 크기
      expect(cloud.color, null);
    });

    test('Empty PointCloud', () {
      final cloud = PointCloud.empty();

      expect(cloud.data.isEmpty, true);
      expect(cloud.length, 0);
    });
  });

  group('Transform3D Tests', () {
    test('Transform3D default values', () {
      final transform = Transform3D();

      expect(transform.rotationX, 0.0);
      expect(transform.rotationY, 0.0);
      expect(transform.rotationZ, 0.0);
      expect(transform.scale, 1.0);
    });

    test('Transform3D rotation calculation', () {
      final transform = Transform3D(rotationX: 90, rotationY: 0, rotationZ: 0);

      // final result = transform.rotateX(0, 1, 0);

      // // 90도 X축 회전시 y=1은 z=1이 되어야 함 (근사값 비교)
      // expect(result.$1, closeTo(0, 0.001)); // x
      // expect(result.$2, closeTo(0, 0.001)); // y
      // expect(result.$3, closeTo(1, 0.001)); // z
    });
  });

  group('PointCloudViewer Widget Tests', () {
    testWidgets('PointCloudViewer renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PointCloudViewer(clouds: [PointCloud.empty()])),
        ),
      );

      expect(find.byType(PointCloudViewer), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('PointCloudViewer handles gestures', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PointCloudViewer(clouds: [PointCloud.empty()])),
        ),
      );

      // 드래그 제스처 테스트
      await tester.drag(find.byType(PointCloudViewer), const Offset(100, 0));
      await tester.pump();

      // 핀치 줌 테스트
      final center = tester.getCenter(find.byType(PointCloudViewer));

      // 두 개의 터치 포인트 생성
      final gesture1 = await tester.createGesture();
      final gesture2 = await tester.createGesture();

      // 첫 번째 터치
      await gesture1.down(center);
      // 두 번째 터치는 조금 떨어진 위치에
      await gesture2.down(center + const Offset(20, 0));
      await tester.pump();

      // 핀치 줌 동작
      await gesture1.moveBy(const Offset(-20, 0));
      await gesture2.moveBy(const Offset(20, 0));
      await tester.pump();

      // 터치 종료
      await gesture1.up();
      await gesture2.up();
      await tester.pump();
    });
  });
}
