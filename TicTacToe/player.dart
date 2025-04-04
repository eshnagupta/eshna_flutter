import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "said_state.dart";
import "game_state.dart";
import "yak_state.dart";

class Player extends StatelessWidget {
  final bool iStart;
  Player(this.iStart, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameCubit>(
      create: (context) => GameCubit(iStart),
      child: BlocBuilder<GameCubit, GameState>(
        builder: (context, state) => BlocProvider<SaidCubit>(
          create: (context) => SaidCubit(),
          child: BlocBuilder<SaidCubit, SaidState>(
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: Text("player")),
              body: Player2(),
            ),
          ),
        ),
      ),
    );
  }
}

class Player2 extends StatelessWidget {
  Widget build(BuildContext context) {
    YakCubit yc = BlocProvider.of<YakCubit>(context);
    YakState ys = yc.state;
    SaidCubit sc = BlocProvider.of<SaidCubit>(context);

    if (ys.socket != null && !ys.listened) {
      sc.listen(context);
      yc.updateListen();
    }
    return Player3();
  }
}

class Player3 extends StatelessWidget {
  Player3({super.key});
  final TextEditingController chatCtrl = TextEditingController();

  Widget build(BuildContext context) {
    SaidCubit sc = BlocProvider.of<SaidCubit>(context);
    SaidState ss = sc.state;
    YakCubit yc = BlocProvider.of<YakCubit>(context);

    return Column(
      children: [
        Row(children: [Sq(0), Sq(1), Sq(2)]),
        Row(children: [Sq(3), Sq(4), Sq(5)]),
        Row(children: [Sq(6), Sq(7), Sq(8)]),
        Text("said: ${ss.said}"),
        ElevatedButton(
          onPressed: () {
            yc.say("resign");
            sc.update("You resigned. Opponent wins.");
          },
          child: Text("Resign"),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            controller: chatCtrl,
            decoration: InputDecoration(labelText: "Type message"),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            String msg = chatCtrl.text.trim();
            if (msg.isNotEmpty) {
              yc.say("chat:$msg");
              sc.update("You: $msg");
              chatCtrl.clear();
            }
          },
          child: Text("Send Chat"),
        ),
      ],
    );
  }
}

class Sq extends StatelessWidget {
  final int sn;
  Sq(this.sn, {super.key});

  Widget build(BuildContext context) {
    GameCubit gc = BlocProvider.of<GameCubit>(context);
    GameState gs = gc.state;
    YakCubit yc = BlocProvider.of<YakCubit>(context);

    return ElevatedButton(
      onPressed: gs.myTurn && gs.board[sn] == GameCubit.d
          ? () {
        gc.play(sn);
        yc.say("sq $sn");
      }
          : null,
      child: Text(gs.board[sn]),
    );
  }
}
