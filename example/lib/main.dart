import 'package:flutter/material.dart';

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
        children: [..._buildGridControlWidgets(), const Spacer(flex: 50)],
      ),
    );
  }

  List<Widget> _buildGridControlWidgets() {
    return [
      Expanded(child: Text('Grid Size')),
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
      Expanded(child: Text('Grid Step')),
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
}
