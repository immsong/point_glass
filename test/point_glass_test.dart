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

    test('should create ViewContext', () {
      final viewContext = ViewContext(
        model: ModelTransform(),
        camera: PinholeCamera(cameraZ: 10),
        proj: PinholeProjection(focalPx: 800, near: 1, far: 20000),
        canvasCenter: Offset(0, 0),
      );
      expect(viewContext.model.scale, equals(1.0));
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
        final viewContext = ValueNotifier(ViewContext(
          model: ModelTransform(),
          camera: PinholeCamera(cameraZ: 10),
          proj: PinholeProjection(focalPx: 800, near: 1, far: 20000),
          canvasCenter: Offset(0, 0),
        ));

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Center(
              // 크기 제약 추가
              child: SizedBox(
                // 명시적 크기 설정
                width: 800,
                height: 600,
                child: PointGlassViewer(
                  viewContext: viewContext,
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
        final viewContext = ValueNotifier(ViewContext(
          model: ModelTransform(),
          camera: PinholeCamera(cameraZ: 10),
          proj: PinholeProjection(focalPx: 800, near: 1, far: 20000),
          canvasCenter: Offset(0, 0),
        ));

        await tester.pumpWidget(
          MaterialApp(home: PointGlassViewer(viewContext: viewContext)),
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
        final viewContext = ViewContext(
          model: ModelTransform(),
          camera: PinholeCamera(cameraZ: 10),
          proj: PinholeProjection(focalPx: 800, near: 1, far: 20000),
          canvasCenter: Offset(0, 0),
        );
        expect(viewContext.model.scale, equals(1.0));
        expect(viewContext.camera.yaw, equals(0.0));
        expect(viewContext.camera.pitch, equals(0.0));
        expect(viewContext.camera.roll, equals(0.0));
      });

      test('should transform point correctly', () {
        final viewContext = ViewContext(
          model: ModelTransform(),
          camera: PinholeCamera(cameraZ: 10),
          proj: PinholeProjection(focalPx: 800, near: 1, far: 20000),
          canvasCenter: Offset(0, 0),
        );

        final point = viewContext.projectModel(1, 1, 1);
        expect(point.p, isNotNull);
        expect(point.vz, isNotNull);
      });

      test('should copy with new values', () {
        final viewContext = ViewContext(
          model: ModelTransform(),
          camera: PinholeCamera(cameraZ: 10),
          proj: PinholeProjection(focalPx: 800, near: 1, far: 20000),
          canvasCenter: Offset(0, 0),
        );
        final copied = viewContext.copyWith(
          camera: PinholeCamera(cameraZ: 20),
        );

        expect(copied.camera.cameraZ, equals(20));
      });

      test('should convert between degrees and radians', () {
        final viewContext = ViewContext(
          model: ModelTransform(),
          camera: PinholeCamera(cameraZ: 10),
          proj: PinholeProjection(focalPx: 800, near: 1, far: 20000),
          canvasCenter: Offset(0, 0),
        );

        // 기본값이 0.0이므로 0도/0 라디안으로 테스트
        expect(radians(viewContext.camera.yaw), closeTo(0.0, 0.0001));
        expect(radians(viewContext.camera.pitch), closeTo(0.0, 0.0001));
        expect(radians(viewContext.camera.roll), closeTo(0.0, 0.0001));
        expect(degrees(radians(viewContext.camera.yaw)), closeTo(0.0, 0.0001));
        expect(
            degrees(radians(viewContext.camera.pitch)), closeTo(0.0, 0.0001));
        expect(degrees(radians(viewContext.camera.roll)), closeTo(0.0, 0.0001));
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
        final viewContext = ValueNotifier(ViewContext(
          model: ModelTransform(),
          camera: PinholeCamera(cameraZ: 10),
          proj: PinholeProjection(focalPx: 800, near: 1, far: 20000),
          canvasCenter: Offset(0, 0),
        ));
        final viewer = PointGlassViewer(
          viewContext: viewContext,
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
      final viewContext = ValueNotifier(ViewContext(
        model: ModelTransform(),
        camera: PinholeCamera(cameraZ: 10),
        proj: PinholeProjection(focalPx: 800, near: 1, far: 20000),
        canvasCenter: Offset(0, 0),
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: PointGlassViewer(
            viewContext: viewContext,
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
