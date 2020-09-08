import 'package:brokencanvas/session.dart';
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final Session session;
  Loading({Key key,  @required this.session})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // display 'waiting for the round to finish'

    // display game id, username, current round number at the top

    // wait 5 seconds, return
    return Scaffold(
        backgroundColor: Colors.red,
        body: Container(
        ));
  }
}
