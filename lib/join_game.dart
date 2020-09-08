import 'package:brokencanvas/session.dart';
import 'package:flutter/material.dart';

class JoinGame extends StatelessWidget {
  JoinGame({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ask for user, game id, get session info from backend
    return Scaffold(
        backgroundColor: Colors.white70,
        body: Container(
          alignment: Alignment.center,
          child: FlatButton(
            child: Text("Join game"),
            onPressed: () {
              Session session = Session()
                ..state = SessionState.DRAW
                ..group = "orange"
                ..user = "arielle"
                ..round = 0;
              Navigator.pop(context, session);
            },
          ),
        ));
  }
}
