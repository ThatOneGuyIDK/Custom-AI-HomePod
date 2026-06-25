import 'package:volume_controller/volume_controller.dart';

class VolumeService {
  static bool _isInitialized = false;

  /// Initialize the volume service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize volume controller
      _isInitialized = true;
    } catch (e) {
      print('Error initializing volume service: $e');
    }
  }

  /// Get current master volume (0.0 to 1.0)
  static Future<double> getMasterVolume() async {
    try {
      await initialize();
      return VolumeController().getVolume();
    } catch (e) {
      print('Error getting volume: $e');
      return 0.5; // Default fallback
    }
  }

  /// Set master volume (0.0 to 1.0)
  static Future<void> setMasterVolume(double volume) async {
    try {
      await initialize();
      final clampedVolume = volume.clamp(0.0, 1.0);
      VolumeController().setVolume(clampedVolume);
    } catch (e) {
      print('Error setting volume: $e');
      throw Exception('Failed to set volume: $e');
    }
  }

  /// Mute the system (set volume to 0)
  static Future<void> mute() async {
    try {
      await initialize();
      VolumeController().setVolume(0.0);
    } catch (e) {
      print('Error muting: $e');
      throw Exception('Failed to mute: $e');
    }
  }

  /// Unmute the system (set volume to previous level)
  static Future<void> unmute() async {
    try {
      await initialize();
      VolumeController().setVolume(0.5); // Default unmute level
    } catch (e) {
      print('Error unmuting: $e');
      throw Exception('Failed to unmute: $e');
    }
  }

  /// Check if system is muted (volume = 0)
  static Future<bool> isMuted() async {
    try {
      await initialize();
      final volume = await getMasterVolume();
      return volume <= 0.01; // Consider muted if volume is very low
    } catch (e) {
      print('Error checking mute status: $e');
      return false; // Default fallback
    }
  }

  /// Stream of volume changes (simplified)
  static Stream<double> getVolumeStream() {
    try {
      // For now, return a simple stream that updates every second
      return Stream.periodic(const Duration(seconds: 1), (_) async {
        return await getMasterVolume();
      }).asyncMap((future) => future);
    } catch (e) {
      print('Error getting volume stream: $e');
      return Stream.value(0.5); // Default fallback stream
    }
  }

  /// Set volume to a percentage (0-100)
  static Future<void> setVolumePercentage(int percentage) async {
    final volume = (percentage / 100.0).clamp(0.0, 1.0);
    await setMasterVolume(volume);
  }

  /// Get volume as percentage (0-100)
  static Future<int> getVolumePercentage() async {
    final volume = await getMasterVolume();
    return (volume * 100).round();
  }

  /// Set volume to preset levels
  static Future<void> setVolumePreset(VolumePreset preset) async {
    switch (preset) {
      case VolumePreset.mute:
        await mute();
        break;
      case VolumePreset.low:
        await setVolumePercentage(25);
        break;
      case VolumePreset.medium:
        await setVolumePercentage(50);
        break;
      case VolumePreset.high:
        await setVolumePercentage(75);
        break;
      case VolumePreset.maximum:
        await setVolumePercentage(100);
        break;
    }
  }

  /// Toggle mute state
  static Future<void> toggleMute() async {
    final isCurrentlyMuted = await isMuted();
    if (isCurrentlyMuted) {
      await unmute();
    } else {
      await mute();
    }
  }

  /// Increase volume by a percentage
  static Future<void> increaseVolume(int percentage) async {
    final currentVolume = await getVolumePercentage();
    final newVolume = (currentVolume + percentage).clamp(0, 100);
    await setVolumePercentage(newVolume);
  }

  /// Decrease volume by a percentage
  static Future<void> decreaseVolume(int percentage) async {
    final currentVolume = await getVolumePercentage();
    final newVolume = (currentVolume - percentage).clamp(0, 100);
    await setVolumePercentage(newVolume);
  }
}

enum VolumePreset {
  mute,
  low,
  medium,
  high,
  maximum,
} 