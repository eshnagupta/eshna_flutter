import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './chess_state.dart';
import './move_state.dart';
import './coords.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Retrieve the correct directory for persistent storage
  final directory = await getApplicationDocumentsDirectory();

  // Use a HydratedStorageDirectory instead of Directory
  final storage = await HydratedStorage.build(
    storageDirectory: directory as HydratedStorageDirectory,  // Pass the correct type
  );

  HydratedBloc.storage = storage;

  runApp(Chess());
}


class Chess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "chess",
      home: BlocProvider<ChessCubit>(
        create: (context) => ChessCubit(),
        child: BlocBuilder<ChessCubit, ChessState>(
          builder: (context, state) => BlocProvider<MoveCubit>(
            create: (context) => MoveCubit(),
            child: BlocBuilder<MoveCubit, MoveState>(
              builder: (context, state) => Chess1(),
            ),
          ),
        ),
      ),
    );
  }
}


class Chess1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("chess")),
      body: drawBoard(context),
    );
  }

  Widget drawBoard(BuildContext context) {
    ChessCubit cc = BlocProvider.of<ChessCubit>(context);
    ChessState cs = cc.state;

    Column theGrid = Column(children: []);

    if (cs.turnCount % 2 == 0) {
      // white's turn, draw rank 1 at bottom
      for (int row = 7; row >= 0; row--) {
        Row r = Row(children: []);
        for (int col = 0; col < 8; col++) {
          r.children.add(Square(Coords(col, row), cs.board[col][row]));
        }
        theGrid.children.add(r);
      }
    } else {
      for (int row = 0; row < 8; row++) {
        Row r = Row(children: []);
        for (int col = 7; col >= 0; col--) {
          r.children.add(Square(Coords(col, row), cs.board[col][row]));
        }
        theGrid.children.add(r);
      }
    }

    return theGrid;
  }
}

class Square extends StatelessWidget {
  Coords here;
  String letter;
  bool light; // true means light-colored square

  Square(this.here, this.letter) : light = ((here.r + here.c) % 2 == 1);

  @override
  Widget build(BuildContext context) {
    MoveCubit mc = BlocProvider.of<MoveCubit>(context);
    MoveState ms = mc.state;
    ChessCubit cc = BlocProvider.of<ChessCubit>(context);
    ChessState cs = cc.state;

    return Listener(
      onPointerDown: (_) {
        print("mouse down at  ${here.c},${here.r}");
        mc.mouseDown(here, cc);
      },
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: light ? Colors.white : Colors.grey,
          border: Border.all(),
        ),
        child: Text(letter, style: TextStyle(fontSize: 30)),
      ),
    );
  }
}
