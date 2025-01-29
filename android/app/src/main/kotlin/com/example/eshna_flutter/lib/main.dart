//eshna gupta
import 'dart:math';
import "package:flutter/material.dart";

void main() {
  runApp(DiceRoller());
}

class DiceRoller extends StatelessWidget {
  DiceRoller({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dice Roller",
      home: DiceRollerHome(),
    );
  }
}

class DiceRollerHome extends StatefulWidget {
  @override
  State<DiceRollerHome> createState() => DiceRollerHomeState();
}

class DiceRollerHomeState extends State<DiceRollerHome> {
  int _diceValue = 1; //init value

  void _rollDice() {
    setState(() {
      _diceValue = Random().nextInt(6) + 1; //random num generator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dice Roller")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$_diceValue",//based on number rolled
            style: const TextStyle(
              fontSize: 100,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const Spacer(flex: 1),
          ElevatedButton(
            onPressed: _rollDice,//function called
            child: const Text("Roll Dice"),
          ),
          const Spacer(flex: 1),
          Container(
            decoration: BoxDecoration(
              color: Colors.pink,
              border: Border.all(width: 8),
            ),
            child: const Text(
              "in box",
              style: TextStyle(fontSize: 40),
            ),
          ),
        ],
      ),
    );
  }
}
