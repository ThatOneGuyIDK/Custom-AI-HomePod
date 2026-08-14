import 'package:flutter/material.dart';
import 'package:homepod_assistant/services/weather_service.dart';
import 'package:homepod_assistant/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherProvider extends ChangeNotifier {
  static const String _weatherLocationKey = 'weather_location';
  static const String _weatherLatKey = 'weather_lat';
  static const String _weatherLonKey = 'weather_lon';
  static const String _weatherFavoritesKey = 'weather_favorites';
  static const String _defaultWeatherLocation = 'San Francisco, CA';

  final WeatherService _service;

  bool _isLoading = false;
  String _error = '';
  double _lat = 37.7749;
  double _lon = -122.4194;
  String _locationName = 'San Francisco, CA';
  String _weatherLocation = _defaultWeatherLocation;
  final List<String> _favoriteLocations = [_defaultWeatherLocation, 'New York, NY', 'Los Angeles, CA', 'Weyers Cave, Virginia', 'Charlottesville, Virginia'];

  Map<String, dynamic>? _currentWeather;
  List<dynamic> _forecast = [];
  List<dynamic> _alerts = [];

  bool get isLoading => _isLoading;
  String get error => _error;
  double get lat => _lat;
  double get lon => _lon;
  String get locationName => _locationName;
  String get weatherLocation => _weatherLocation;
  List<String> get favoriteLocations => List.unmodifiable(_favoriteLocations);
  Map<String, dynamic>? get currentWeather => _currentWeather;
  List<dynamic> get forecast => _forecast;
  List<dynamic> get alerts => _alerts;

  WeatherProvider() : _service = WeatherService(apiKey: AppConfig.weatherApiKey) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _weatherLocation = prefs.getString(_weatherLocationKey) ?? _defaultWeatherLocation;
      _lat = prefs.getDouble(_weatherLatKey) ?? 37.7749;
      _lon = prefs.getDouble(_weatherLonKey) ?? -122.4194;

      final favoritesJson = prefs.getString(_weatherFavoritesKey);
      if (favoritesJson != null) {
        try {
          _favoriteLocations.clear();
          _favoriteLocations.addAll(List<String>.from(favoritesJson.split(',')));
          if (!_favoriteLocations.contains(_defaultWeatherLocation)) {
            _favoriteLocations.add(_defaultWeatherLocation);
          }
        } catch (e) {
          print('Failed to parse favorites: $e');
        }
      }

      notifyListeners();
      if (AppConfig.isValidApiKey(AppConfig.weatherApiKey)) {
        Future.delayed(Duration.zero, () => fetchWeather());
      }
    } catch (e) {
      print('Failed to load weather settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_weatherLocationKey, _weatherLocation);
      await prefs.setDouble(_weatherLatKey, _lat);
      await prefs.setDouble(_weatherLonKey, _lon);
      await prefs.setString(_weatherFavoritesKey, _favoriteLocations.join(','));
    } catch (e) {
      print('Failed to save weather settings: $e');
    }
  }

  Future<void> setWeatherLocation(String location) async {
    if (_weatherLocation != location) {
      _weatherLocation = location;

      if (!_favoriteLocations.contains(location)) {
        _favoriteLocations.add(location);
      }

      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> addFavoriteLocation(String location) async {
    if (!_favoriteLocations.contains(location)) {
      _favoriteLocations.add(location);
      await _saveSettings();
      notifyListeners();
    }
  }

  Future<void> removeFavoriteLocation(String location) async {
    if (_favoriteLocations.contains(location) && location != _defaultWeatherLocation) {
      _favoriteLocations.remove(location);
      await _saveSettings();
      notifyListeners();
    }
  }

  List<String> getSuggestedLocations() {
    return [
      'San Francisco, CA',
      'New York, NY',
      'Los Angeles, CA',
      'Chicago, IL',
      'Houston, TX',
      'Phoenix, AZ',
      'Philadelphia, PA',
      'San Antonio, TX',
      'San Diego, CA',
      'Dallas, TX',
      'Austin, TX',
      'San Jose, CA',
      'Fort Worth, TX',
      'Jacksonville, FL',
      'Columbus, OH',
      'Charlotte, NC',
      'Indianapolis, IN',
      'Seattle, WA',
      'Denver, CO',
      'Weyers Cave, Virginia',
      'Charlottesville, Virginia',
    ];
  }

  Future<void> fetchWeather() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final currentData = await _service.getCurrentWeather(lat: _lat, lon: _lon);
      final forecastData = await _service.getForecast(lat: _lat, lon: _lon);

      _currentWeather = currentData;
      _forecast = _aggregateDailyForecast(forecastData['list'] ?? []);
      _alerts = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _aggregateDailyForecast(List<dynamic> list) {
    final Map<String, List<dynamic>> byDay = {};
    for (final item in list) {
      final date = item['dt_txt'].split(' ')[0];
      byDay.putIfAbsent(date, () => []);
      byDay[date]!.add(item);
    }
    return byDay.entries.map((entry) {
      final items = entry.value;
      final mains = items.map((i) => i['main'] as Map<String, dynamic>).toList();
      final maxTemp = mains.map((t) => (t['temp_max'] as num).toDouble()).reduce((a, b) => a > b ? a : b);
      final minTemp = mains.map((t) => (t['temp_min'] as num).toDouble()).reduce((a, b) => a < b ? a : b);
      final avgFeelsLike = mains.fold(0.0, (sum, t) => sum + (t['feels_like'] as num).toDouble()) / mains.length;
      final avgHumidity = mains.fold(0, (sum, t) => sum + (t['humidity'] as num).toInt()) ~/ mains.length;
      final winds = items.map((i) => ((i['wind'] as Map<String, dynamic>)['speed'] as num).toDouble());
      final avgWindSpeed = winds.fold(0.0, (sum, s) => sum + s) / winds.length;
      final icon = items.first['weather'].first['icon'] as String;
      return {
        'dt': items.first['dt'],
        'temp': {'day': maxTemp, 'min': minTemp, 'feels_like': avgFeelsLike},
        'humidity': avgHumidity,
        'wind_speed': avgWindSpeed,
        'weather': items.first['weather'],
        'icon': icon,
      };
    }).toList();
  }

  Future<void> searchLocation(String query) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final results = await _service.geocodeLocation(query);

      if (results.isEmpty) {
        _error = 'Location not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final first = results.first;
      _lat = first['lat'].toDouble();
      _lon = first['lon'].toDouble();
      _locationName = query;
      _weatherLocation = query;
      _isLoading = false;
      notifyListeners();

      await _saveSettings();
      await fetchWeather();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setLocation(double lat, double lon, String name) {
    _lat = lat;
    _lon = lon;
    _locationName = name;
    _weatherLocation = name;
    notifyListeners();
    _saveSettings();
    fetchWeather();
  }

  String getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
        return '☀️';
      case '01n':
        return '🌙';
      case '02d':
        return '⛅';
      case '02n':
        return '☁️';
      case '03d':
      case '03n':
        return '☁️';
      case '04d':
      case '04n':
        return '☁️';
      case '09d':
      case '09n':
        return '🌧️';
      case '10d':
        return '🌦️';
      case '10n':
        return '🌧️';
      case '11d':
      case '11n':
        return '⛈️';
      case '13d':
      case '13n':
        return '❄️';
      case '50d':
      case '50n':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  String getCondition(String iconCode) {
    switch (iconCode) {
      case '01d':
      case '01n':
        return 'Clear';
      case '02d':
      case '02n':
        return 'Partly Cloudy';
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return 'Cloudy';
      case '09d':
      case '09n':
        return 'Rain';
      case '10d':
      case '10n':
        return 'Rain';
      case '11d':
      case '11n':
        return 'Thunderstorm';
      case '13d':
      case '13n':
        return 'Snow';
      case '50d':
      case '50n':
        return 'Fog';
      default:
        return 'Unknown';
    }
  }

  String getDayName(int index) {
    if (index == 0) return 'Today';
    if (index == 1) return 'Tomorrow';
    final now = DateTime.now();
    final daysOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final targetWeekday = ((now.weekday - 1 + index) % 7);
    return daysOfWeek[targetWeekday];
  }
}
