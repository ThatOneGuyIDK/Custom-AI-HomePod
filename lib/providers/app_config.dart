import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig extends ChangeNotifier {
  static const String _weatherLocationKey = 'weather_location';
  static const String _defaultWeatherLocation = 'San Francisco, CA';
  
  String _weatherLocation = _defaultWeatherLocation;
  final List<String> _favoriteLocations = [_defaultWeatherLocation, 'New York, NY', 'Los Angeles, CA', 'Weyers Cave, Virginia', 'Charlottesville, Virginia'];
  
  // Getters
  String get weatherLocation => _weatherLocation;
  List<String> get favoriteLocations => List.unmodifiable(_favoriteLocations);
  
  AppConfig() {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _weatherLocation = prefs.getString(_weatherLocationKey) ?? _defaultWeatherLocation;
      
      // Load favorite locations (in a real app, you'd store this as JSON)
      // For now, we'll keep the default list
      notifyListeners();
    } catch (e) {
      // If SharedPreferences fails, use defaults
      print('Failed to load settings: $e');
    }
  }
  
  Future<void> setWeatherLocation(String location) async {
    if (_weatherLocation != location) {
      _weatherLocation = location;
      
      // Add to favorites if not already there
      if (!_favoriteLocations.contains(location)) {
        _favoriteLocations.add(location);
      }
      
      // Save to persistent storage
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_weatherLocationKey, location);
      } catch (e) {
        print('Failed to save weather location: $e');
      }
      
      notifyListeners();
    }
  }
  
  Future<void> addFavoriteLocation(String location) async {
    if (!_favoriteLocations.contains(location)) {
      _favoriteLocations.add(location);
      // In a real app, you'd save this to persistent storage
      notifyListeners();
    }
  }
  
  Future<void> removeFavoriteLocation(String location) async {
    if (_favoriteLocations.contains(location) && location != _defaultWeatherLocation) {
      _favoriteLocations.remove(location);
      // In a real app, you'd save this to persistent storage
      notifyListeners();
    }
  }
  
  // Get suggested locations for search
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
      'San Francisco, CA',
      'Indianapolis, IN',
      'Seattle, WA',
      'Denver, CO',
      'Weyers Cave, Virginia',
      'Charlottesville, Virginia',
    ];
  }
} 