import "package:flutter_bloc/flutter_bloc.dart";

class GameState {
  bool iStart;
  bool myTurn;
  List<String> board;

  GameState(this.iStart, this.myTurn, this.board);
}

class GameCubit extends Cubit<GameState> {
  static final String d = ".";
  GameCubit(bool myt)
      : super(GameState(myt, myt, List.filled(9, d)));

  void update(int where, String what) {
    state.board[where] = what;
    state.myTurn = !state.myTurn;
    emit(GameState(state.iStart, state.myTurn, state.board));
  }

  void play(int where) {
    String mark = state.myTurn == state.iStart ? "x" : "o";
    state.board[where] = mark;

    if (checkWin(mark)) {
      emit(GameState(state.iStart, false, state.board));
    } else {
      emit(GameState(state.iStart, !state.myTurn, state.board));
    }
  }

  void pass() {
    emit(GameState(state.iStart, !state.myTurn, state.board));
  }

  bool checkWin(String mark) {
    List<List<int>> winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];
    return winPatterns.any(
            (pattern) => pattern.every((i) => state.board[i] == mark));
  }

  void handle(String msg) {
    List<String> parts = msg.split(" ");
    if (parts[0] == "sq") {
      int sqNum = int.parse(parts[1]);
      play(sqNum);
    }
  }
}