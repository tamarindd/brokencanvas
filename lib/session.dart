class Session {
  SessionState state;
  String group;
  int round;
  String user;

  Session() {
    this.state = SessionState.START;
  }
}

enum SessionState { START, DRAW, GUESS, WAIT, END }
