import 'package:screen_brightness/screen_brightness.dart';

class BrightnessService {
  static bool _isInitialized = false;

  /// Initialize the brightness service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize the brightness service
      _isInitialized = true;
    } catch (e) {
      print('Error initializing brightness service: $e');
    }
  }

  /// Get current screen brightness (0.0 to 1.0)
  static Future<double> getBrightness() async {
    try {
      await initialize();
      final brightness = await ScreenBrightness().current;
      return brightness.clamp(0.0, 1.0);
    } catch (e) {
      print('Error getting brightness: $e');
      return 0.5; // Default fallback
    }
  }

  /// Set screen brightness (0.0 to 1.0)
  static Future<void> setBrightness(double brightness) async {
    try {
      await initialize();
      final clampedBrightness = brightness.clamp(0.0, 1.0);
      await ScreenBrightness().setScreenBrightness(clampedBrightness);
    } catch (e) {
      print('Error setting brightness: $e');
      throw Exception('Failed to set brightness: $e');
    }
  }

  /// Get maximum brightness value
  static Future<double> getMaxBrightness() async {
    try {
      await initialize();
      // For now, return 1.0 as max brightness
      return 1.0;
    } catch (e) {
      print('Error getting max brightness: $e');
      return 1.0; // Default fallback
    }
  }

  /// Get minimum brightness value
  static Future<double> getMinBrightness() async {
    try {
      await initialize();
      // For now, return 0.0 as min brightness
      return 0.0;
    } catch (e) {
      print('Error getting min brightness: $e');
      return 0.0; // Default fallback
    }
  }

  /// Stream of brightness changes
  static Stream<double> getBrightnessStream() {
    try {
      return ScreenBrightness().onCurrentBrightnessChanged;
    } catch (e) {
      print('Error getting brightness stream: $e');
      return Stream.value(0.5); // Default fallback stream
    }
  }

  /// Set brightness to a percentage (0-100)
  static Future<void> setBrightnessPercentage(int percentage) async {
    final brightness = (percentage / 100.0).clamp(0.0, 1.0);
    await setBrightness(brightness);
  }

  /// Get brightness as percentage (0-100)
  static Future<int> getBrightnessPercentage() async {
    final brightness = await getBrightness();
    return (brightness * 100).round();
  }

  /// Set brightness to preset levels
  static Future<void> setBrightnessPreset(BrightnessPreset preset) async {
    switch (preset) {
      case BrightnessPreset.dim:
        await setBrightnessPercentage(25);
        break;
      case BrightnessPreset.normal:
        await setBrightnessPercentage(50);
        break;
      case BrightnessPreset.bright:
        await setBrightnessPercentage(75);
        break;
      case BrightnessPreset.maximum:
        await setBrightnessPercentage(100);
        break;
    }
  }
}

enum BrightnessPreset {
  dim,
  normal,
  bright,
  maximum,
} 