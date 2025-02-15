// Eshna Gupta
// File: Calculator.dart


import 'package:flutter/material.dart';

void main() {
  runApp(const Calculator());
}

class Calculator extends StatelessWidget {
  const Calculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CalculatorHome(),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  const CalculatorHome({super.key});

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String inputValue = '';
  String outputValue = '';
  String selectedConversion = 'C-F';

  // Conversion functions
  double celsiusToFahrenheit(double celsius) {
    return (celsius * 9/5) + 32;
  }

  double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5/9;
  }

  double kgToLbs(double kg) {
    return kg * 2.20462;
  }

  double lbsToKg(double lbs) {
    return lbs / 2.20462;
  }

  void onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        inputValue = '';
        outputValue = '';
      } else {
        if (value == '.' && inputValue.contains('.')) return;
        if (value == '-' && inputValue.isNotEmpty) return;
        inputValue += value;

        // Perform conversion immediately when input changes
        try {
          double input = double.parse(inputValue);
          double result;

          switch (selectedConversion) {
            case 'C-F':
              result = celsiusToFahrenheit(input);
              break;
            case 'F-C':
              result = fahrenheitToCelsius(input);
              break;
            case 'Kg-Lb':
              result = kgToLbs(input);
              break;
            case 'Lb-Kg':
              result = lbsToKg(input);
              break;
            default:
              result = 0;
          }

          outputValue = result.toStringAsFixed(4);
        } catch (e) {
          outputValue = '';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Title
            const Text(
              'Converter',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Display area
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    inputValue.isEmpty ? '0' : inputValue,
                    style: const TextStyle(fontSize: 24),
                  ),
                  Text(
                    outputValue.isEmpty ? '0' : outputValue,
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Main content area with keypad and conversion buttons
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Numeric keypad
                Expanded(
                  flex: 2,
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      ...['7', '8', '9', '4', '5', '6', '1', '2', '3', '.', '0', '-']
                          .map((key) => buildButton(key)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Conversion buttons
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      buildConversionButton('C-F'),
                      const SizedBox(height: 8),
                      buildConversionButton('F-C'),
                      const SizedBox(height: 8),
                      buildConversionButton('Kg-Lb'),
                      const SizedBox(height: 8),
                      buildConversionButton('Lb-Kg'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String text) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
        color: Colors.purple.withOpacity(0.1),
      ),
      child: TextButton(
        onPressed: () => onButtonPressed(text),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.purple,
          ),
        ),
      ),
    );
  }

  Widget buildConversionButton(String type) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
        color: selectedConversion == type
            ? Colors.purple.withOpacity(0.2)
            : Colors.purple.withOpacity(0.1),
      ),
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedConversion = type;
            inputValue = '';
            outputValue = '';
          });
        },
        child: Text(
          type,
          style: const TextStyle(
            color: Colors.purple,
          ),
        ),
      ),
    );
  }
}