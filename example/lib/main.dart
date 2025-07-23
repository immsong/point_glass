import 'package:flutter/material.dart';
import 'package:point_glass/point_glass.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Point Glass Demo',
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 테스트용 포인트 클라우드 데이터 생성
  List<PointCloud> _generateTestData() {
    final points = <Point3D>[];

    // 큐브 형태의 포인트 생성
    for (double x = -5; x <= 5; x += 0.5) {
      for (double y = -5; y <= 5; y += 0.5) {
        // 큐브의 표면에만 점 생성
        if (x.abs() == 5 || y.abs() == 5) {
          points.add(
            Point3D(
              x: x,
              y: y,
              z: 0,
              color: Color.fromARGB(
                255,
                ((x + 5) * 25).round(),
                ((y + 5) * 25).round(),
                0,
              ),
            ),
          );
        }
      }
    }

    return [PointCloud(data: points, size: 2.0)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Point Glass Demo')),
      body: PointCloudViewer(
        clouds: _generateTestData(),
        initialScale: 50.0,
        initialRotationX: 45.0,
        initialRotationY: 45.0,
        gridConfig: const GridConfig(
          enabled: true,
          size: 20.0,
          step: 1,
          lineAlpha: 30,
          showAxis: true,
          showAxisLabels: true,
        ),
      ),
    );
  }
}
