import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import rootBundle for loading asset files

void main() {
  runApp(QuizApp()); // where app starts
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: QuizScreen(), // set the home screen to QuizScreen
    );
  }
}

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> { //allows widget to be dynamic
  List<Map<String, String>> _questions = []; // list: store quiz questions
  int _currentQuestionIndex = 0; // counter: track current question
  int _score = 0; // current score
  bool _answered = false; // if the user has answered the current question
  String _feedback = ''; // feedback message after answering question
  TextEditingController _answerController = TextEditingController(); // Controller for answer input field

  @override
  void initState() {
    super.initState();
    _loadQuestions(); // load questions upon screen init
  }

  // Loads questions from an asset file
  Future<void> _loadQuestions() async {
    try {
      String data = await rootBundle.loadString('assets/StateCapitols.txt'); // load file from assets
      List<String> lines = data.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();

      if (lines.length > 1) {
        List<String> headers = lines[0].split(',').map((h) => h.trim()).toList(); // get headers from the first line
        for (var i = 1; i < lines.length; i++) {
          List<String> parts = lines[i].split(',').map((p) => p.trim()).toList(); // split each line into key-value pairs
          if (parts.length == 2) {
            _questions.add({headers[0]: parts[0], headers[1]: parts[1]}); // add pair to the list
          }
        }
      }
    } catch (e) {
      print("Error loading questions: $e");
      _useCannedQuiz(); // use canned questions if an error occurs
    }
    setState(() {}); // update UI after answering each question
  }

  // canned quiz in case of an error loading the file
  void _useCannedQuiz() {
    _questions = [
      {'Number': '1', 'Word': 'one'},
      {'Number': '2', 'Word': 'two'},
      {'Number': '3', 'Word': 'three'},
      {'Number': '4', 'Word': 'four'},
      {'Number': '5', 'Word': 'five'},
    ];
  }

  // checks if the user's answer is correct
  void _checkAnswer() {
    setState(() {
      _answered = true;
      String correctAnswer = _questions[_currentQuestionIndex].values.last; // get the correct answer from StateCapitols file
      if (_answerController.text.trim().toLowerCase() == correctAnswer.toLowerCase()) {
        _score++; // if correct
        _feedback = 'Correct!';
      } else {
        _feedback = 'Wrong! Correct answer: $correctAnswer';
      }
    });
  }

  // next Q or shows final score if quiz is completed
  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++; // next question
        _answered = false; // reset answered var
        _feedback = ''; // empty feedback
        _answerController.clear(); // empty input field
      } else {
        _feedback = 'Quiz Completed! Final Score: $_score / ${_questions.length}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator())); // indicator if questions are not loaded
    }

    return Scaffold(
      appBar: AppBar(title: Text('Quiz App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // show current question
            Text(
              '${_questions[_currentQuestionIndex].keys.first}: ${_questions[_currentQuestionIndex].values.first}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // for user input
            TextField(
              controller: _answerController,
              decoration: InputDecoration(labelText: 'Enter your answer'),
            ),

            SizedBox(height: 20),

            // submit button only if the user hasn't answered
            if (!_answered)
              ElevatedButton(onPressed: _checkAnswer, child: Text('Submit')),

            // feedback and next button after answering
            if (_answered) ...[
              Text(_feedback, style: TextStyle(fontSize: 18, color: Colors.red)),
              SizedBox(height: 10),
              ElevatedButton(onPressed: _nextQuestion, child: Text('Next')),
            ],

            SizedBox(height: 20),

            // show user's score
            Text('Score: $_score / ${_questions.length}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
