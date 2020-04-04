import 'dart:ui';

import 'package:flutter/material.dart';

class DrawApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Draw(),
    );
  }
}

class Draw extends StatefulWidget {
  @override
  _DrawState createState() => _DrawState();
}

class _DrawState extends State<Draw> {
  GestureDetector touch;
  CustomPaint canvas;
  Painter painter = new Painter();
  Color strokeColour = Colors.black;
  Map<StrokePropertyType, StrokeProperty> sliderProperties;
  StrokePropertyType selectedMode = StrokePropertyType.Width;

  StrokeProperty selectedSlider() {
    return sliderProperties[selectedMode];
  }

  _DrawState() {
    var width = StrokeProperty()
      ..value = 3.0
      ..max = 50.0;

    var opacity = StrokeProperty()
      ..value = 1.0
      ..max = 1.0;

    sliderProperties = new Map();
    sliderProperties[StrokePropertyType.Opacity] = opacity;
    sliderProperties[StrokePropertyType.Width] = width;
  }

  void panStart(DragStartDetails details) {
    Paint strokePaint = new Paint();
    strokePaint.style = PaintingStyle.stroke;
    strokePaint.color = strokeColour
        .withOpacity(sliderProperties[StrokePropertyType.Opacity].value);
    strokePaint.strokeWidth = sliderProperties[StrokePropertyType.Width].value;

    painter.startStroke(details.globalPosition, strokePaint);
  }

  void panUpdate(DragUpdateDetails details) {
    painter.appendStroke(details.globalPosition);
  }

  void panEnd(DragEndDetails details) {
    painter.endStroke();
  }

  bool showBottomList = false;
  List<Color> colors = [
    Colors.amber,
    Colors.red,
    Colors.indigo,
    Colors.teal,
    Colors.black,
    Colors.white70,
  ];
  @override
  Widget build(BuildContext context) {
    touch = new GestureDetector(
      onPanStart: panStart,
      onPanUpdate: panUpdate,
      onPanEnd: panEnd,
    );

    canvas = new CustomPaint(
      painter: painter,
      child: touch,
    );

    return Scaffold(
      floatingActionButton: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            setState(() {
              painter.clear();
            });
          }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: Colors.tealAccent),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.undo),
                          onPressed: () {
                            setState(() {
                              painter.undo();
                            });
                          }),
                      IconButton(
                          icon: Icon(Icons.add_circle),
                          onPressed: () {
                            setState(() {
                              if (selectedMode == StrokePropertyType.Width)
                                showBottomList = !showBottomList;
                              selectedMode = StrokePropertyType.Width;
                            });
                          }),
                      IconButton(
                          icon: Icon(Icons.opacity),
                          onPressed: () {
                            setState(() {
                              if (selectedMode == StrokePropertyType.Opacity)
                                showBottomList = !showBottomList;
                              selectedMode = StrokePropertyType.Opacity;
                            });
                          }),
                      IconButton(
                          icon: Icon(Icons.palette),
                          onPressed: () {
                            setState(() {
                              if (selectedMode == StrokePropertyType.Color)
                                showBottomList = !showBottomList;
                              selectedMode = StrokePropertyType.Color;
                            });
                          }),
                    ],
                  ),
                  Visibility(
                    child: (selectedMode == StrokePropertyType.Color)
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: getColorList(),
                          )
                        : Slider(
                            value: selectedSlider().value,
                            max: selectedSlider().max,
                            min: 0.0,
                            onChanged: (val) {
                              setState(() {
                                selectedSlider().value = val;
                              });
                            }),
                    visible: showBottomList,
                  ),
                ],
              ),
            )),
      ),
      body: canvas,
    );
  }

  getColorList() {
    List<Widget> listWidget = List();
    for (Color color in colors) {
      listWidget.add(colorCircle(color));
    }
    return listWidget;
  }

  Widget colorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          strokeColour = color;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(top: 16.0),
          height: 36,
          width: 36,
          color: color,
        ),
      ),
    );
  }
}

class Painter extends ChangeNotifier implements CustomPainter {
  final strokes = new List<DrawingPoints>();

  Painter();

  bool hitTest(Offset position) => null;

  void startStroke(Offset position, Paint strokePaint) {
    DrawingPoints points = DrawingPoints()
      ..paint = strokePaint
      ..points = [position];
    strokes.add(points);
    notifyListeners();
  }

  void appendStroke(Offset position) {
    var stroke = strokes.last;
    stroke.points.add(position);
    notifyListeners();
  }

  void endStroke() {
    notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;
    Paint fillPaint = new Paint();
    fillPaint.color = Colors.white70;
    fillPaint.style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);

    for (var stroke in strokes) {
      Path strokePath = new Path();
      strokePath.addPolygon(stroke.points, false);
      canvas.drawPath(strokePath, stroke.paint);
    }
  }

  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  // *shrug*
  @override
  get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) {
    return false;
  }

  void clear() {
    strokes.clear();
  }

  void undo() {
    strokes.removeLast();
  }
}

class DrawingPoints {
  Paint paint;
  List<Offset> points;
  DrawingPoints({this.points, this.paint});
}

class StrokeProperty {
  double value;
  double max;
}

enum StrokePropertyType { Width, Opacity, Color }
