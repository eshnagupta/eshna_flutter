import "dart:io";
import "dart:typed_data";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "yak_state.dart";
import "game_state.dart";

class SaidState {
  String said;
  SaidState(this.said);
}

class SaidCubit extends Cubit<SaidState> {
  SaidCubit() : super(SaidState("and so it begins ....\n"));

  void update(String s) {
    emit(SaidState(s));
  }

  void listen(BuildContext bc) {
    YakCubit yc = BlocProvider.of<YakCubit>(bc);
    YakState ys = yc.state;
    GameCubit gc = BlocProvider.of<GameCubit>(bc);

    ys.socket!.listen(
          (Uint8List data) async {
        final message = String.fromCharCodes(data);

        if (message.startsWith("chat:")) {
          update("Opponent: ${message.substring(5)}");
        } else if (message == "resign") {
          update("Opponent resigned. You win!");
        } else if (message == "pass") {
          gc.pass();
          update("Opponent passed.");
        } else {
          gc.handle(message);
        }
      },
      onError: (error) {
        print(error);
        ys.socket!.close();
      },
    );
  }
}