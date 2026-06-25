import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homepod_assistant/providers/app_config.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  MockWeather? _currentWeather;
  List<MockWeather> _forecast = [];
  List<WeatherAlert> _alerts = [];
  bool _isLoading = true;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _currentWeather = MockWeather(
        temperature: 72,
        condition: 'Sunny',
        humidity: 45,
        windSpeed: 8,
        icon: '☀️',
        feelsLike: 74,
        uvIndex: 6,
        visibility: 10,
        pressure: 1013,
      );
      
      _forecast = [
        MockWeather(temperature: 75, condition: 'Partly Cloudy', humidity: 50, windSpeed: 10, icon: '⛅', feelsLike: 77, uvIndex: 5, visibility: 9, pressure: 1012),
        MockWeather(temperature: 68, condition: 'Rainy', humidity: 80, windSpeed: 15, icon: '🌧️', feelsLike: 70, uvIndex: 2, visibility: 5, pressure: 1008),
        MockWeather(temperature: 70, condition: 'Cloudy', humidity: 60, windSpeed: 12, icon: '☁️', feelsLike: 72, uvIndex: 3, visibility: 8, pressure: 1010),
        MockWeather(temperature: 78, condition: 'Sunny', humidity: 40, windSpeed: 6, icon: '☀️', feelsLike: 80, uvIndex: 7, visibility: 10, pressure: 1014),
        MockWeather(temperature: 72, condition: 'Partly Cloudy', humidity: 55, windSpeed: 9, icon: '⛅', feelsLike: 74, uvIndex: 4, visibility: 9, pressure: 1011),
      ];

      _alerts = [
        WeatherAlert('Heat Advisory', 'High temperatures expected', 'High', Colors.orange, DateTime.now().add(const Duration(hours: 2))),
        WeatherAlert('Air Quality Alert', 'Poor air quality conditions', 'Medium', Colors.yellow, DateTime.now().add(const Duration(hours: 6))),
      ];
      
      _isLoading = false;
    });
  }

  void _searchLocation(String query) {
    // Handle search query
    // In a real app, this would trigger location search
  }

  void _setLocation(String location, AppConfig appConfig) {
    appConfig.setWeatherLocation(location);
    _loadWeather();
  }

  void _addToFavorites(String location, AppConfig appConfig) {
    appConfig.addFavoriteLocation(location);
  }

  void _removeFromFavorites(String location, AppConfig appConfig) {
    appConfig.removeFavoriteLocation(location);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppConfig>(
      builder: (context, appConfig, child) {
        return Container(
          width: 300,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wb_sunny, color: Colors.orange, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Weather',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            appConfig.weatherLocation,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showLocationSearch(context, appConfig),
                      icon: const Icon(Icons.location_on, color: Colors.orange, size: 24),
                    ),
                  ],
                ),
              ),
          
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _buildTabButton('Current', 0),
                const SizedBox(width: 8),
                _buildTabButton('Forecast', 1),
                const SizedBox(width: 8),
                _buildTabButton('Alerts', 2),
              ],
            ),
          ),
          
          // Content based on selected tab
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
        );
      },
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTabIndex) {
      case 0:
        return _buildCurrentTab();
      case 1:
        return _buildForecastTab();
      case 2:
        return _buildAlertsTab();
      default:
        return _buildCurrentTab();
    }
  }

  Widget _buildCurrentTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Current Weather
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Text(
                  _currentWeather!.icon,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_currentWeather!.temperature}°F',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _currentWeather!.condition,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Feels like ${_currentWeather!.feelsLike}°F',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Weather Details Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildWeatherDetailCard('Humidity', '${_currentWeather!.humidity}%', Icons.water_drop, Colors.blue),
                _buildWeatherDetailCard('Wind', '${_currentWeather!.windSpeed} mph', Icons.air, Colors.green),
                _buildWeatherDetailCard('UV Index', '${_currentWeather!.uvIndex}', Icons.wb_sunny, Colors.orange),
                _buildWeatherDetailCard('Visibility', '${_currentWeather!.visibility} mi', Icons.visibility, Colors.purple),
              ],
            ),
          ),
          
          // Refresh Button
          Container(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: _loadWeather,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _forecast.length,
      itemBuilder: (context, index) {
        final day = _forecast[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Text(
                day.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDayName(index),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      day.condition,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Humidity: ${day.humidity}% • Wind: ${day.windSpeed} mph',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${day.temperature}°F',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Feels like ${day.feelsLike}°F',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlertsTab() {
    if (_alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            const Text(
              'No Weather Alerts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All clear! No severe weather expected.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: alert.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: alert.color),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: alert.color,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      alert.title,
                      style: TextStyle(
                        color: alert.color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: alert.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      alert.severity,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                alert.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Expected: ${_formatAlertTime(alert.expectedTime)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeatherDetailCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getDayName(int index) {
    final days = ['Today', 'Tomorrow', 'Wednesday', 'Thursday', 'Friday'];
    return days[index];
  }

  String _formatAlertTime(DateTime time) {
    final now = DateTime.now();
    final difference = time.difference(now);
    
    if (difference.inHours < 1) {
      return 'Within the hour';
    } else if (difference.inHours < 24) {
      return 'In ${difference.inHours} hours';
    } else {
      return 'In ${difference.inDays} days';
    }
  }

  void _showLocationSearch(BuildContext context, AppConfig appConfig) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 280,
          height: 350,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.orange, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Search Location',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  onChanged: _searchLocation,
                  decoration: InputDecoration(
                    hintText: 'Enter city name...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    prefixIcon: const Icon(Icons.location_city, color: Colors.orange),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orange, width: 2),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: appConfig.favoriteLocations.length,
                  itemBuilder: (context, index) {
                    final location = appConfig.favoriteLocations[index];
                    final isCurrent = location == appConfig.weatherLocation;
                    return ListTile(
                      leading: Icon(
                        isCurrent ? Icons.my_location : Icons.location_on,
                        color: isCurrent ? Colors.orange : Colors.white70,
                      ),
                      title: Text(
                        location,
                        style: TextStyle(
                          color: isCurrent ? Colors.orange : Colors.white,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isCurrent
                          ? const Icon(Icons.check, color: Colors.orange)
                          : IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () => _removeFromFavorites(location, appConfig),
                            ),
                      onTap: () {
                        _setLocation(location, appConfig);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MockWeather {
  final int temperature;
  final String condition;
  final int humidity;
  final int windSpeed;
  final String icon;
  final int feelsLike;
  final int uvIndex;
  final int visibility;
  final int pressure;

  MockWeather({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    required this.feelsLike,
    required this.uvIndex,
    required this.visibility,
    required this.pressure,
  });
}

class WeatherAlert {
  final String title;
  final String description;
  final String severity;
  final Color color;
  final DateTime expectedTime;

  WeatherAlert(this.title, this.description, this.severity, this.color, this.expectedTime);
} 