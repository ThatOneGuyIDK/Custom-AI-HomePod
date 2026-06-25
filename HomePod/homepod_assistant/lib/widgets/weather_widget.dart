import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class WeatherWidget extends StatefulWidget {
  final double size;
  final Color? accentColor;
  
  const WeatherWidget({
    super.key,
    this.size = 200,
    this.accentColor,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget>
    with TickerProviderStateMixin {
  MockWeather? _currentWeather;
  List<MockWeather> _forecast = [];
  bool _isLoading = true;
  String _error = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _loadWeather();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // Mock weather data for testing
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _currentWeather = MockWeather(
          temperature: 22.5,
          condition: 'Partly Cloudy',
          humidity: 65,
          windSpeed: 12.0,
          icon: 'partly-cloudy-day',
        );
        
        _forecast = [
          MockWeather(
            temperature: 24.0,
            condition: 'Sunny',
            humidity: 60,
            windSpeed: 8.0,
            icon: 'clear-day',
            date: DateTime.now().add(const Duration(days: 1)),
          ),
          MockWeather(
            temperature: 20.0,
            condition: 'Rainy',
            humidity: 80,
            windSpeed: 15.0,
            icon: 'rain',
            date: DateTime.now().add(const Duration(days: 2)),
          ),
        ];
        
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  String _getWeatherIcon(String condition) {
    // Map weather conditions to emojis for mock data
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear-day':
        return '☀️';
      case 'partly cloudy':
      case 'partly-cloudy-day':
        return '⛅';
      case 'cloudy':
        return '☁️';
      case 'rainy':
      case 'rain':
        return '🌧️';
      case 'snowy':
      case 'snow':
        return '❄️';
      case 'stormy':
      case 'thunderstorm':
        return '⛈️';
      case 'foggy':
      case 'fog':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_error.isNotEmpty) {
      return _buildErrorWidget();
    }

    if (_currentWeather == null) {
      return _buildNoDataWidget();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildWeatherDisplay(),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: (widget.accentColor ?? Colors.blue).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: widget.accentColor ?? Colors.blue,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red.withOpacity(0.1),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: widget.size * 0.2,
            ),
            const SizedBox(height: 8),
            Text(
              'Weather Error',
              style: TextStyle(
                color: Colors.red,
                fontSize: widget.size * 0.08,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to retry',
              style: TextStyle(
                color: Colors.red.withOpacity(0.7),
                fontSize: widget.size * 0.06,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withOpacity(0.1),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              color: Colors.grey,
              size: widget.size * 0.2,
            ),
            const SizedBox(height: 8),
            Text(
              'No Weather Data',
              style: TextStyle(
                color: Colors.grey,
                fontSize: widget.size * 0.08,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDisplay() {
    final weather = _currentWeather!;
    final accentColor = widget.accentColor ?? Colors.blue;
    
    return GestureDetector(
      onTap: _loadWeather,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              accentColor.withOpacity(0.2),
              accentColor.withOpacity(0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          border: Border.all(
            color: accentColor.withOpacity(0.4),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Background weather icon
            Positioned(
              top: widget.size * 0.1,
              left: widget.size * 0.1,
              right: widget.size * 0.1,
              child: Center(
                child: Text(
                  _getWeatherIcon(weather.condition),
                  style: TextStyle(fontSize: widget.size * 0.3),
                ),
              ),
            ),
            
            // Temperature display
            Positioned(
              bottom: widget.size * 0.25,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '${weather.temperature.round()}°C',
                  style: TextStyle(
                    fontSize: widget.size * 0.15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            // Location name
            Positioned(
              bottom: widget.size * 0.1,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: widget.size * 0.08,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            // Weather description
            Positioned(
              top: widget.size * 0.45,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  weather.condition,
                  style: TextStyle(
                    fontSize: widget.size * 0.08,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            // Refresh indicator
            Positioned(
              top: widget.size * 0.05,
              right: widget.size * 0.05,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.refresh,
                  color: accentColor,
                  size: widget.size * 0.08,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 

class MockWeather {
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final String icon;
  final DateTime? date;

  MockWeather({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    this.date,
  });
} 