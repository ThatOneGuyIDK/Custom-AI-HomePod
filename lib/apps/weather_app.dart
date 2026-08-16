import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homepod_assistant/providers/weather_provider.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _searchLocation(String query, WeatherProvider weatherProvider) {
    final provider = context.read<WeatherProvider>();
    provider.searchLocation(query);
  }

  void _removeFromFavorites(String location, WeatherProvider weatherProvider) {
    weatherProvider.removeFavoriteLocation(location);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        return Consumer<WeatherProvider>(
          builder: (context, weatherProvider, child) {
            return Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
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
                                weatherProvider.locationName,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showLocationSearch(context, weatherProvider),
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
                    child: _buildTabContent(weatherProvider),
                  ),
                ],
              ),
            );
          },
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

  Widget _buildTabContent(WeatherProvider provider) {
    switch (_currentTabIndex) {
      case 0:
        return _buildCurrentTab(provider);
      case 1:
        return _buildForecastTab(provider);
      case 2:
        return _buildAlertsTab(provider);
      default:
        return _buildCurrentTab(provider);
    }
  }

  Widget _buildCurrentTab(WeatherProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    if (provider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Flexible(
              child: Text(
                provider.error,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: provider.fetchWeather,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.currentWeather == null) {
      return const Center(
        child: Text(
          'No weather data',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final current = provider.currentWeather!;
    final weatherList = current['weather'] as List<dynamic>? ?? [];
    final weatherMain = weatherList.isNotEmpty ? weatherList.first : {};
    final iconCode = weatherMain['icon'] ?? '01d';
    final temp = current['temp']?.toDouble() ?? 0.0;
    final feelsLike = current['feels_like']?.toDouble() ?? 0.0;
    final humidity = current['humidity'] ?? 0;
    final windSpeed = current['wind_speed']?.toDouble() ?? 0.0;
    final uvi = current['uvi']?.toDouble() ?? 0.0;
    final visibility = (current['visibility'] ?? 0) / 1609.34;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Current Weather
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Text(
                  provider.getWeatherIcon(iconCode),
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 12),
                Text(
                  '${temp.round()}°F',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  provider.getCondition(iconCode),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Feels like ${feelsLike.round()}°F',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Weather Details Grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildWeatherDetailCard('Humidity', '$humidity%', Icons.water_drop, Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildWeatherDetailCard('Wind', '${windSpeed.toStringAsFixed(1)} mph', Icons.air, Colors.green)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildWeatherDetailCard('UV Index', '$uvi', Icons.wb_sunny, Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildWeatherDetailCard('Visibility', '${visibility.toStringAsFixed(1)} mi', Icons.visibility, Colors.purple)),
                ],
              ),
            ],
          ),

          // Refresh Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 12),
            child: ElevatedButton.icon(
              onPressed: provider.fetchWeather,
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

  Widget _buildForecastTab(WeatherProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    if (provider.forecast.isEmpty) {
      return const Center(
        child: Text(
          'No forecast data',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: provider.forecast.length > 5 ? 5 : provider.forecast.length,
      itemBuilder: (context, index) {
        final day = provider.forecast[index];
        final temp = day['temp'] as Map<String, dynamic>? ?? {};
        final dayTemp = temp['day']?.toDouble() ?? 0.0;
        final feelsLike = temp['feels_like']?.toDouble() ?? 0.0;
        final humidity = day['humidity'] ?? 0;
        final windSpeed = day['wind_speed']?.toDouble() ?? 0.0;
        final weatherList = day['weather'] as List<dynamic>? ?? [];
        final weatherMain = weatherList.isNotEmpty ? weatherList.first : {};
        final iconCode = weatherMain['icon'] ?? '01d';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Text(
                provider.getWeatherIcon(iconCode),
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.getDayName(index),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      provider.getCondition(iconCode),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Humidity: $humidity% • Wind: ${windSpeed.toStringAsFixed(1)} mph',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
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
                    '${dayTemp.round()}°F',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Feels like ${feelsLike.round()}°F',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
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

  Widget _buildAlertsTab(WeatherProvider provider) {
    if (provider.alerts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 16),
            Text(
              'No Weather Alerts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'All clear! No severe weather expected.',
              style: TextStyle(
                color: Colors.white70,
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
      itemCount: provider.alerts.length,
      itemBuilder: (context, index) {
        final alert = provider.alerts[index];
        final severity = alert['severity'] ?? 'Unknown';
        final color = _getAlertColor(severity);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      alert['event'] ?? 'Weather Alert',
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      severity,
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
                alert['description'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Expected: ${_formatAlertTime(alert)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getAlertColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.blue;
    }
  }

  void _showLocationSearch(BuildContext context, WeatherProvider weatherProvider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 280,
          height: 350,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
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
                  onSubmitted: (query) => _searchLocation(query, weatherProvider),
                  decoration: InputDecoration(
                    hintText: 'Enter city name...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    prefixIcon: const Icon(Icons.location_city, color: Colors.orange),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
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
                child: Consumer<WeatherProvider>(
                  builder: (context, weatherProvider, child) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: weatherProvider.favoriteLocations.length,
                      itemBuilder: (context, index) {
                        final location = weatherProvider.favoriteLocations[index];
                        final isCurrent = location == weatherProvider.weatherLocation;
                        return ListTileTheme(
                          style: ListTileStyle.drawer,
                          child: ListTile(
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
                                    onPressed: () => _removeFromFavorites(location, weatherProvider),
                                  ),
                            onTap: () {
                              _searchLocation(location, weatherProvider);
                              Navigator.of(context).pop();
                            },
                          ),
                        );
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

String _formatAlertTime(Map<String, dynamic> alert) {
  final now = DateTime.now();
  DateTime? startTime;

  if (alert['start'] != null) {
    startTime = DateTime.fromMillisecondsSinceEpoch(alert['start'] * 1000);
  } else if (alert['ends'] != null) {
    startTime = DateTime.fromMillisecondsSinceEpoch(alert['ends'] * 1000);
  }

  if (startTime == null) return 'Unknown time';

  final difference = startTime.difference(now);

  if (difference.inHours < 1) {
    return 'Within the hour';
  } else if (difference.inHours < 24) {
    return 'In ${difference.inHours} hours';
  } else {
    return 'In ${difference.inDays} days';
  }
}