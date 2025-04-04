// chess_state.dart
// Barrett Koster 2025

import 'package:flutter_bloc/flutter_bloc.dart';
import 'coords.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ChessState {
  final List<List<String>> board;
  final int turnCount;

  ChessState()
      : board = [
    ['r.', 'p', ' ', ' ', ' ', ' ', 'P', 'R.'],
    ['n', 'p', ' ', ' ', ' ', ' ', 'P', 'N'],
    ['b', 'p', ' ', ' ', ' ', ' ', 'P', 'B'],
    ['q', 'p', ' ', ' ', ' ', ' ', 'P', 'Q'],
    ['k', 'p', ' ', ' ', ' ', ' ', 'P', 'K'],
    ['b', 'p', ' ', ' ', ' ', ' ', 'P', 'B'],
    ['n', 'p', ' ', ' ', ' ', ' ', 'P', 'N'],
    ['r.', 'p', ' ', ' ', ' ', ' ', 'P', 'R.'],
  ],
        turnCount = 0;

  ChessState.load(this.board, this.turnCount);

  Map<String, dynamic> toJson() {
    return {
      'board': board.map((col) => col.toList()).toList(),
      'turnCount': turnCount,
    };
  }

  static ChessState fromJson(Map<String, dynamic> json) {
    return ChessState.load(
      (json['board'] as List).map((col) => List<String>.from(col)).toList(),
      json['turnCount'],
    );
  }
}


// class ChessCubit extends Cubit<ChessState>
// {
//   ChessCubit() : super( ChessState() );
//
//   void update( Coords fromHere, Coords toHere )
//   { state.board[toHere.c][toHere.r] =
//     state.board[fromHere.c][fromHere.r];
//     state.board[fromHere.c][fromHere.r] = " ";
//     emit( ChessState.load( state.board, state.turnCount+1) );
//   }
// }

class ChessCubit extends HydratedCubit<ChessState> {
  ChessCubit() : super(ChessState());

  void update(Coords fromHere, Coords toHere) {
    state.board[toHere.c][toHere.r] = state.board[fromHere.c][fromHere.r];
    state.board[fromHere.c][fromHere.r] = " ";
    emit(ChessState.load(state.board, state.turnCount + 1));
  }

  @override
  ChessState fromJson(Map<String, dynamic> json) {
    return ChessState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(ChessState state) {
    return state.toJson();
  }
}
