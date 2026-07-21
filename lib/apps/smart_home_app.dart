import 'package:flutter/material.dart';

class SmartHomeApp extends StatefulWidget {
  const SmartHomeApp({super.key});

  @override
  State<SmartHomeApp> createState() => _SmartHomeAppState();
}

class _SmartHomeAppState extends State<SmartHomeApp> {
  bool _isConnected = false;
  List<SmartDevice> _devices = [];
  List<Automation> _automations = [];
  int _currentTabIndex = 0;
  bool _isDiscovering = false;

  @override
  void initState() {
    super.initState();
    _initializeSmartHome();
  }

  void _initializeSmartHome() {
    _devices = [
      SmartDevice('Living Room Light', Icons.lightbulb, true, Colors.yellow, DeviceType.light, 'Philips Hue'),
      SmartDevice('Kitchen Light', Icons.lightbulb, false, Colors.orange, DeviceType.light, 'Philips Hue'),
      SmartDevice('Bedroom Light', Icons.lightbulb, true, Colors.blue, DeviceType.light, 'Philips Hue'),
      SmartDevice('Front Door Lock', Icons.lock, false, Colors.green, DeviceType.security, 'August'),
      SmartDevice('Thermostat', Icons.thermostat, true, Colors.red, DeviceType.climate, 'Nest'),
      SmartDevice('Security Camera', Icons.videocam, true, Colors.purple, DeviceType.security, 'Ring'),
      SmartDevice('Garage Door', Icons.garage, false, Colors.grey, DeviceType.security, 'Chamberlain'),
      SmartDevice('Sprinkler System', Icons.water_drop, false, Colors.cyan, DeviceType.outdoor, 'Rachio'),
    ];

    _automations = [
      Automation('Good Morning', '7:00 AM', 'Turn on lights, adjust thermostat', true, Colors.orange),
      Automation('Good Night', '10:00 PM', 'Turn off lights, lock doors', true, Colors.blue),
      Automation('Away Mode', 'Manual', 'Secure home, enable cameras', false, Colors.red),
      Automation('Movie Time', 'Manual', 'Dim lights, close blinds', false, Colors.purple),
    ];

    // Simulate connection
    _simulateConnection();
  }

  void _simulateConnection() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
      }
    });
  }

  void _toggleDevice(SmartDevice device) {
    setState(() {
      device.isOn = !device.isOn;
      device.lastUpdated = DateTime.now();
    });
  }

  void _toggleAutomation(Automation automation) {
    setState(() {
      automation.isActive = !automation.isActive;
    });
  }

  void _startDeviceDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    // Simulate device discovery
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isDiscovering = false;
          // Add a new discovered device
          _devices.add(SmartDevice(
            'New Smart Plug',
            Icons.power,
            false,
            Colors.green,
            DeviceType.outlet,
            'TP-Link',
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.home, color: Colors.blue, size: 32),
                SizedBox(width: 12),
                Text(
                  'Smart Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Connection Status
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isConnected ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.wifi : Icons.wifi_off,
                      color: _isConnected ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isConnected ? 'Connected' : 'Connecting...',
                      style: TextStyle(
                        color: _isConnected ? Colors.green : Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (_isConnected)
                  Text(
                    '${_devices.length} devices',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _buildTabButton('Devices', 0),
                const SizedBox(width: 8),
                _buildTabButton('Automation', 1),
                const SizedBox(width: 8),
                _buildTabButton('Discover', 2),
              ],
            ),
          ),
          
          // Content based on selected tab
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
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
            color: isSelected ? Colors.blue : Colors.transparent,
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

  Widget _buildTabContent() {
    switch (_currentTabIndex) {
      case 0:
        return _buildDevicesTab();
      case 1:
        return _buildAutomationTab();
      case 2:
        return _buildDiscoverTab();
      default:
        return _buildDevicesTab();
    }
  }

  Widget _buildDevicesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: device.isOn ? device.color : Colors.grey.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    device.icon,
                    color: device.isOn ? device.color : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: TextStyle(
                            color: device.isOn ? Colors.white : Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          device.brand,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (device.lastUpdated != null)
                          Text(
                            'Last updated: ${_formatTime(device.lastUpdated!)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Switch(
                    value: device.isOn,
                    onChanged: (value) => _toggleDevice(device),
                    activeColor: device.color,
                    activeTrackColor: device.color.withOpacity(0.3),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDeviceActionButton(
                    'Details',
                    Icons.info_outline,
                    () => _showDeviceDetails(device),
                  ),
                  if (device.type == DeviceType.light)
                    _buildDeviceActionButton(
                      'Brightness',
                      Icons.brightness_6,
                      () => _showBrightnessControl(device),
                    ),
                  if (device.type == DeviceType.climate)
                    _buildDeviceActionButton(
                      'Temperature',
                      Icons.thermostat,
                      () => _showTemperatureControl(device),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAutomationTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _automations.length,
      itemBuilder: (context, index) {
        final automation = _automations[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: automation.isActive ? automation.color : Colors.grey.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: automation.isActive ? automation.color : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          automation.name,
                          style: TextStyle(
                            color: automation.isActive ? Colors.white : Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          automation.time,
                          style: TextStyle(
                            color: automation.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          automation.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: automation.isActive,
                    onChanged: (value) => _toggleAutomation(automation),
                    activeColor: automation.color,
                    activeTrackColor: automation.color.withOpacity(0.3),
                  ),
                ],
              ),
              if (automation.isActive) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _runAutomation(automation),
                      icon: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                      label: const Text('Run Now', style: TextStyle(color: Colors.white, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: automation.color,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _editAutomation(automation),
                      icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                      label: const Text('Edit', style: TextStyle(color: Colors.white, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiscoverTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Discovery Status
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Icon(
                  _isDiscovering ? Icons.search : Icons.wifi_find,
                  color: _isDiscovering ? Colors.orange : Colors.blue,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _isDiscovering ? 'Discovering Devices...' : 'Device Discovery',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isDiscovering 
                      ? 'Searching for new smart devices on your network'
                      : 'Find and add new smart home devices',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Discovery Button
          ElevatedButton.icon(
            onPressed: _isDiscovering ? null : _startDeviceDiscovery,
            icon: Icon(_isDiscovering ? Icons.hourglass_empty : Icons.search, color: Colors.white),
            label: Text(_isDiscovering ? 'Discovering...' : 'Start Discovery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isDiscovering ? Colors.grey : Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Manual Add
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'Manual Setup',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add devices manually if they don\'t appear automatically',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _showManualAddDialog(),
                  icon: const Icon(Icons.add, color: Colors.white, size: 16),
                  label: const Text('Add Device', style: TextStyle(color: Colors.white, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceActionButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 16),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 32),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showDeviceDetails(SmartDevice device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.95),
        title: Text(
          device.name,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Brand: ${device.brand}', style: const TextStyle(color: Colors.white70)),
            Text('Type: ${device.type.name}', style: const TextStyle(color: Colors.white70)),
            Text('Status: ${device.isOn ? "ON" : "OFF"}', style: const TextStyle(color: Colors.white70)),
            if (device.lastUpdated != null)
              Text('Last Updated: ${_formatTime(device.lastUpdated!)}', style: const TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBrightnessControl(SmartDevice device) {
    double brightness = 0.5;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.95),
        title: const Text(
          'Brightness Control',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              device.name,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.brightness_low, color: Colors.white, size: 20),
                Expanded(
                  child: Slider(
                    value: brightness,
                    onChanged: (value) {
                      brightness = value;
                    },
                    activeColor: device.color,
                    inactiveColor: Colors.grey.withOpacity(0.3),
                  ),
                ),
                const Icon(Icons.brightness_high, color: Colors.white, size: 20),
              ],
            ),
            Text(
              '${(brightness * 100).toInt()}%',
              style: TextStyle(color: device.color, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Brightness set to ${(brightness * 100).toInt()}%'),
                  backgroundColor: device.color,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: device.color),
            child: const Text('Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTemperatureControl(SmartDevice device) {
    double temperature = 72.0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.95),
        title: const Text(
          'Temperature Control',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              device.name,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (temperature > 60) temperature -= 1;
                  },
                  icon: const Icon(Icons.remove_circle, color: Colors.white, size: 32),
                ),
                Text(
                  '${temperature.toInt()}°F',
                  style: TextStyle(color: device.color, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    if (temperature < 90) temperature += 1;
                  },
                  icon: const Icon(Icons.add_circle, color: Colors.white, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Slider(
              value: temperature,
              min: 60,
              max: 90,
              divisions: 30,
              onChanged: (value) {
                temperature = value;
              },
              activeColor: device.color,
              inactiveColor: Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Temperature set to ${temperature.toInt()}°F'),
                  backgroundColor: device.color,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: device.color),
            child: const Text('Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _runAutomation(Automation automation) {
    // Execute automation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Running ${automation.name}...'),
        backgroundColor: automation.color,
      ),
    );
  }

  void _editAutomation(Automation automation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.95),
        title: const Text(
          'Edit Automation',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${automation.name}', style: const TextStyle(color: Colors.white70)),
            Text('Time: ${automation.time}', style: const TextStyle(color: Colors.white70)),
            Text('Description: ${automation.description}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Active:', style: TextStyle(color: Colors.white70)),
                const SizedBox(width: 8),
                Switch(
                  value: automation.isActive,
                  onChanged: (value) {
                    automation.isActive = value;
                  },
                  activeColor: automation.color,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Automation ${automation.name} updated'),
                  backgroundColor: automation.color,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: automation.color),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showManualAddDialog() {
    String deviceName = '';
    String deviceBrand = '';
    DeviceType selectedType = DeviceType.light;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.95),
        title: const Text(
          'Add Device Manually',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => deviceName = value,
              decoration: const InputDecoration(
                labelText: 'Device Name',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => deviceBrand = value,
              decoration: const InputDecoration(
                labelText: 'Brand',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DeviceType>(
              value: selectedType,
              onChanged: (DeviceType? value) {
                if (value != null) selectedType = value;
              },
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Device Type',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
              ),
              items: DeviceType.values.map((DeviceType type) {
                return DropdownMenuItem<DeviceType>(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              if (deviceName.isNotEmpty && deviceBrand.isNotEmpty) {
                setState(() {
                  _devices.add(SmartDevice(
                    deviceName,
                    _getDeviceIcon(selectedType),
                    false,
                    _getDeviceColor(selectedType),
                    selectedType,
                    deviceBrand,
                  ));
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Device $deviceName added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Add Device', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(DeviceType type) {
    switch (type) {
      case DeviceType.light:
        return Icons.lightbulb;
      case DeviceType.security:
        return Icons.security;
      case DeviceType.climate:
        return Icons.thermostat;
      case DeviceType.outlet:
        return Icons.power;
      case DeviceType.outdoor:
        return Icons.outdoor_grill;
    }
  }

  Color _getDeviceColor(DeviceType type) {
    switch (type) {
      case DeviceType.light:
        return Colors.yellow;
      case DeviceType.security:
        return Colors.green;
      case DeviceType.climate:
        return Colors.red;
      case DeviceType.outlet:
        return Colors.blue;
      case DeviceType.outdoor:
        return Colors.cyan;
    }
  }
}

class SmartDevice {
  final String name;
  final IconData icon;
  bool isOn;
  final Color color;
  final DeviceType type;
  final String brand;
  DateTime? lastUpdated;

  SmartDevice(this.name, this.icon, this.isOn, this.color, this.type, this.brand);
}

class Automation {
  final String name;
  final String time;
  final String description;
  bool isActive;
  final Color color;

  Automation(this.name, this.time, this.description, this.isActive, this.color);
}

enum DeviceType {
  light,
  security,
  climate,
  outlet,
  outdoor,
} 