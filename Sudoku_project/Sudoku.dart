import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Sudoku',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SudokuBoard(),
    );
  }
}

class SudokuBoard extends StatefulWidget {
  const SudokuBoard({super.key});

  @override
  State<SudokuBoard> createState() => _SudokuBoardState();
}

class _SudokuBoardState extends State<SudokuBoard> {
  static const int gridSize = 4;
  List<List<int>> board = List.generate(gridSize, (_) => List.filled(gridSize, 0));
  int selectedRow = -1;
  int selectedCol = -1;
  late SharedPreferences prefs;
  int bestTime = 9999; // seconds

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _generatePuzzle();
  }

  Future<void> _loadHighScore() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      bestTime = prefs.getInt('bestTime') ?? 9999;
    });
  }

  void _generatePuzzle() {
    board[0][0] = 1;
    board[1][1] = 2;
    board[2][2] = 3;
    board[3][3] = 4;
  }

  void _handleTap(int row, int col) {
    setState(() {
      selectedRow = row;
      selectedCol = col;
    });
  }

  void _handleInput(int num) {
    if (selectedRow != -1 && selectedCol != -1) {
      setState(() {
        board[selectedRow][selectedCol] = num;
      });

      if (_checkWin()) {
        _showWinDialog();
      }
    }
  }

  bool _checkWin() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (board[i][j] == 0) return false;
      }
    }
    return true;
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: const Text('You solved the puzzle!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                board = List.generate(gridSize, (_) => List.filled(gridSize, 0));
                _generatePuzzle();
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(gridSize, (index) {
        return ElevatedButton(
          onPressed: () => _handleInput(index + 1),
          child: Text('${index + 1}'),
        );
      }),
    );
  }

  Widget _buildCell(int row, int col) {
    bool isSelected = row == selectedRow && col == selectedCol;
    return GestureDetector(
      onTap: () => _handleTap(row, col),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: isSelected ? Colors.lightBlueAccent : Colors.white,
        ),
        child: Center(
          child: Text(
            board[row][col] == 0 ? '' : board[row][col].toString(),
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
        ),
        itemCount: gridSize * gridSize,
        itemBuilder: (context, index) {
          int row = index ~/ gridSize;
          int col = index % gridSize;
          return _buildCell(row, col);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Sudoku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                board = List.generate(gridSize, (_) => List.filled(gridSize, 0));
                _generatePuzzle();
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildBoard(),
              const SizedBox(height: 20),
              _buildNumberInput(),
              const SizedBox(height: 20),
              Text('Best Time: $bestTime sec'),
            ],
          ),
        ),
      ),
    );
  }
}
