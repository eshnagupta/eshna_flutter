import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String temperature = "Fetching...";
  String city = "Los Angeles";
  final String apiKey = "f2e7194b82d2ab0ddc20117af530d680";

  @override
  void initState() {
    super.initState();
    fetchTemperature();
  }

  Future<void> fetchTemperature() async {
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperature = "${data["main"]["temp"]}°C";
        });
      } else {
        setState(() {
          temperature = "Error fetching data";
        });
      }
    } catch (e) {
      setState(() {
        temperature = "Failed to load data";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather App")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("City: $city", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text("Temperature: $temperature", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchTemperature,
              child: const Text("Refresh"),
            ),
          ],
        ),
      ),
    );
  }
}
