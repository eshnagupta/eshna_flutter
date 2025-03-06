import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(DealOrNoDealApp());
}

class DealOrNoDealApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deal or No Deal',
      theme: ThemeData.dark(),
      home: DealOrNoDealGame(),
    );
  }
}

class DealOrNoDealGame extends StatefulWidget {
  @override
  _DealOrNoDealGameState createState() => _DealOrNoDealGameState();
}

class _DealOrNoDealGameState extends State<DealOrNoDealGame> {
  List<int> values = [1, 5, 10, 100, 1000, 5000, 10000, 100000, 500000, 1000000];
  List<bool> opened = List.generate(10, (_) => false);
  int? playerCase;
  bool gameEnded = false;
  double dealerOffer = 0;
  bool awaitingChoice = false;

  @override
  void initState() {
    super.initState();
    values.shuffle();
    loadGame();
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyD && !gameEnded && !awaitingChoice) {
        acceptDeal();
      } else if (event.logicalKey == LogicalKeyboardKey.keyN && !gameEnded && !awaitingChoice) {
        setState(() {
          awaitingChoice = true;
        });
      } else if (event.logicalKey.keyId >= LogicalKeyboardKey.digit0.keyId &&
          event.logicalKey.keyId <= LogicalKeyboardKey.digit9.keyId) {
        int index = event.logicalKey.keyId - LogicalKeyboardKey.digit0.keyId;
        if (index >= 0 && index < 10) {
          chooseCase(index);
        }
      }
    }
  }

  void saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('values', values.map((e) => e.toString()).toList());
    prefs.setStringList('opened', opened.map((e) => e.toString()).toList());
    prefs.setInt('playerCase', playerCase ?? -1);
    prefs.setBool('gameEnded', gameEnded);
  }

  void loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      values = prefs.getStringList('values')?.map(int.parse).toList() ?? values;
      opened = prefs.getStringList('opened')?.map((e) => e == 'true').toList() ?? opened;
      playerCase = prefs.getInt('playerCase') == -1 ? null : prefs.getInt('playerCase');
      gameEnded = prefs.getBool('gameEnded') ?? false;
    });
  }

  void resetGame() {
    setState(() {
      values.shuffle();
      opened = List.generate(10, (_) => false);
      playerCase = null;
      gameEnded = false;
      awaitingChoice = false;
    });
    saveGame();
  }

  void chooseCase(int index) {
    if (playerCase == null) {
      setState(() {
        playerCase = index;
      });
    } else if (!opened[index] && index != playerCase) {
      setState(() {
        opened[index] = true;
        awaitingChoice = false;
        updateDealerOffer();
      });
    }
    saveGame();
  }

  void updateDealerOffer() {
    List<int> remainingValues = values.asMap().entries.where((e) => !opened[e.key] && e.key != playerCase).map((e) => e.value).toList();
    if (remainingValues.isEmpty) {
      gameEnded = true;
      return;
    }
    double expectedValue = remainingValues.reduce((a, b) => a + b) / remainingValues.length;
    dealerOffer = expectedValue * 0.9;
  }

  void acceptDeal() {
    setState(() {
      gameEnded = true;
    });
    saveGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Deal or No Deal')),
      body: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
            itemCount: 10,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => chooseCase(index),
                child: Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: opened[index] ? Colors.grey : Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      opened[index] ? '\$${values[index]}' : 'Case ${index + 1}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
          Text('Dealer Offer: \$${dealerOffer.toStringAsFixed(2)}', style: TextStyle(fontSize: 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: gameEnded || awaitingChoice ? null : acceptDeal, child: Text('DEAL')),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: gameEnded || awaitingChoice ? null : () => setState(() => awaitingChoice = true),
                child: Text('NO DEAL'),
              ),
            ],
          ),
          ElevatedButton(onPressed: resetGame, child: Text('RESET')),
        ],
      ),
    );
  }
}