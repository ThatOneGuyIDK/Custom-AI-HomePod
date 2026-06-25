# 🏠 HomePod Assistant Widget Setup Guide

Welcome to your HomePod-style smart assistant! This guide will help you set up and configure all the widgets and features.

## 🚀 Quick Start

1. **Clone and Setup**: Make sure you have Flutter installed and the project dependencies
2. **Configure API Keys**: Set up your service API keys (see sections below)
3. **Run the App**: Use `flutter run` to start the application
4. **Navigate Widgets**: Swipe left/right or use arrow buttons to switch between widgets

## 📱 Available Widgets

### 1. 🌤️ Weather Widget
**Features**: Current weather, temperature, conditions, location-based data
**Setup Required**: OpenWeatherMap API key

**Configuration**:
```dart
// In lib/config/app_config.dart
static const String weatherApiKey = 'YOUR_ACTUAL_API_KEY';
```

**Get API Key**:
1. Visit [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for a free account
3. Generate an API key
4. Replace `YOUR_OPENWEATHER_API_KEY_HERE` in the config

### 2. 🎵 Spotify Widget
**Features**: Music playback control, track info, album art, play/pause/skip
**Setup Required**: Spotify Developer account and credentials

**Configuration**:
```dart
// In lib/config/app_config.dart
static const String spotifyClientId = 'YOUR_CLIENT_ID';
static const String spotifyClientSecret = 'YOUR_CLIENT_SECRET';
static const String spotifyRedirectUrl = 'YOUR_REDIRECT_URL';
```

**Get Spotify Credentials**:
1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new app
3. Get Client ID and Client Secret
4. Add redirect URL (e.g., `http://localhost:8080/callback`)
5. Update the config file

### 3. 🏠 Smart Home Widget
**Features**: MQTT device control, lights, plugs, thermostat, real-time status
**Setup Required**: MQTT broker (local or cloud)

**Configuration**:
```dart
// In lib/config/app_config.dart
static const String mqttBroker = 'YOUR_MQTT_BROKER_IP';
static const String mqttUsername = 'YOUR_MQTT_USERNAME';
static const String mqttPassword = 'YOUR_MQTT_PASSWORD';
```

**MQTT Setup Options**:
- **Local**: Install Mosquitto on Raspberry Pi
- **Cloud**: Use services like HiveMQ, CloudMQTT, or AWS IoT

**Local MQTT Setup**:
```bash
# On Raspberry Pi
sudo apt-get install mosquitto mosquitto-clients
sudo systemctl enable mosquitto
sudo systemctl start mosquitto

# Create user
sudo mosquitto_passwd -c /etc/mosquitto/passwd your_username
```

### 4. 📰 News Widget
**Features**: Headlines, calendar events, rotating content, swipe navigation
**Setup Required**: News API key (optional, uses sample data by default)

**Configuration**:
```dart
// Add to lib/config/app_config.dart
static const String newsApiKey = 'YOUR_NEWS_API_KEY';
```

**Get News API Key**:
1. Visit [NewsAPI](https://newsapi.org/)
2. Sign up for free account
3. Get API key
4. Update config file

### 5. ⚙️ Settings Widget
**Features**: API configuration, preferences, MQTT settings, app preferences
**Setup Required**: None (uses local storage)

**Usage**:
- Tap the settings widget to expand
- Configure your API keys and preferences
- Tap "Save Settings" to store changes

## 🔧 Advanced Configuration

### Environment Variables
Create a `.env` file in the project root:
```env
WEATHER_API_KEY=your_weather_key
SPOTIFY_CLIENT_ID=your_spotify_id
SPOTIFY_CLIENT_SECRET=your_spotify_secret
MQTT_BROKER=your_mqtt_broker
MQTT_USERNAME=your_mqtt_username
MQTT_PASSWORD=your_mqtt_password
```

### Custom Widget Development
Create new widgets by extending the base widget pattern:

```dart
class CustomWidget extends StatefulWidget {
  final double size;
  final Color? accentColor;
  
  const CustomWidget({
    super.key,
    this.size = 200,
    this.accentColor,
  });

  @override
  State<CustomWidget> createState() => _CustomWidgetState();
}
```

### Widget Integration
Add new widgets to the home screen:

```dart
// In lib/screens/home_screen.dart
void _initializeWidgets() {
  _widgets.addAll([
    const WeatherWidget(size: 120, accentColor: Colors.blue),
    const SpotifyWidget(size: 120, accentColor: Colors.green),
    const SmartHomeWidget(size: 120, accentColor: Colors.purple),
    const NewsWidget(size: 120, accentColor: Colors.orange),
    const SettingsWidget(size: 120, accentColor: Colors.teal),
    const CustomWidget(size: 120, accentColor: Colors.red), // Add here
  ]);
}
```

## 🌐 Network Configuration

### Local Development
For local development with HTTPS (required for speech recognition):

```bash
# Install ngrok
npm install -g ngrok

# Create HTTPS tunnel
ngrok http 8080

# Use the HTTPS URL provided by ngrok
```

### Production Deployment
For production deployment:

1. **HTTPS Certificate**: Obtain SSL certificate
2. **Domain**: Configure your domain
3. **Firewall**: Open necessary ports (443, 8080)
4. **Reverse Proxy**: Use Nginx or Apache

## 🔒 Security Considerations

### API Key Security
- Never commit API keys to version control
- Use environment variables or secure storage
- Rotate keys regularly
- Implement rate limiting

### MQTT Security
- Use TLS/SSL encryption
- Implement authentication
- Use strong passwords
- Restrict access to necessary topics only

### Network Security
- Enable HTTPS everywhere
- Use strong authentication
- Implement proper CORS policies
- Regular security updates

## 🧪 Testing

### Test Mode
Enable test mode for development:

```dart
// In lib/config/app_config.dart
static const bool isTestMode = true;
```

### Mock Data
Widgets include sample data for testing:
- Weather: Sample weather conditions
- Spotify: Mock player state
- Smart Home: Sample devices
- News: Sample headlines and events

### Debug Panel
Enable debug panel to see:
- System information
- Network status
- Voice service logs
- Performance metrics

## 🚨 Troubleshooting

### Common Issues

**Weather Widget Not Loading**:
- Check API key configuration
- Verify internet connection
- Check location permissions

**Spotify Widget Connection Failed**:
- Verify client ID and secret
- Check redirect URL configuration
- Ensure Spotify app is running

**MQTT Connection Issues**:
- Verify broker IP and port
- Check username/password
- Ensure broker is running
- Check firewall settings

**Voice Recognition Not Working**:
- Ensure HTTPS is enabled
- Check microphone permissions
- Verify network connectivity
- Try test mode

### Debug Steps
1. Enable debug panel
2. Check console logs
3. Verify API responses
4. Test network connectivity
5. Check device permissions

## 📱 Mobile Companion App

### Features
- Remote control functionality
- Settings management
- Device status monitoring
- Push notifications

### Setup
1. Build mobile app from same codebase
2. Configure shared preferences
3. Set up push notifications
4. Test cross-device communication

## 🔄 Updates and Maintenance

### Regular Tasks
- Update API keys
- Monitor rate limits
- Check for security updates
- Backup configuration
- Monitor performance

### Backup Configuration
```bash
# Backup settings
cp lib/config/app_config.dart backup/
cp .env backup/

# Restore settings
cp backup/app_config.dart lib/config/
cp backup/.env ./
```

## 📚 Additional Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [OpenWeatherMap API](https://openweathermap.org/api)
- [Spotify Web API](https://developer.spotify.com/documentation/web-api)
- [MQTT Protocol](https://mqtt.org/documentation)

### Community
- [Flutter Community](https://flutter.dev/community)
- [Home Assistant Community](https://community.home-assistant.io/)
- [MQTT Community](https://mqtt.org/community)

### Support
- GitHub Issues: Report bugs and request features
- Documentation: Check this guide and inline comments
- Community Forums: Get help from other users

## 🎯 Next Steps

1. **Configure API Keys**: Set up your service accounts
2. **Test Widgets**: Verify each widget works correctly
3. **Customize**: Modify colors, sizes, and behavior
4. **Add Devices**: Connect your smart home devices
5. **Deploy**: Move to production environment
6. **Expand**: Add new widgets and features

---

**Happy coding! 🚀**

If you need help or have questions, check the troubleshooting section or open an issue on GitHub. 