import "dart:math";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class DragState {
  final List<List<bool>> world;

  DragState(this.world);

  DragState.first() : world = init();

  static List<List<bool>> init() {
    List<List<bool>> grid = [];
    for (int i = 0; i < 20; i++) {
      List<bool> row = [];
      for (int j = 0; j < 20; j++) {
        row.add(Random().nextInt(10) > 6 ? true : false);
      }
      grid.add(row);
    }
    return grid;
  }
}

class DragCubit extends Cubit<DragState> {
  DragCubit() : super(DragState.first());

  void update(List<List<bool>> c) {
    emit(DragState(c));
  }

  void step() {
    List<List<bool>> current = state.world;
    List<List<bool>> next = List.generate(20, (i) => List.generate(20, (j) => false));

    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 20; j++) {
        int neighbors = 0;
        for (int dx = -1; dx <= 1; dx++) {
          for (int dy = -1; dy <= 1; dy++) {
            if (dx == 0 && dy == 0) continue;
            int ni = i + dx, nj = j + dy;
            if (ni >= 0 && ni < 20 && nj >= 0 && nj < 20 && current[ni][nj]) {
              neighbors++;
            }
          }
        }

        if (current[i][j]) {
          next[i][j] = neighbors == 2 || neighbors == 3;
        } else {
          next[i][j] = neighbors == 3;
        }
      }
    }

    update(next);
  }
}

void main() {
  runApp(const Dragger());
}

class Dragger extends StatelessWidget {
  const Dragger({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conway\'s Life',
      home: BlocProvider<DragCubit>(
        create: (context) => DragCubit(),
        child: const Dragger2(),
      ),
    );
  }
}

class Dragger2 extends StatefulWidget {
  const Dragger2({super.key});

  @override
  State<Dragger2> createState() => _Dragger2State();
}

class _Dragger2State extends State<Dragger2> {
  bool isRunning = true;

  @override
  void initState() {
    super.initState();
    runSimulation();
  }

  void runSimulation() async {
    final dg = BlocProvider.of<DragCubit>(context);
    while (true) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (isRunning) {
        dg.step();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dg = BlocProvider.of<DragCubit>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Conway's Game of Life")),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: BlocBuilder<DragCubit, DragState>(
                builder: (context, state) {
                  return Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(border: Border.all(width: 2)),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 400,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 20,
                      ),
                      itemBuilder: (context, index) {
                        int row = index ~/ 20;
                        int col = index % 20;
                        bool alive = state.world[row][col];
                        return Container(
                          margin: const EdgeInsets.all(1),
                          color: alive ? Colors.black : Colors.white,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isRunning = !isRunning;
                  });
                },
                child: Text(isRunning ? "Pause" : "Resume"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  dg.update(DragState.init());
                },
                child: const Text("Reset"),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
