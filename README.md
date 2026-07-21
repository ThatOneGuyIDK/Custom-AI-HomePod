# HomePod Assistant

A HomePod-style smart assistant for Raspberry Pi with 6-inch round Waveshare touchscreen display. Built with Flutter for optimal performance on embedded hardware.

## Features

### 🖥️ UI & Display
- **Circular Layout**: Optimized for 6-inch round display
- **Clock Widget**: Real-time analog/digital clock display
- **Weather Widget**: Current weather with location support
- **Assistant Indicator**: Visual feedback for voice assistant states
- **Volume Control**: Touch-based volume adjustment
- **Dark Theme**: Elegant dark interface with subtle animations

### 🎤 Voice Assistant (Planned)
- Wake word detection ("Hey HomePod")
- Speech-to-text integration
- Text-to-speech output
- Local AI assistant connection
- Voice command processing

### 🎵 Media Integration (Planned)
- Spotify Connect support
- Local audio playback
- Bluetooth speaker support
- Volume control integration

### 🏠 Smart Home (Planned)
- MQTT device control
- Smart home automation
- Voice-controlled scenes
- Device status display

## Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Raspberry Pi with Raspberry Pi OS
- 6-inch Waveshare round touchscreen

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd homepod_assistant
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Raspberry Pi

#### Quick Build (Recommended)
```bash
# Run the build script
./build_for_pi.sh
```

#### Manual Build
1. **Enable Linux desktop support**
   ```bash
   flutter config --enable-linux-desktop
   ```

2. **Build for Linux**
   ```bash
   flutter build linux --release
   ```

3. **Deploy to Raspberry Pi**
   ```bash
   # Copy the build output to your Raspberry Pi
   scp -r build/linux/x64/release/bundle/ pi@your-pi-ip:/home/pi/homepod_assistant/
   ```

#### Detailed Setup
For complete Raspberry Pi setup instructions, see **[RASPBERRY_PI_DEPLOYMENT.md](RASPBERRY_PI_DEPLOYMENT.md)**

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── providers/
│   └── assistant_state.dart  # Voice assistant state management
├── screens/
│   └── home_screen.dart      # Main circular interface
├── widgets/
│   ├── clock_widget.dart     # Time display
│   ├── weather_widget.dart   # Weather information
│   ├── assistant_indicator.dart # Voice assistant status
│   └── volume_control.dart   # Volume adjustment
├── services/                 # API and external service integrations
├── models/                   # Data models
└── assets/                   # Images, sounds, and animations
```

## Configuration

### Environment Setup
Create a `.env` file in the project root:
```env
# Weather API
OPENWEATHER_API_KEY=your_api_key_here

# Spotify API
SPOTIFY_CLIENT_ID=your_client_id_here
SPOTIFY_CLIENT_SECRET=your_client_secret_here

# Local AI Assistant
LOCAL_AI_URL=http://localhost:8080

# MQTT Configuration
MQTT_BROKER=localhost
MQTT_PORT=1883
```

## Development Roadmap

### Phase 1: Core UI ✅
- [x] Circular layout implementation
- [x] Clock widget
- [x] Weather widget (placeholder)
- [x] Assistant indicator
- [x] Volume control
- [x] Basic touch interactions

### Phase 2: Voice Assistant
- [ ] Wake word detection
- [ ] Speech-to-text integration
- [ ] Text-to-speech output
- [ ] Local AI assistant connection

### Phase 3: Media Integration
- [ ] Spotify API integration
- [ ] Local audio playback
- [ ] Bluetooth speaker support

### Phase 4: Smart Home
- [ ] MQTT device control
- [ ] Smart home automation
- [ ] Voice-controlled scenes

### Phase 5: Advanced Features
- [ ] Face recognition
- [ ] Gesture control
- [ ] Advanced AI features

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by Apple's HomePod design
- Built with Flutter for cross-platform compatibility
- Optimized for Raspberry Pi hardware
- Uses various open-source packages and libraries

## Support

For support and questions:
- Create an issue in the GitHub repository
- Check the documentation in the `/docs` folder
- Review the development checklist in `HomePod_Assistant_Checklist.md`
