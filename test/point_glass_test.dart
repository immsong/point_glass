import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vector_math/vector_math.dart' as vm;

import 'package:point_glass/point_glass.dart';

void main() {
  group('Point Glass Tests', () {
    test('should create PointGlassGrid', () {
      final grid = PointGlassGrid(
        enable: true,
        gridSize: 20,
        gridStep: 1,
        enableLabel: true,
      );
      expect(grid.enable, true);
      expect(grid.gridSize, 20);
      expect(grid.gridStep, 1);
      expect(grid.enableLabel, true);
    });

    test('should create PointGlassAxis', () {
      final axis = PointGlassAxis(enable: true, axisLength: 0.5);
      expect(axis.enable, true);
      expect(axis.axisLength, 0.5);
    });

    test('should create Transform3D', () {
      final transform = Transform3D(
        scale: 50,
        rotationX: 0,
        rotationY: 0,
        rotationZ: 0,
      );
      expect(transform.scale, 50);
      expect(transform.rotationX, 0);
    });

    test('should create PointGlassPolygon', () {
      final polygon = PointGlassPolygon(
        enable: true,
        points: [vm.Vector3(0, 0, 0), vm.Vector3(1, 0, 0), vm.Vector3(0, 1, 0)],
        pointSize: 3,
        pointColor: Colors.red,
        isEditable: false,
      );
      expect(polygon.enable, true);
      expect(polygon.points.length, 3);
      expect(polygon.pointSize, 3);
      expect(polygon.isEditable, false);
    });

    test('should create PointGlassAnnualSector', () {
      final sector = PointGlassAnnualSector(
        enable: true,
        startAngle: 0,
        endAngle: 90,
        innerRadius: 1,
        outerRadius: 2,
        color: Colors.blue,
        alpha: 100,
      );
      expect(sector.enable, true);
      expect(sector.startAngle, 0);
      expect(sector.endAngle, 90);
      expect(sector.innerRadius, 1);
      expect(sector.outerRadius, 2);
    });

    test('should create PointGlassPoints', () {
      final points = PointGlassPoints(enable: true, points: []);
      expect(points.enable, true);
      expect(points.points.length, 0);
    });

    group('Widget Tests', () {
      testWidgets('PointGlassViewer should render correctly', (tester) async {
        final transform = ValueNotifier(Transform3D(scale: 50));

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Center(
              // 크기 제약 추가
              child: SizedBox(
                // 명시적 크기 설정
                width: 800,
                height: 600,
                child: PointGlassViewer(
                  transform: transform,
                  mode: PointGlassViewerMode.rotate, // 모드 명시
                  grid: PointGlassGrid(enable: true),
                ),
              ),
            ),
          ),
        ));

        expect(find.byType(PointGlassViewer), findsOneWidget);
      });

      testWidgets('PointGlassViewer should handle user interactions', (
        tester,
      ) async {
        final transform = ValueNotifier(Transform3D(scale: 50));

        await tester.pumpWidget(
          MaterialApp(home: PointGlassViewer(transform: transform)),
        );

        await tester.drag(
          find.byType(PointGlassViewer),
          const Offset(100, 100),
        );
        await tester.pumpAndSettle();

        await tester.fling(
          find.byType(PointGlassViewer),
          const Offset(0, 100),
          1000,
        );
        await tester.pumpAndSettle();
      });
    });

    group('Transform3D Tests', () {
      test('should initialize with default values', () {
        final transform = Transform3D();
        expect(transform.scale, equals(100.0));
        expect(transform.rotationX, equals(0.0));
        expect(transform.rotationY, equals(0.0));
        expect(transform.rotationZ, equals(0.0));
        expect(transform.positionX, equals(0.0));
        expect(transform.positionY, equals(0.0));
      });

      test('should transform point correctly', () {
        final transform = Transform3D(
          scale: 100,
          rotationX: 45,
          rotationY: 30,
          rotationZ: 0,
        );

        final (x, y, z) = transform.transform(1, 1, 1);
        expect(x, isNotNull);
        expect(y, isNotNull);
        expect(z, isNotNull);
      });

      test('should copy with new values', () {
        final transform = Transform3D(scale: 100);
        final copied = transform.copyWith(
          scale: 200,
          rotationX: 45,
        );

        expect(copied.scale, equals(200));
        expect(copied.rotationX, equals(45));
        expect(copied.rotationY, equals(0)); // 원래 값 유지
      });

      test('should convert between degrees and radians', () {
        final transform = Transform3D();
        expect(transform.radians(180), closeTo(pi, 0.0001));
        expect(transform.degrees(pi), closeTo(180, 0.0001));
      });
    });

    group('PointGlassGrid Tests', () {
      test('should initialize with default values', () {
        final grid = PointGlassGrid();
        expect(grid.gridSize, equals(20));
        expect(grid.gridStep, equals(1));
        expect(grid.enableLabel, equals(false));
        expect(grid.labelStyle.color, equals(Colors.white));
      });

      test('should initialize with custom values', () {
        final grid = PointGlassGrid(
          enable: true,
          gridSize: 30,
          gridStep: 2,
          enableLabel: true,
          labelStyle: const TextStyle(color: Colors.blue),
        );

        expect(grid.enable, isTrue);
        expect(grid.gridSize, equals(30));
        expect(grid.gridStep, equals(2));
        expect(grid.enableLabel, isTrue);
        expect(grid.labelStyle.color, equals(Colors.blue));
      });
    });

    group('PointGlassViewer Mode Tests', () {
      test('should handle mode changes', () {
        final transform = ValueNotifier(Transform3D(scale: 50));
        final viewer = PointGlassViewer(
          transform: transform,
          mode: PointGlassViewerMode.rotate,
        );

        expect(viewer.mode, equals(PointGlassViewerMode.rotate));
      });
    });

    group('PointGlassPolygon Edit Tests', () {
      test('should handle point addition and removal', () {
        final polygon = PointGlassPolygon(
          enable: true,
          points: [vm.Vector3(0, 0, 0)],
          isEditable: true,
        );

        polygon.points.add(vm.Vector3(1, 1, 0));
        expect(polygon.points.length, equals(2));

        polygon.points.removeLast();
        expect(polygon.points.length, equals(1));
      });
    });

    group('Edge Cases', () {
      test('should handle empty points list', () {
        final points = PointGlassPoints(enable: true, points: []);
        expect(points.points.isEmpty, isTrue);
      });

      test('should handle invalid angles in annual sector', () {
        final sector = PointGlassAnnualSector(
          enable: true,
          startAngle: 40,
          endAngle: 90,
          innerRadius: 1,
          outerRadius: 2,
          color: Colors.blue,
          alpha: 100,
        );

        expect(sector.startAngle, lessThanOrEqualTo(360));
        expect(sector.endAngle, greaterThanOrEqualTo(0));
      });
    });

    testWidgets('Full interaction flow test', (tester) async {
      final transform = ValueNotifier(Transform3D(scale: 50));

      await tester.pumpWidget(
        MaterialApp(
          home: PointGlassViewer(
            transform: transform,
            grid: PointGlassGrid(enable: true),
            polygons: [
              PointGlassPolygon(
                enable: true,
                isEditable: true,
                points: [vm.Vector3(0, 0, 0)],
              ),
            ],
          ),
        ),
      );

      // 기본 렌더링 확인
      expect(find.byType(PointGlassViewer), findsOneWidget);

      // 상호작용 테스트
      await tester.drag(find.byType(PointGlassViewer), const Offset(100, 0));
      await tester.pumpAndSettle();

      await tester.fling(
        find.byType(PointGlassViewer),
        const Offset(0, 100),
        1000,
      );
      await tester.pumpAndSettle();
    });
  });
}
