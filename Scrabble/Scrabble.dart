// A complete Flutter/Dart implementation for a simplified network-based Scrabble-like game
// Focus: GUI board, networking, and basic game logic with drag-and-drop support
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';

void main() => runApp(ScrabbleApp());

class ScrabbleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Scrabble',
      home: ConnectionScreen(),
    );
  }
}

class ConnectionScreen extends StatefulWidget {
  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final TextEditingController ipController = TextEditingController();
  bool isHost = false;

  void startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          isHost: isHost,
          hostIp: ipController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connect to Game')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: ipController,
              decoration: InputDecoration(labelText: 'Host IP (leave blank for host)'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    isHost = true;
                    startGame();
                  },
                  child: Text('Host'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    isHost = false;
                    startGame();
                  },
                  child: Text('Client'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final bool isHost;
  final String hostIp;

  GameScreen({required this.isHost, required this.hostIp});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final int boardSize = 10;
  List<List<String>> board = [];
  List<String> myRack = [];
  List<String> bag = [];
  Socket? socket;
  bool myTurn = false;

  @override
  void initState() {
    super.initState();
    initBoard();
    initBag();
    if (widget.isHost) startHost(); else connectToHost();
  }

  void initBoard() {
    board = List.generate(boardSize, (_) => List.filled(boardSize, ''));
  }

  void initBag() {
    List<String> letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    bag = [];
    for (int i = 0; i < 3; i++) {
      bag.addAll(letters);
    }
    bag.shuffle();
    drawRack();
  }

  void drawRack() {
    while (myRack.length < 7 && bag.isNotEmpty) {
      myRack.add(bag.removeLast());
    }
    setState(() {});
  }

  void startHost() async {
    ServerSocket server = await ServerSocket.bind(InternetAddress.anyIPv4, 4040);
    server.listen((client) {
      socket = client;
      socket!.listen(onData);
      myTurn = true;
      setState(() {});
    });
  }

  void connectToHost() async {
    socket = await Socket.connect(widget.hostIp, 4040);
    socket!.listen(onData);
  }

  void onData(Uint8List data) {
    var msg = jsonDecode(utf8.decode(data));
    if (msg['type'] == 'move') {
      board[msg['x']][msg['y']] = msg['letter'];
      myTurn = true;
      drawRack();
      setState(() {});
    }
  }

  void sendMove(int x, int y, String letter) {
    socket?.write(jsonEncode({'type': 'move', 'x': x, 'y': y, 'letter': letter}));
  }

  Widget buildBoard() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(boardSize, (i) =>
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(boardSize, (j) =>
                  DragTarget<String>(
                    onWillAccept: (data) => myTurn && board[i][j] == '',
                    onAccept: (letter) {
                      setState(() {
                        board[i][j] = letter;
                        myRack.remove(letter);
                        sendMove(i, j, letter);
                        myTurn = false;
                      });
                    },
                    builder: (context, candidateData, rejectedData) => Container(
                      key: ValueKey(board[i][j]),
                      width: 30,
                      height: 30,
                      margin: EdgeInsets.all(1),
                      color: board[i][j] == '' ? Colors.grey[300] : Colors.green[200],
                      alignment: Alignment.center,
                      child: Text(board[i][j], style: TextStyle(fontSize: 20)),
                    ),
                  ),
              ),
            ),
        ),
      ),
    );
  }

  Widget buildRack() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: myRack.map((char) => Draggable<String>(
          data: char,
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              width: 40,
              height: 40,
              color: Colors.blue,
              alignment: Alignment.center,
              child: Text(char, style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
          ),
          childWhenDragging: Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.all(4),
            color: Colors.grey,
          ),
          child: Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.all(4),
            color: Colors.blue,
            alignment: Alignment.center,
            child: Text(char, style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
        )).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double boardSize = (min(screenWidth, screenHeight) * 0.75).clamp(200, 300);

    return Scaffold(
      appBar: AppBar(title: Text(myTurn ? 'Your Turn' : 'Opponent\'s Turn')),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: boardSize,
              height: boardSize,
              child: buildBoard(),
            ),
            SizedBox(height: 10),
            buildRack(),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
