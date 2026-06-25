import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class SmartHomeWidget extends StatefulWidget {
  final double size;
  final Color? accentColor;
  
  const SmartHomeWidget({
    super.key,
    this.size = 200,
    this.accentColor,
  });

  @override
  State<SmartHomeWidget> createState() => _SmartHomeWidgetState();
}

class _SmartHomeWidgetState extends State<SmartHomeWidget>
    with TickerProviderStateMixin {
  MqttServerClient? _client;
  bool _isConnected = false;
  Map<String, SmartDevice> _devices = {};
  bool _isLoading = true;
  String _error = '';
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _initializeMQTT();
    _loadSampleDevices(); // For demo purposes
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    // _disconnectMQTT(); // Removed for demo mode
    super.dispose();
  }

  Future<void> _initializeMQTT() async {
    try {
      // Mock MQTT connection for testing
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _isConnected = true;
        _isLoading = false;
      });
      
      // Start glow animation
      _glowController.repeat(reverse: true);
      
    } catch (e) {
      print('Failed to connect to MQTT: $e');
      setState(() {
        _error = 'MQTT Connection Failed';
        _isLoading = false;
      });
    }
  }

  void _onConnected() {
    setState(() {
      _isConnected = true;
      _isLoading = false;
    });
    
    // Subscribe to device topics
    _subscribeToDevices();
    
    // Start glow animation
    _glowController.repeat(reverse: true);
  }

  void _onDisconnected() {
    setState(() {
      _isConnected = false;
    });
    _glowController.stop();
  }

  void _onSubscribed(String topic) {
    print('Subscribed to: $topic');
  }

  void _subscribeToDevices() {
    if (!_isConnected) return;
    
    // Mock device subscription for testing
    print('Subscribed to device topics (demo mode)');
  }

  void _handleMQTTMessage(String topic, String payload) {
    // Parse topic to get device info
    final parts = topic.split('/');
    if (parts.length >= 3) {
      final deviceType = parts[1]; // lights, plugs, thermostat
      final deviceId = parts[2]; // specific device ID
      final status = parts[3] ?? 'status'; // status or command
      
      setState(() {
        if (_devices.containsKey('$deviceType/$deviceId')) {
          final device = _devices['$deviceType/$deviceId']!;
          
          if (status == 'status') {
            // Update device status
            if (payload == 'on' || payload == 'true') {
              device.isOn = true;
            } else if (payload == 'off' || payload == 'false') {
              device.isOn = false;
            } else {
              // Try to parse as JSON or other format
              device.value = payload;
            }
          }
        }
      });
    }
  }

  Future<void> _toggleDevice(String deviceId) async {
    if (!_isConnected) return;
    
    final device = _devices[deviceId];
    if (device == null) return;
    
    final newState = !device.isOn;
    
    try {
      // Mock MQTT command for testing
      print('Mock MQTT command: $deviceId -> $newState');
      
      // Optimistically update UI
      setState(() {
        device.isOn = newState;
      });
      
      // Start pulse animation
      _pulseController.forward(from: 0.0);
    } catch (e) {
      print('Failed to send MQTT command: $e');
    }
  }

  void _loadSampleDevices() {
    // Add sample devices for demonstration
    _devices = {
      'lights/living_room': SmartDevice(
        id: 'living_room',
        name: 'Living Room',
        type: 'lights',
        icon: Icons.lightbulb,
        isOn: false,
      ),
      'lights/kitchen': SmartDevice(
        id: 'kitchen',
        name: 'Kitchen',
        type: 'lights',
        icon: Icons.lightbulb_outline,
        isOn: true,
      ),
      'plugs/tv': SmartDevice(
        id: 'tv',
        name: 'TV Plug',
        type: 'plugs',
        icon: Icons.tv,
        isOn: true,
      ),
      'thermostat/main': SmartDevice(
        id: 'main',
        name: 'Thermostat',
        type: 'thermostat',
        icon: Icons.thermostat,
        isOn: true,
        value: '72°F',
      ),
    };
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_error.isNotEmpty) {
      return _buildErrorWidget();
    }

    return _buildSmartHomeDisplay();
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: (widget.accentColor ?? Colors.purple).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: widget.accentColor ?? Colors.purple,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red.withOpacity(0.1),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
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
              size: widget.size * 0.2,
            ),
            const SizedBox(height: 8),
            Text(
              'Connection Error',
              style: TextStyle(
                color: Colors.red,
                fontSize: widget.size * 0.08,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to retry',
              style: TextStyle(
                color: Colors.red.withOpacity(0.7),
                fontSize: widget.size * 0.06,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartHomeDisplay() {
    final accentColor = widget.accentColor ?? Colors.purple;
    final deviceList = _devices.values.toList();
    
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            accentColor.withOpacity(0.2),
            accentColor.withOpacity(0.1),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        border: Border.all(
          color: accentColor.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Connection status indicator
          Positioned(
            top: widget.size * 0.05,
            right: widget.size * 0.05,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: widget.size * 0.08,
                  height: widget.size * 0.08,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isConnected 
                        ? Colors.green.withOpacity(_glowAnimation.value)
                        : Colors.red.withOpacity(0.3),
                    border: Border.all(
                      color: _isConnected ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _isConnected ? Icons.wifi : Icons.wifi_off,
                    color: Colors.white,
                    size: widget.size * 0.04,
                  ),
                );
              },
            ),
          ),
          
          // Device grid (2x2 for 4 devices)
          if (deviceList.length <= 4) ...[
            // Top left device
            if (deviceList.isNotEmpty)
              Positioned(
                top: widget.size * 0.15,
                left: widget.size * 0.15,
                child: _buildDeviceButton(deviceList[0], accentColor),
              ),
            
            // Top right device
            if (deviceList.length > 1)
              Positioned(
                top: widget.size * 0.15,
                right: widget.size * 0.15,
                child: _buildDeviceButton(deviceList[1], accentColor),
              ),
            
            // Bottom left device
            if (deviceList.length > 2)
              Positioned(
                bottom: widget.size * 0.15,
                left: widget.size * 0.15,
                child: _buildDeviceButton(deviceList[2], accentColor),
              ),
            
            // Bottom right device
            if (deviceList.length > 3)
              Positioned(
                bottom: widget.size * 0.15,
                right: widget.size * 0.15,
                child: _buildDeviceButton(deviceList[3], accentColor),
              ),
          ],
          
          // Center title
          Positioned(
            top: widget.size * 0.4,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Smart Home',
                style: TextStyle(
                  fontSize: widget.size * 0.08,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          // Device count indicator
          Positioned(
            bottom: widget.size * 0.1,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${_devices.length} devices',
                style: TextStyle(
                  fontSize: widget.size * 0.06,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceButton(SmartDevice device, Color accentColor) {
    final buttonSize = widget.size * 0.25;
    
    return GestureDetector(
      onTap: () => _toggleDevice('${device.type}/${device.id}'),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: device.isOn ? _pulseAnimation.value : 1.0,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: device.isOn 
                    ? accentColor.withOpacity(0.8)
                    : Colors.grey.withOpacity(0.3),
                border: Border.all(
                  color: device.isOn 
                      ? accentColor
                      : Colors.grey.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: device.isOn ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    device.icon,
                    color: device.isOn ? Colors.white : Colors.grey,
                    size: buttonSize * 0.4,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    device.name,
                    style: TextStyle(
                      fontSize: buttonSize * 0.25,
                      color: device.isOn ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (device.value != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      device.value!,
                      style: TextStyle(
                        fontSize: buttonSize * 0.2,
                        color: device.isOn ? Colors.white70 : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SmartDevice {
  final String id;
  final String name;
  final String type;
  final IconData icon;
  bool isOn;
  String? value;

  SmartDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    this.isOn = false,
    this.value,
  });
} 