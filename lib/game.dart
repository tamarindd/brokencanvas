import 'dart:typed_data';

import 'package:brokencanvas/canvas.dart';
import 'package:brokencanvas/join_game.dart';
import 'package:brokencanvas/loading.dart';
import 'package:brokencanvas/session.dart';
import 'package:brokencanvas/submit.dart';
import 'package:flutter/material.dart';

class DrawApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawid',
      debugShowCheckedModeBanner: false,
      home: Game(),
    );
  }
}

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState(Session());
}

class _GameState extends State<Game> {
  Session session;
  _GameState(this.session);

  Future<void> _submitDrawing(Uint8List imageBytes) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Submit(
          session: session,
          imageBytes: imageBytes,
        ),
      ),
    );
    //   wait to complete
  }

  Future<void> joinGame() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JoinGame(),
      ),
    ).then((session) => setState(() {
          this.session = session;
        }));
  }

  Future<void> drawPhase() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Draw(),
      ),
    ).then((pngBytes) => _submitDrawing(pngBytes));
  }

  void _waitForNextRound() async {
    SessionState newState = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Loading(session: session),
      ),
    );
    setState(() {
      session.state = newState;
      session.round++;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (session.state) {
      case SessionState.START:
        {
          break;
        }
      case SessionState.DRAW:
        {
          Future.microtask(() => drawPhase().then((_) => _waitForNextRound()));
          break;
        }
      case SessionState.GUESS:
        {
          break;
        }
      case SessionState.WAIT:
        {
          break;
        }
      case SessionState.END:
        {
          break;
        }
      default:
    }

    return Scaffold(
        backgroundColor: Colors.white70,
        body: Container(
          alignment: Alignment.center,
          child: FlatButton(
            child: Text("Join game"),
            onPressed: () {
              setState(() {
                this.session = Session()
                  ..state = SessionState.DRAW
                  ..group = "orange"
                  ..user = "arielle"
                  ..round = 0;
              });
            },
          ),
        ));
  }
}
