import 'package:flutter/material.dart';

import 'package:vector_math/vector_math.dart' as vm;

import 'package:point_glass/point_glass.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double gridSize = 20;
  double gridStep = 1;

  double axisLength = 0.5;
  bool axisOnOff = true;

  bool polygonOnOff = true;
  List<PointGlassPolygon> polygons = [
    // 삼각형
    PointGlassPolygon(
      enable: true,
      points: [
        vm.Vector3(-15, -10, 0),
        vm.Vector3(-19.33, -2.5, 0),
        vm.Vector3(-10.67, -2.5, 0),
      ],
      pointSize: 0.25,
      pointColor: Colors.red,
    ),
    // 사각형
    PointGlassPolygon(
      enable: true,
      points: [
        vm.Vector3(10, -10, 0),
        vm.Vector3(20, -10, 0),
        vm.Vector3(20, 0, 0),
        vm.Vector3(10, 0, 0),
      ],
      pointSize: 0.25,
      pointColor: Colors.orange,
    ),
    // 육각형
    PointGlassPolygon(
      enable: true,
      points: [
        vm.Vector3(15, 5, 0),
        vm.Vector3(10.67, 7.5, 0),
        vm.Vector3(10.67, 12.5, 0),
        vm.Vector3(15, 15, 0),
        vm.Vector3(19.33, 12.5, 0),
        vm.Vector3(19.33, 7.5, 0),
      ],
      pointSize: 0.25,
      pointColor: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 48, 48, 48),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: PointGlassViewer(
                grid: PointGlassGrid(
                  enable: true,
                  gridSize: gridSize,
                  gridStep: gridStep,
                  enableLabel: true,
                  labelStyle: TextStyle(color: Colors.white.withAlpha(150)),
                ),
                axis: PointGlassAxis(enable: axisOnOff, axisLength: axisLength),
                polygons: polygons,
              ),
            ),
            Expanded(child: _buildController()),
          ],
        ),
      ),
    );
  }

  Widget _buildController() {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ..._buildGridControlWidgets(),
          const Spacer(),
          ..._buildAxisControlWidgets(),
          const Spacer(),
          ..._buildPolygonControlWidgets(),
          const Spacer(flex: 50),
        ],
      ),
    );
  }

  List<Widget> _buildGridControlWidgets() {
    return [
      Expanded(child: Row(children: [Text('Grid Size'), const Spacer()])),
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: Slider(
                value: gridSize,
                min: 10,
                max: 100,
                onChanged: (value) {
                  setState(() {
                    gridSize = (((value / 10).round()) * 10).toDouble();
                  });
                },
              ),
            ),
            Text(gridSize.toString()),
          ],
        ),
      ),
      const Spacer(),
      Expanded(child: Row(children: [Text('Grid Step'), const Spacer()])),
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: Slider(
                value: gridStep,
                min: 1,
                max: 10,
                onChanged: (value) {
                  setState(() {
                    if (value > 5) {
                      gridStep = 10;
                    } else if (value > 2) {
                      gridStep = 5;
                    } else if (value > 1) {
                      gridStep = 2;
                    } else {
                      gridStep = 1;
                    }
                  });
                },
              ),
            ),
            Text(gridStep.toString()),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildAxisControlWidgets() {
    return [
      Expanded(child: Row(children: [Text('Axis Length'), const Spacer()])),
      Expanded(
        child: Row(
          children: [
            Expanded(
              child: Slider(
                value: axisLength,
                min: 0.5,
                max: 5,
                onChanged: (value) {
                  setState(() {
                    axisLength = (value * 2).round() / 2;
                  });
                },
              ),
            ),
            Text(axisLength.toString()),
          ],
        ),
      ),
      const Spacer(),
      Expanded(child: Row(children: [Text('Axis On / Off'), const Spacer()])),
      Expanded(
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: axisOnOff,
              onChanged: (value) {
                setState(() {
                  axisOnOff = true;
                });
              },
            ),
            Text('On'),
            const Spacer(),
            Radio<bool>(
              value: false,
              groupValue: axisOnOff,
              onChanged: (value) {
                setState(() {
                  axisOnOff = false;
                });
              },
            ),
            Text('Off'),
            const Spacer(),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildPolygonControlWidgets() {
    return [
      Expanded(
        child: Row(children: [Text('Polygon On / Off'), const Spacer()]),
      ),
      Expanded(
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: polygonOnOff,
              onChanged: (value) {
                setState(() {
                  polygonOnOff = true;
                  for (var polygon in polygons) {
                    polygon.enable = true;
                  }
                });
              },
            ),
            Text('On'),
            const Spacer(),
            Radio<bool>(
              value: false,
              groupValue: polygonOnOff,
              onChanged: (value) {
                setState(() {
                  polygonOnOff = false;
                  for (var polygon in polygons) {
                    polygon.enable = false;
                  }
                });
              },
            ),
            Text('Off'),
            const Spacer(),
          ],
        ),
      ),
    ];
  }
}
