import 'package:flutter/material.dart';

class VolumeApp extends StatefulWidget {
  const VolumeApp({super.key});

  @override
  State<VolumeApp> createState() => _VolumeAppState();
}

class _VolumeAppState extends State<VolumeApp> {
  double _masterVolume = 0.7;
  double _musicVolume = 0.8;
  double _voiceVolume = 0.9;
  double _systemVolume = 0.6;
  bool _muted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.volume_up, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text(
                  'Volume Control',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Master Volume
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      _muted ? Icons.volume_off : Icons.volume_up,
                      color: _muted ? Colors.red : Colors.green,
                      size: 32,
                    ),
                    const Text(
                      'Master Volume',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _muted = !_muted;
                        });
                      },
                      icon: Icon(
                        _muted ? Icons.volume_up : Icons.volume_off,
                        color: _muted ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Slider(
                  value: _muted ? 0.0 : _masterVolume,
                  onChanged: (value) {
                    setState(() {
                      _masterVolume = value;
                      _muted = false;
                    });
                  },
                  activeColor: Colors.green,
                  inactiveColor: Colors.grey.withOpacity(0.3),
                  min: 0.0,
                  max: 1.0,
                ),
                Text(
                  '${(_masterVolume * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Individual Volume Controls
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildVolumeControl(
                  icon: Icons.music_note,
                  title: 'Music',
                  volume: _musicVolume,
                  color: Colors.purple,
                  onChanged: (value) {
                    setState(() {
                      _musicVolume = value;
                    });
                  },
                ),
                
                const Divider(color: Colors.white24),
                
                _buildVolumeControl(
                  icon: Icons.mic,
                  title: 'Voice',
                  volume: _voiceVolume,
                  color: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      _voiceVolume = value;
                    });
                  },
                ),
                
                const Divider(color: Colors.white24),
                
                _buildVolumeControl(
                  icon: Icons.notifications,
                  title: 'System',
                  volume: _systemVolume,
                  color: Colors.orange,
                  onChanged: (value) {
                    setState(() {
                      _systemVolume = value;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Quick Actions
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _masterVolume = 0.0;
                      _musicVolume = 0.0;
                      _voiceVolume = 0.0;
                      _systemVolume = 0.0;
                      _muted = true;
                    });
                  },
                  icon: const Icon(Icons.volume_off, color: Colors.white),
                  label: const Text('Mute All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _masterVolume = 0.5;
                      _musicVolume = 0.5;
                      _voiceVolume = 0.5;
                      _systemVolume = 0.5;
                      _muted = false;
                    });
                  },
                  icon: const Icon(Icons.volume_down, color: Colors.white),
                  label: const Text('50%'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeControl({
    required IconData icon,
    required String title,
    required double volume,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${(volume * 100).round()}%',
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: SizedBox(
        width: 100,
        child: Slider(
          value: volume,
          onChanged: onChanged,
          activeColor: color,
          inactiveColor: color.withOpacity(0.3),
          min: 0.0,
          max: 1.0,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
} 