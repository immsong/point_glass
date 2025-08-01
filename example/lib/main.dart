import 'package:flutter/material.dart';

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
                mode: isEditPolygon
                    ? PointGlassViewerMode.editPolygon
                    : PointGlassViewerMode.rotate,
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
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildGridControlWidgets(),
          _buildAxisControlWidgets(),
          _buildPolygonControlWidgets(),
          _buildAnnualSectorControlWidgets(),
          const Spacer(),
        ],
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
  }