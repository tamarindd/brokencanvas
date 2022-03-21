import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DrawApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrokenCanvas',
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
  final recorder = new PictureRecorder();
  CustomPaint canvas;
  final painter = Painter();
  Color strokeColor = Colors.black;
  StrokeProperty strokeWidth  = StrokeProperty()
      ..value = 3
      ..max = 50;

  _DrawState();

  void panStart(DragStartDetails details) {
    Paint strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..color = strokeColor
    ..strokeWidth = strokeWidth.value as double;

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

  void saveDrawing() async {
      final img = await painter.recordPainting(context);
      final pngBytes = await img.toByteData(format: ImageByteFormat.png);
      final imgBytes = pngBytes.buffer.asUint8List();
      // save image
      // return pngBytes.buffer.asUint8List();
  }

  bool showBottomList = false;
  List<MaterialColor> colors = [
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
            heroTag: "saveBtn",
            backgroundColor: Colors.lightGreen,
            onPressed: () {
              saveDrawing();
            },
            child: Icon(Icons.save),
          ),
        ),
      ]),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0), color: Colors.grey),
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
                      Slider(
                            activeColor: strokeColor,
                            value: strokeWidth.value as double,
                            max: strokeWidth.max as double,
                            min: 0.0,
                            onChanged: (val) {
                              setState(() {
                                strokeWidth.value = val as int;
                              });
                            }),
                      IconButton(
                          icon: Icon(Icons.palette),
                          onPressed: () {
                            setState(() {
                              // display color picker
                            });
                          }),
                    ],
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

}

class ColorPicker extends State<Draw>  {
  final _recentColors = List<Color>();
  Color selectedColor;

  ColorPicker();

  getSelectColorList() {
    List<Widget> listWidget = List();
    for (Color color in colors) {
      listWidget.add(colorCircle(color));
    }
    return listWidget;
  }


  getSavedColorList() {
    List<Widget> listWidget = List();
    for (Color color in _recentColors) {
      listWidget.add(colorCircle(color));
    }
    return listWidget;
  }



  Widget colorCircle(Color color) {
    return RawMaterialButton(
      onPressed: () {
        
        setState(() {
          strokeColor = color;
        });
      },
      constraints: BoxConstraints(
          minWidth: 36.0, maxWidth: 36.0, minHeight: 36.0, maxHeight: 36.0),
      highlightColor: selectedColor == color ? color : Colors.black,
      elevation: 2.0,
      fillColor: color,
      shape: CircleBorder(),
    );
  }

}


class Painter extends ChangeNotifier implements CustomPainter {
  final _strokes = List<DrawingPoints>();

  Painter(); // todo add a white70 rectangle to _strokes

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
  int value;
  int max;
}

enum StrokePropertyType { Width, Opacity, Color }
