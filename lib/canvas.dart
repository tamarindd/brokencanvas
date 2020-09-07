import 'dart:ui' as ui;
import 'dart:ui';

import 'package:brokencanvas/session.dart';
import 'package:brokencanvas/submit.dart';
import 'package:flutter/material.dart';

class DrawApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawid',
      debugShowCheckedModeBanner: false,
      home: Draw(),
    );
  }
}

class Draw extends StatefulWidget {
  @override
  _DrawState createState() => _DrawState(Session("orange", 0, "ari"));
}

class _DrawState extends State<Draw> {
  Session session;
  GestureDetector touch;
  final recorder = new PictureRecorder();
  CustomPaint canvas;
  final painter = Painter();
  Color strokeColour = Colors.black;
  Map<StrokePropertyType, StrokeProperty> sliderProperties;
  StrokePropertyType selectedMode = StrokePropertyType.Width;

  StrokeProperty selectedSlider() {
    return sliderProperties[selectedMode];
  }

  _DrawState(Session session) {
    this.session = session;

    var width = StrokeProperty()
      ..value = 3.0
      ..max = 50.0;

    var opacity = StrokeProperty()
      ..value = 1.0
      ..max = 1.0;

    sliderProperties = Map();
    sliderProperties[StrokePropertyType.Opacity] = opacity;
    sliderProperties[StrokePropertyType.Width] = width;
  }

  void panStart(DragStartDetails details) {
    Paint strokePaint = Paint();
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

  void clearCanvas() {
    getConfirmation(context, "Clear canvas",
            "Are you sure you want to restart your drawing?")
        .then((result) {
      if (result != null && result) {
        painter.clear();
      }
    });
  }

  void submitDrawing() {
    getConfirmation(context, "Submit", "Are you sure you're done drawing?")
        .then((result) async {
      final img = await painter.recordPainting(context);
      final pngBytes = await img.toByteData(format: ImageByteFormat.png);
      final imgBytes = pngBytes.buffer.asUint8List();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Submit(
            session: session,
            imageBytes: imgBytes,
          ),
        ),
      );
      return pngBytes.buffer.asUint8List();
    });
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
    touch = GestureDetector(
        onPanStart: panStart, onPanUpdate: panUpdate, onPanEnd: panEnd);

    canvas = CustomPaint(
      painter: painter,
      child: touch,
    );

    return Scaffold(
      floatingActionButton: Stack(children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 31),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              heroTag: "clearBtn",
              backgroundColor: Colors.black,
              onPressed: () {
                clearCanvas();
              },
              child: Icon(Icons.delete),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            heroTag: "submitBtn",
            backgroundColor: Colors.lightGreen,
            onPressed: () {
              submitDrawing();
            },
            child: Icon(Icons.check),
          ),
        ),
      ]),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: Colors.lightBlueAccent),
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

  Future<bool> getConfirmation(
      BuildContext context, String title, String content) async {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context, false);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () {
        Navigator.pop(context, true);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog, return true or false
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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
  final _strokes = List<DrawingPoints>();

  Painter();

  Painter.withStrokes(List<DrawingPoints> strokes) {
    _strokes.addAll(strokes);
  }

  bool hitTest(Offset position) => null;

  void startStroke(Offset position, Paint strokePaint) {
    DrawingPoints points = DrawingPoints()
      ..paint = strokePaint
      ..points = [position];
    _strokes.add(points);
    notifyListeners();
  }

  void appendStroke(Offset position) {
    var stroke = _strokes.last;
    stroke.points.add(position);
    notifyListeners();
  }

  void endStroke() {
    notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;
    Paint background = Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, background);

    for (var stroke in _strokes) {
      Path strokePath = Path();
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
    _strokes.clear();
    notifyListeners();
  }

  void undo() {
    _strokes.removeLast();
    notifyListeners();
  }

  Future<ui.Image> recordPainting(BuildContext context) {
    final recorder = PictureRecorder();
    Canvas canvas = Canvas(recorder);
    final painter = Painter.withStrokes(_strokes);
    final size = context.size;
    painter.paint(canvas, size);
    return recorder
        .endRecording()
        .toImage(size.width.floor(), size.height.floor());
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
