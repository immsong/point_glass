import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vector_math/vector_math.dart' as vm;

import 'package:point_glass/point_glass.dart';
import 'widgets.dart';

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

  List<PointGlassPolygon> polygons = [
    // 삼각형
    PointGlassPolygon(
      enable: true,
      points: [
        vm.Vector3(-15, -10, 0),
        vm.Vector3(-19.33, -2.5, 0),
        vm.Vector3(-10.67, -2.5, 0),
      ],
      pointSize: 3,
      pointColor: Colors.red,
      isEditable: false,
    ),
  ];
  bool polygonOnOff = true;
  bool isEditPolygon = false;

  bool annualSectorOnOff = true;
  double annualSectorStartAngle = 40;
  double annualSectorEndAngle = 140;
  double annualSectorInnerRadius = 2;
  double annualSectorOuterRadius = 4;

  // 필요 시 여기서 Transform3D 초기값 설정
  ValueNotifier<Transform3D> transform = ValueNotifier(
    Transform3D(scale: 50, rotationX: 0, rotationY: 0, rotationZ: 0),
  );

  List<PointGlassPoints> pointsGroup = [
    PointGlassPoints(enable: true, points: []),
    PointGlassPoints(enable: true, points: []),
    PointGlassPoints(enable: true, points: []),
    PointGlassPoints(enable: true, points: []),
  ];
  int pointGroupRefreshCount = 0;
  int pointGroupRefreshInc = 1;

  PointGlassViewerMode viewMode = PointGlassViewerMode.rotate;

  bool pointCloud1OnOff = true;
  bool pointCloud2OnOff = true;

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/point_cloud_sample').then((value) {
      PointGlassPoints pg = PointGlassPoints(enable: true, points: []);

      final lines = value.split('\n');
      pg.points = lines.map((line) {
        final parts = line.split(',');
        return PointGlassPoint(
          point: vm.Vector3(
            (double.parse(parts[0]) / 20.0) - 5,
            (double.parse(parts[1]) / 20.0) + 5,
            double.parse(parts[2]) / 20.0,
          ),
          color: Colors.grey,
          alpha: 150,
          strokeWidth: 1,
        );
      }).toList();

      pointsGroup[1] = pg;

      pg = PointGlassPoints(enable: true, points: []);
      pg.points = lines.map((line) {
        final parts = line.split(',');
        return PointGlassPoint(
          point: vm.Vector3(
            (double.parse(parts[0]) / 20.0) + 5,
            (double.parse(parts[1]) / 20.0) + 5,
            double.parse(parts[2]) / 20.0,
          ),
          color: Color(0xFFDECAA0),
          alpha: 150,
          strokeWidth: 1,
        );
      }).toList();

      pointsGroup[2] = pg;
    });

    // 25ms 당 한번 호출
    Timer.periodic(Duration(milliseconds: 25), (timer) {
      for (var i = 0; i < pointsGroup.length; i++) {
        for (var j = 0; j < pointsGroup[i].points.length; j++) {
          setState(() {
            pointsGroup[i].points[j].point.y =
                pointsGroup[i].points[j].point.y + (pointGroupRefreshInc * 0.1);
          });
        }
      }

      if (pointGroupRefreshCount > 50) {
        pointGroupRefreshInc = -1;
      } else if (pointGroupRefreshCount < 1) {
        pointGroupRefreshInc = 1;
      }

      pointGroupRefreshCount += pointGroupRefreshInc;
    });
  }

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
                transform: transform,
                mode: viewMode,
                grid: PointGlassGrid(
                  enable: true,
                  gridSize: gridSize,
                  gridStep: gridStep,
                  enableLabel: true,
                  labelStyle: TextStyle(color: Colors.white.withAlpha(150)),
                ),
                axis: PointGlassAxis(enable: axisOnOff, axisLength: axisLength),
                polygons: polygons,
                annualSectors: [
                  PointGlassAnnualSector(
                    enable: annualSectorOnOff,
                    startAngle: annualSectorStartAngle,
                    endAngle: annualSectorEndAngle,
                    innerRadius: annualSectorInnerRadius,
                    outerRadius: annualSectorOuterRadius,
                    color: Colors.green,
                    alpha: 30,
                    lineColor: Colors.green,
                    lineAlpha: 255,
                  ),
                ],
                pointsGroup: pointsGroup,
              ),
            ),
            Expanded(flex: 3, child: _buildController()),
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildGridControlWidgets(),
            _buildAxisControlWidgets(),
            _buildPolygonControlWidgets(),
            _buildAnnualSectorControlWidgets(),
            _buildViewerControlWidgets(),
            _pointCloudControlWidgets(),
          ],
        ),
      ),
    );
  }

  Widget _buildGridControlWidgets() {
    return Column(
      children: [
        title('Grid'),
        slider(
          txt: 'Grid Size',
          value: gridSize,
          min: 10,
          max: 100,
          onChanged: (value) {
            setState(() {
              gridSize = (((value / 10).round()) * 10).toDouble();
            });
          },
        ),
        slider(
          txt: 'Grid Step',
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
        horizontalLine(),
      ],
    );
  }

  Widget _buildAxisControlWidgets() {
    return Column(
      children: [
        title('Axis'),
        radioButton(
          txt: 'Axis On / Off',
          groupValue: axisOnOff,
          trueLabel: 'On',
          falseLabel: 'Off',
          onTrueAction: () {
            setState(() {
              axisOnOff = true;
            });
          },
          onFalseAction: () {
            setState(() {
              axisOnOff = false;
            });
          },
        ),
        slider(
          txt: 'Axis Length',
          value: axisLength,
          min: 0.5,
          max: 5,
          onChanged: (value) {
            setState(() {
              axisLength = (value * 2).round() / 2;
            });
          },
        ),
        horizontalLine(),
      ],
    );
  }

  Widget _buildPolygonControlWidgets() {
    return Column(
      children: [
        title('Polygon'),
        radioButton(
          txt: 'Polygon On / Off',
          groupValue: polygonOnOff,
          trueLabel: 'On',
          falseLabel: 'Off',
          onTrueAction: () {
            setState(() {
              polygonOnOff = true;
              for (var polygon in polygons) {
                polygon.enable = polygonOnOff;
              }
            });
          },
          onFalseAction: () {
            setState(() {
              polygonOnOff = false;
              for (var polygon in polygons) {
                polygon.enable = polygonOnOff;
              }
            });
          },
        ),
        radioButton(
          txt: 'Polygon Edit / View Only',
          groupValue: isEditPolygon,
          trueLabel: 'Edit',
          falseLabel: 'View',
          onTrueAction: () {
            setState(() {
              isEditPolygon = true;
              viewMode = PointGlassViewerMode.editPolygon;
              for (var polygon in polygons) {
                polygon.isEditable = isEditPolygon;
              }
            });
          },
          onFalseAction: () {
            setState(() {
              isEditPolygon = false;
              viewMode = PointGlassViewerMode.rotate;
              for (var polygon in polygons) {
                polygon.isEditable = isEditPolygon;
              }
            });
          },
        ),
        horizontalLine(),
      ],
    );
  }

  Widget _buildAnnualSectorControlWidgets() {
    return Column(
      children: [
        title('Annual Sector'),
        radioButton(
          txt: 'Annual Sector On / Off',
          groupValue: annualSectorOnOff,
          trueLabel: 'On',
          falseLabel: 'Off',
          onTrueAction: () {
            setState(() {
              annualSectorOnOff = true;
            });
          },
          onFalseAction: () {
            setState(() {
              annualSectorOnOff = false;
            });
          },
        ),
        slider(
          txt: 'Start Angle',
          value: annualSectorStartAngle,
          min: 0,
          max: 360,
          onChanged: (value) {
            setState(() {
              if (value >= annualSectorEndAngle) {
                annualSectorStartAngle = annualSectorEndAngle - 1;
              } else {
                annualSectorStartAngle = value.round().toDouble();
              }
            });
          },
        ),
        slider(
          txt: 'End Angle',
          value: annualSectorEndAngle,
          min: 0,
          max: 360,
          onChanged: (value) {
            setState(() {
              if (value <= annualSectorStartAngle) {
                annualSectorEndAngle = annualSectorStartAngle + 1;
              } else {
                annualSectorEndAngle = value.round().toDouble();
              }
            });
          },
        ),
        slider(
          txt: 'Inner Radius',
          value: annualSectorInnerRadius,
          min: 0,
          max: 100,
          onChanged: (value) {
            setState(() {
              if (value > annualSectorOuterRadius) {
                annualSectorInnerRadius = annualSectorOuterRadius;
              } else {
                annualSectorInnerRadius = value.round().toDouble();
              }
            });
          },
        ),
        slider(
          txt: 'Outer Radius',
          value: annualSectorOuterRadius,
          min: 0,
          max: 100,
          onChanged: (value) {
            setState(() {
              if (value < annualSectorInnerRadius) {
                annualSectorOuterRadius = annualSectorInnerRadius;
              } else {
                annualSectorOuterRadius = value.round().toDouble();
              }
            });
          },
        ),
        horizontalLine(),
      ],
    );
  }

  Widget _buildViewerControlWidgets() {
    return Column(
      children: [
        title('View'),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: label('View Mode')),
                  Radio<PointGlassViewerMode>(
                    value: PointGlassViewerMode.rotate,
                    groupValue: viewMode,
                    onChanged: (value) {
                      setState(() {
                        viewMode = value!;
                        isEditPolygon = false;
                        for (var polygon in polygons) {
                          polygon.isEditable = isEditPolygon;
                        }
                      });
                    },
                  ),
                  Expanded(child: label('Rotate')),
                  Radio<PointGlassViewerMode>(
                    value: PointGlassViewerMode.translate,
                    groupValue: viewMode,
                    onChanged: (value) {
                      setState(() {
                        viewMode = value!;
                        isEditPolygon = false;
                        for (var polygon in polygons) {
                          polygon.isEditable = isEditPolygon;
                        }
                      });
                    },
                  ),
                  Expanded(child: label('Translate')),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Spacer(),
                  Radio<PointGlassViewerMode>(
                    value: PointGlassViewerMode.spin,
                    groupValue: viewMode,
                    onChanged: (value) {
                      setState(() {
                        viewMode = value!;
                        isEditPolygon = false;
                        for (var polygon in polygons) {
                          polygon.isEditable = isEditPolygon;
                        }
                      });
                    },
                  ),
                  Expanded(child: label('Spin')),
                  Radio<PointGlassViewerMode>(
                    value: PointGlassViewerMode.editPolygon,
                    groupValue: viewMode,
                    onChanged: (value) {
                      setState(() {
                        viewMode = value!;
                        isEditPolygon = true;
                        for (var polygon in polygons) {
                          polygon.isEditable = isEditPolygon;
                        }
                      });
                    },
                  ),
                  Expanded(child: label('Edit Polygon')),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        _transformListener(),
        Row(
          children: [
            const Spacer(),
            ElevatedButton(
              child: Text('Reset'),
              onPressed: () {
                setState(() {
                  transform.value = Transform3D(
                    scale: 50,
                    rotationX: 0,
                    rotationY: 0,
                    rotationZ: 0,
                  );
                });
              },
            ),
          ],
        ),
        horizontalLine(),
      ],
    );
  }

  Widget _transformListener() {
    return ValueListenableBuilder<Transform3D>(
      valueListenable: transform,
      builder: (context, value, child) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: label('Transform Info')),
                const Spacer(),
                Expanded(
                  child: label(
                    'Scale: ${transform.value.scale.toStringAsFixed(1)}',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Spacer(flex: 2),
                Expanded(
                  child: label(
                    'Rotation X: ${transform.value.rotationX.toStringAsFixed(1)}',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Spacer(flex: 2),
                Expanded(
                  child: label(
                    'Rotation Y: ${transform.value.rotationY.toStringAsFixed(1)}',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Spacer(flex: 2),
                Expanded(
                  child: label(
                    'Rotation Z: ${transform.value.rotationZ.toStringAsFixed(1)}',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _pointCloudControlWidgets() {
    return Column(
      children: [
        title('Point Cloud'),
        radioButton(
          txt: 'Point Cloud 1On / Off',
          groupValue: pointCloud1OnOff,
          trueLabel: 'On',
          falseLabel: 'Off',
          onTrueAction: () {
            setState(() {
              pointCloud1OnOff = true;
              pointsGroup[1].enable = pointCloud1OnOff;
            });
          },
          onFalseAction: () {
            setState(() {
              pointCloud1OnOff = false;
              pointsGroup[1].enable = pointCloud1OnOff;
            });
          },
        ),
        radioButton(
          txt: 'Point Cloud 2 On / Off',
          groupValue: pointCloud2OnOff,
          trueLabel: 'On',
          falseLabel: 'Off',
          onTrueAction: () {
            setState(() {
              pointCloud2OnOff = true;
              pointsGroup[2].enable = pointCloud2OnOff;
            });
          },
          onFalseAction: () {
            setState(() {
              pointCloud2OnOff = false;
              pointsGroup[2].enable = pointCloud2OnOff;
            });
          },
        ),
        horizontalLine(),
      ],
    );
  }
}
