import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homepod_assistant/providers/weather_provider.dart';

class WeatherWidget extends StatelessWidget {
  final double size;
  final Color? accentColor;
  
  const WeatherWidget({
    super.key,
    this.size = 200,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingWidget(provider, size, accentColor);
        }

        if (provider.error.isNotEmpty) {
          return _buildErrorWidget(provider, size, accentColor);
        }

        if (provider.currentWeather == null) {
          return _buildNoDataWidget(provider, size, accentColor);
        }

        return _buildWeatherDisplay(provider, size, accentColor);
      },
    );
  }

  Widget _buildLoadingWidget(WeatherProvider provider, double size, Color? accentColor) {
    final color = accentColor ?? Colors.orange;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(WeatherProvider provider, double size, Color? accentColor) {
    return GestureDetector(
      onTap: provider.fetchWeather,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.withValues(alpha: 0.1),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.3),
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
                size: size * 0.2,
              ),
              const SizedBox(height: 8),
              Text(
                'Weather Error',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: size * 0.08,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to retry',
                style: TextStyle(
                  color: Colors.red.withValues(alpha: 0.7),
                  fontSize: size * 0.06,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataWidget(WeatherProvider provider, double size, Color? accentColor) {
    return GestureDetector(
      onTap: provider.fetchWeather,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withValues(alpha: 0.1),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.3),
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
                size: size * 0.2,
              ),
              const SizedBox(height: 8),
              Text(
                'No Weather Data',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: size * 0.08,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to load',
                style: TextStyle(
                  color: Colors.grey.withValues(alpha: 0.7),
                  fontSize: size * 0.06,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDisplay(WeatherProvider provider, double size, Color? accentColor) {
    final current = provider.currentWeather!;
    final weatherList = current['weather'] as List<dynamic>? ?? [];
    final weatherMain = weatherList.isNotEmpty ? weatherList.first : {};
    final iconCode = weatherMain['icon'] ?? '01d';
    final condition = weatherMain['main'] ?? 'Unknown';
    final temp = current['temp']?.toDouble() ?? 0.0;
    final color = accentColor ?? Colors.orange;
    
    return GestureDetector(
      onTap: provider.fetchWeather,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.1),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Background weather icon
            Positioned(
              top: size * 0.1,
              left: size * 0.1,
              right: size * 0.1,
              child: Center(
                child: Text(
                  provider.getWeatherIcon(iconCode),
                  style: TextStyle(fontSize: size * 0.3),
                ),
              ),
            ),
            
            // Temperature display
            Positioned(
              bottom: size * 0.25,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '${temp.round()}°F',
                  style: TextStyle(
                    fontSize: size * 0.15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            // Location name
            Positioned(
              bottom: size * 0.1,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  provider.locationName,
                  style: TextStyle(
                    fontSize: size * 0.08,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            
            // Weather description
            Positioned(
              top: size * 0.45,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  condition,
                  style: TextStyle(
                    fontSize: size * 0.08,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            
            // Refresh indicator
            Positioned(
              top: size * 0.05,
              right: size * 0.05,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.refresh,
                  color: color,
                  size: size * 0.08,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
