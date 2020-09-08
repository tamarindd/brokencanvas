import 'dart:ui';
import 'dart:typed_data';

import 'package:brokencanvas/session.dart';
import 'package:flutter/material.dart';

class Submit extends StatelessWidget {
  final Uint8List imageBytes;
  final Session session;
  Submit({Key key, @required this.imageBytes, @required this.session})
      : super(key: key);

  void submit() async {
    // display 'submitting'

    // submit

  }

  @override
  Widget build(BuildContext context) {
    submit();

// todo turn this into a popup. when it's done submitting, go to loading page
    return Scaffold(
        backgroundColor: Colors.white70,
        body: Container(
          decoration: BoxDecoration(
            color: const Color(0xff7c94b6),
            image: DecorationImage(
              image: MemoryImage(imageBytes),
              fit: BoxFit.cover,
            ),
            border: Border.all(
              color: Colors.blueGrey,
              width: 10.0,
            ),
          ),
        ));
  }
}
