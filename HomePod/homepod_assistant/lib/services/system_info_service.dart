import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SystemInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static bool _isInitialized = false;

  /// Initialize the system info service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _isInitialized = true;
    } catch (e) {
      print('Error initializing system info service: $e');
    }
  }

  /// Get device model information
  static Future<String> getDeviceModel() async {
    try {
      await initialize();
      
      if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return '${linuxInfo.name} ${linuxInfo.version}';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return '${windowsInfo.productName} ${windowsInfo.buildNumber}';
      } else if (Platform.isMacOS) {
        final macOsInfo = await _deviceInfo.macOsInfo;
        return '${macOsInfo.computerName} ${macOsInfo.osRelease}';
      } else {
        return 'Unknown Device';
      }
    } catch (e) {
      print('Error getting device model: $e');
      return 'Unknown Device';
    }
  }

  /// Get operating system version
  static Future<String> getOSVersion() async {
    try {
      await initialize();
      
      if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return '${linuxInfo.name} ${linuxInfo.version}';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return 'Windows ${windowsInfo.majorVersion}.${windowsInfo.minorVersion}';
      } else if (Platform.isMacOS) {
        final macOsInfo = await _deviceInfo.macOsInfo;
        return 'macOS ${macOsInfo.osRelease}';
      } else {
        return 'Unknown OS';
      }
    } catch (e) {
      print('Error getting OS version: $e');
      return 'Unknown OS';
    }
  }

  /// Get app version information
  static Future<AppVersionInfo> getAppVersion() async {
    try {
      await initialize();
      final packageInfo = await PackageInfo.fromPlatform();
      
      return AppVersionInfo(
        appName: packageInfo.appName,
        packageName: packageInfo.packageName,
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
      );
    } catch (e) {
      print('Error getting app version: $e');
      return AppVersionInfo(
        appName: 'HomePod Assistant',
        packageName: 'com.example.homepod_assistant',
        version: '1.0.0',
        buildNumber: '1',
      );
    }
  }

  /// Get system statistics
  static Future<SystemStats> getSystemStats() async {
    try {
      await initialize();
      
      // For now, return mock system stats
      // In a real implementation, this would read actual system metrics
      return SystemStats(
        memoryUsage: 45.2, // Percentage
        cpuUsage: 12.8, // Percentage
        diskUsage: 67.3, // Percentage
        uptime: const Duration(hours: 24, minutes: 32, seconds: 15),
        temperature: 42.5, // Celsius
      );
    } catch (e) {
      print('Error getting system stats: $e');
      return SystemStats(
        memoryUsage: 0.0,
        cpuUsage: 0.0,
        diskUsage: 0.0,
        uptime: Duration.zero,
        temperature: 0.0,
      );
    }
  }

  /// Get system architecture
  static Future<String> getArchitecture() async {
    try {
      await initialize();
      
      if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return linuxInfo.machineId ?? 'Unknown';
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return windowsInfo.productName ?? 'Unknown';
      } else if (Platform.isMacOS) {
        final macOsInfo = await _deviceInfo.macOsInfo;
        return macOsInfo.arch ?? 'Unknown';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print('Error getting architecture: $e');
      return 'Unknown';
    }
  }

  /// Get system uptime
  static Future<Duration> getUptime() async {
    try {
      await initialize();
      
      // For now, return a mock uptime
      // In a real implementation, this would read from /proc/uptime on Linux
      return const Duration(hours: 24, minutes: 32, seconds: 15);
    } catch (e) {
      print('Error getting uptime: $e');
      return Duration.zero;
    }
  }

  /// Get system memory information
  static Future<MemoryInfo> getMemoryInfo() async {
    try {
      await initialize();
      
      // For now, return mock memory info
      // In a real implementation, this would read from /proc/meminfo on Linux
      return MemoryInfo(
        total: 8192, // MB
        used: 3698, // MB
        free: 4494, // MB
        available: 4494, // MB
      );
    } catch (e) {
      print('Error getting memory info: $e');
      return MemoryInfo(
        total: 0,
        used: 0,
        free: 0,
        available: 0,
      );
    }
  }

  /// Get disk usage information
  static Future<DiskInfo> getDiskInfo() async {
    try {
      await initialize();
      
      // For now, return mock disk info
      // In a real implementation, this would read actual disk usage
      return DiskInfo(
        total: 128000, // MB
        used: 86144, // MB
        free: 41856, // MB
        mountPoint: '/',
      );
    } catch (e) {
      print('Error getting disk info: $e');
      return DiskInfo(
        total: 0,
        used: 0,
        free: 0,
        mountPoint: '/',
      );
    }
  }
}

class AppVersionInfo {
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;

  AppVersionInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
  });

  @override
  String toString() {
    return '$appName v$version ($buildNumber)';
  }
}

class SystemStats {
  final double memoryUsage; // Percentage
  final double cpuUsage; // Percentage
  final double diskUsage; // Percentage
  final Duration uptime;
  final double temperature; // Celsius

  SystemStats({
    required this.memoryUsage,
    required this.cpuUsage,
    required this.diskUsage,
    required this.uptime,
    required this.temperature,
  });

  @override
  String toString() {
    return 'SystemStats(memory: ${memoryUsage.toStringAsFixed(1)}%, cpu: ${cpuUsage.toStringAsFixed(1)}%, disk: ${diskUsage.toStringAsFixed(1)}%, uptime: $uptime, temp: ${temperature.toStringAsFixed(1)}°C)';
  }
}

class MemoryInfo {
  final int total; // MB
  final int used; // MB
  final int free; // MB
  final int available; // MB

  MemoryInfo({
    required this.total,
    required this.used,
    required this.free,
    required this.available,
  });

  double get usagePercentage => total > 0 ? (used / total) * 100 : 0.0;

  @override
  String toString() {
    return 'MemoryInfo(total: ${total}MB, used: ${used}MB, free: ${free}MB, usage: ${usagePercentage.toStringAsFixed(1)}%)';
  }
}

class DiskInfo {
  final int total; // MB
  final int used; // MB
  final int free; // MB
  final String mountPoint;

  DiskInfo({
    required this.total,
    required this.used,
    required this.free,
    required this.mountPoint,
  });

  double get usagePercentage => total > 0 ? (used / total) * 100 : 0.0;

  @override
  String toString() {
    return 'DiskInfo(total: ${total}MB, used: ${used}MB, free: ${free}MB, usage: ${usagePercentage.toStringAsFixed(1)}%, mount: $mountPoint)';
  }
} 