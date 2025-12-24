import 'package:flutter/material.dart';
import 'weather_service.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _cityController = TextEditingController();
  final _weatherService = WeatherService();

  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _getWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _weatherService.fetchWeather(city);
      setState(() {
        _weatherData = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load weather data';
        _weatherData = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final temp = _weatherData?['main']?['temp'];
    final description = _weatherData?['weather']?[0]?['description'];
    final cityName = _weatherData?['name'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App V1.0'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _getWeather,
                child: Text(_isLoading ? 'Loading...' : 'Get Weather'),
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            if (_weatherData != null && _errorMessage == null) ...[
              Text(
                cityName != null ? '$cityName' : '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                temp != null ? '$temp °C' : '',
                style: const TextStyle(
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description != null ? '$description' : '',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
