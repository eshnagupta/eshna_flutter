import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();
  String _weatherInfo = "Enter a city or ZIP code";
  String apiKey = "115dfcf65ed9898c525c7643cb853ee1"; // Replace with your OpenWeatherMap API key

  Future<void> fetchWeather(String location) async {
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey&units=imperial");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weatherInfo = "Temperature: ${data['main']['temp']}°F\n"
              "Wind Speed: ${data['wind']['speed']} mph\n"
              "Direction: ${data['wind']['deg']}°";
        });
      } else {
        setState(() {
          _weatherInfo = "Error: Could not fetch weather";
        });
      }
    } catch (e) {
      setState(() {
        _weatherInfo = "Error: Failed to connect to API";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter City or ZIP Code',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => fetchWeather(_controller.text),
              child: Text('Get Weather'),
            ),
            SizedBox(height: 20),
            Text(
              _weatherInfo,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
