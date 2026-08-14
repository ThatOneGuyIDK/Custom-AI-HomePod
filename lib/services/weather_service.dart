import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String geoUrl = 'https://api.openweathermap.org/geo/1.0';

  final String apiKey;

  WeatherService({required this.apiKey});

  Future<Map<String, dynamic>> getCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    final url =
        '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=imperial';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch current weather: ${response.statusCode}');
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final main = data['main'] as Map<String, dynamic>;
    final wind = data['wind'] as Map<String, dynamic>;
    return {
      'temp': main['temp'],
      'feels_like': main['feels_like'],
      'humidity': main['humidity'],
      'wind_speed': wind['speed'],
      'uvi': 0.0,
      'visibility': data['visibility'] ?? 10000,
      'weather': data['weather'],
      'name': data['name'],
      'dt': data['dt'],
    };
  }

  Future<Map<String, dynamic>> getForecast({
    required double lat,
    required double lon,
  }) async {
    final url =
        '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=imperial';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch forecast data: ${response.statusCode}');
    }
    return json.decode(response.body);
  }

  Future<List<Map<String, dynamic>>> geocodeLocation(String query) async {
    final url = '$geoUrl/direct?q=${Uri.encodeComponent(query)}&limit=5&appid=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to geocode location: ${response.statusCode}');
    }
    final List<dynamic> data = json.decode(response.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}