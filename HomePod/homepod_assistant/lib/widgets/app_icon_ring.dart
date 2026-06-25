import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:homepod_assistant/providers/assistant_state.dart';
import 'package:homepod_assistant/apps/music_app.dart';
import 'package:homepod_assistant/apps/smart_home_app.dart';
import 'package:homepod_assistant/apps/volume_app.dart';
import 'package:homepod_assistant/apps/settings_app.dart';
import 'package:homepod_assistant/apps/weather_app.dart';
import 'package:homepod_assistant/apps/news_app.dart';
import 'package:homepod_assistant/apps/calendar_app.dart';
import 'dart:math';

class AppIconRing extends StatefulWidget {
  const AppIconRing({super.key});

  @override
  State<AppIconRing> createState() => _AppIconRingState();
}

class _AppIconRingState extends State<AppIconRing> {
  double _rotationAngle = 0.0;
  double _startAngle = 0.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AssistantState>(
      builder: (context, assistantState, child) {
        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: SizedBox(
            width: 400,
            height: 400,
            child: Stack(
              children: [
                // App icons arranged in a circle
                ...List.generate(8, (index) {
                  final angle = (index * 45 + _rotationAngle) * (pi / 180); // Convert to radians
                  const radius = 150.0;
                  final x = radius * cos(angle);
                  final y = radius * sin(angle);
                  
                  return Positioned(
                    left: 200 + x - 35, // Center at 200, icon size 70
                    top: 200 + y - 35,
                    child: _buildAppIcon(index, assistantState),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onPanStart(DragStartDetails details) {
    const center = Offset(200, 200);
    final touchPoint = details.localPosition;
    _startAngle = _getAngleFromCenter(touchPoint, center);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    const center = Offset(200, 200);
    final touchPoint = details.localPosition;
    final currentAngle = _getAngleFromCenter(touchPoint, center);
    final angleDifference = currentAngle - _startAngle;
    
    setState(() {
      _rotationAngle += angleDifference;
      _startAngle = currentAngle;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // Drag ended - could add momentum or snap-to-grid here
  }

  double _getAngleFromCenter(Offset point, Offset center) {
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    return atan2(dy, dx) * 180 / pi;
  }

  Widget _buildAppIcon(int index, AssistantState assistantState) {
    final appData = _getAppData(index);
    
    return GestureDetector(
      onTap: () => _handleAppTap(index, assistantState),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: appData.color.withOpacity(0.15),
          border: Border.all(
            color: appData.color.withOpacity(0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: appData.color.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          appData.icon,
          color: appData.color,
          size: 32,
        ),
      ),
    );
  }

  AppData _getAppData(int index) {
    switch (index) {
      case 0: // Top - Music/Spotify
        return AppData(Icons.music_note, Colors.purple, 'Music');
      case 1: // Top Right - Smart Home
        return AppData(Icons.home, Colors.blue, 'Smart Home');
      case 2: // Right - Volume Control
        return AppData(Icons.volume_up, Colors.green, 'Volume');
      case 3: // Bottom Right - Settings
        return AppData(Icons.settings, Colors.grey, 'Settings');
      case 4: // Bottom - Voice Assistant
        return AppData(Icons.mic, Colors.red, 'Voice');
      case 5: // Bottom Left - Weather
        return AppData(Icons.wb_sunny, Colors.orange, 'Weather');
      case 6: // Left - News/Notifications
        return AppData(Icons.notifications, Colors.yellow, 'News');
      case 7: // Top Left - Calendar
        return AppData(Icons.calendar_today, Colors.pink, 'Calendar');
      default:
        return AppData(Icons.apps, Colors.white, 'App');
    }
  }

  void _handleAppTap(int index, AssistantState assistantState) {
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    switch (index) {
      case 0: // Music/Spotify
        _showApp(const MusicApp(), 'Music Player');
        break;
      case 1: // Smart Home
        _showApp(const SmartHomeApp(), 'Smart Home');
        break;
      case 2: // Volume
        _showApp(const VolumeApp(), 'Volume Control');
        break;
      case 3: // Settings
        _showApp(const SettingsApp(), 'Settings');
        break;
      case 4: // Voice - Show voice assistant status
        _showVoiceStatus(assistantState);
        break;
      case 5: // Weather
        _showApp(const WeatherApp(), 'Weather');
        break;
      case 6: // News/Notifications
        _showApp(const NewsApp(), 'News');
        break;
      case 7: // Calendar
        _showApp(const CalendarApp(), 'Calendar');
        break;
    }
  }

  void _showApp(Widget app, String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: app,
      ),
    );
  }

  void _showVoiceStatus(AssistantState assistantState) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 300,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.mic, color: Colors.red, size: 32),
                    SizedBox(width: 12),
                    Text(
                      'Voice Assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Status Indicator
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.withOpacity(0.5)),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              assistantState.isListening ? Icons.mic : Icons.mic_none,
                              color: assistantState.isListening ? Colors.red : Colors.grey,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              assistantState.isListening ? 'Listening' : 'Idle',
                              style: TextStyle(
                                color: assistantState.isListening ? Colors.red : Colors.grey,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              assistantState.isListening ? 'Speak now...' : 'Tap to activate',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Volume Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.volume_up, color: Colors.red, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Voice Volume',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${(assistantState.currentVolume * 100).round()}%',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Control Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (assistantState.status == AssistantStatus.idle) {
                                await assistantState.startListening();
                              } else {
                                await assistantState.stopListening();
                              }
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              assistantState.isListening ? Icons.stop : Icons.mic,
                              color: Colors.white,
                            ),
                            label: Text(
                              assistantState.isListening ? 'Stop' : 'Start',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.white),
                            label: const Text('Close'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppData {
  final IconData icon;
  final Color color;
  final String name;

  AppData(this.icon, this.color, this.name);
} 