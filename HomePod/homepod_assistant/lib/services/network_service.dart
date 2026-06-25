import 'package:network_info_plus/network_info_plus.dart';

class NetworkService {
  static final NetworkInfo _networkInfo = NetworkInfo();
  static bool _isInitialized = false;

  /// Initialize the network service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _isInitialized = true;
    } catch (e) {
      print('Error initializing network service: $e');
    }
  }

  /// Get current WiFi network name
  static Future<String> getWifiName() async {
    try {
      await initialize();
      final wifiName = await _networkInfo.getWifiName();
      return wifiName ?? 'Unknown';
    } catch (e) {
      print('Error getting WiFi name: $e');
      return 'Unknown';
    }
  }

  /// Get WiFi IP address
  static Future<String> getWifiIP() async {
    try {
      await initialize();
      final wifiIP = await _networkInfo.getWifiIP();
      return wifiIP ?? 'Unknown';
    } catch (e) {
      print('Error getting WiFi IP: $e');
      return 'Unknown';
    }
  }

  /// Check if WiFi is connected
  static Future<bool> isWifiConnected() async {
    try {
      await initialize();
      final wifiName = await getWifiName();
      return wifiName != 'Unknown' && wifiName.isNotEmpty;
    } catch (e) {
      print('Error checking WiFi connection: $e');
      return false;
    }
  }

  /// Get network status with all information
  static Future<NetworkStatus> getNetworkStatus() async {
    try {
      await initialize();
      return NetworkStatus(
        isConnected: await isWifiConnected(),
        networkName: await getWifiName(),
        ipAddress: await getWifiIP(),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Error getting network status: $e');
      return NetworkStatus(
        isConnected: false,
        networkName: 'Unknown',
        ipAddress: 'Unknown',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Stream of network status changes
  static Stream<NetworkStatus> getNetworkStatusStream() async* {
    while (true) {
      yield await getNetworkStatus();
      await Future.delayed(const Duration(seconds: 5)); // Update every 5 seconds
    }
  }

  /// Get network signal strength (mock for now)
  static Future<int> getSignalStrength() async {
    try {
      await initialize();
      // For now, return a mock signal strength
      // In a real implementation, this would use platform-specific APIs
      return 85; // Mock 85% signal strength
    } catch (e) {
      print('Error getting signal strength: $e');
      return 0;
    }
  }

  /// Get network type
  static Future<String> getNetworkType() async {
    try {
      await initialize();
      final isConnected = await isWifiConnected();
      return isConnected ? 'WiFi' : 'Disconnected';
    } catch (e) {
      print('Error getting network type: $e');
      return 'Unknown';
    }
  }

  /// Get network speed (mock for now)
  static Future<String> getNetworkSpeed() async {
    try {
      await initialize();
      // For now, return a mock network speed
      // In a real implementation, this would measure actual network performance
      return '100 Mbps'; // Mock speed
    } catch (e) {
      print('Error getting network speed: $e');
      return 'Unknown';
    }
  }

  /// Test network connectivity
  static Future<bool> testConnectivity() async {
    try {
      await initialize();
      final isConnected = await isWifiConnected();
      if (!isConnected) return false;
      
      // Additional connectivity test could be added here
      // For now, just check if we have a valid IP
      final ip = await getWifiIP();
      return ip != 'Unknown' && ip.isNotEmpty;
    } catch (e) {
      print('Error testing connectivity: $e');
      return false;
    }
  }
}

class NetworkStatus {
  final bool isConnected;
  final String networkName;
  final String ipAddress;
  final DateTime timestamp;

  NetworkStatus({
    required this.isConnected,
    required this.networkName,
    required this.ipAddress,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'NetworkStatus(isConnected: $isConnected, networkName: $networkName, ipAddress: $ipAddress)';
  }

  NetworkStatus copyWith({
    bool? isConnected,
    String? networkName,
    String? ipAddress,
    DateTime? timestamp,
  }) {
    return NetworkStatus(
      isConnected: isConnected ?? this.isConnected,
      networkName: networkName ?? this.networkName,
      ipAddress: ipAddress ?? this.ipAddress,
      timestamp: timestamp ?? this.timestamp,
    );
  }
} 