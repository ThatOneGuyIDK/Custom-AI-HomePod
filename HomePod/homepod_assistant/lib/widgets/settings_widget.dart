import 'package:flutter/material.dart';
import 'package:homepod_assistant/providers/assistant_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsWidget extends StatefulWidget {
  final double size;
  final Color? accentColor;

  const SettingsWidget({
    super.key,
    this.size = 200,
    this.accentColor,
  });

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isLoading = false;

  // Settings values
  String _weatherApiKey = '';
  String _spotifyClientId = '';
  String _spotifyRedirectUrl = '';
  String _mqttBroker = 'localhost';
  String _mqttUsername = '';
  String _mqttPassword = '';
  String _assistantPrompt =
      'You are HomePod Assistant, a practical AI helper for daily tasks. '
      'Be concise, friendly, and action-oriented. '
      'Prioritize clear steps, useful suggestions, and direct answers. '
      'If the user asks something ambiguous, ask one short clarification question. '
      'Avoid roleplay, long disclaimers, and unnecessary filler. '
      'For smart home tasks, propose safe, reversible actions first.';
  bool _autoLaunch = true;
  bool _darkMode = true;
  double _brightness = 0.8;
  double _volume = 0.7;

  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    ));

    _rotateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    _loadSettings();
  }

  @override
  void dispose() {
    _expandController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _weatherApiKey = prefs.getString('weather_api_key') ?? '';
        _spotifyClientId = prefs.getString('spotify_client_id') ?? '';
        _spotifyRedirectUrl = prefs.getString('spotify_redirect_url') ?? '';
        _mqttBroker = prefs.getString('mqtt_broker') ?? 'localhost';
        _mqttUsername = prefs.getString('mqtt_username') ?? '';
        _mqttPassword = prefs.getString('mqtt_password') ?? '';
        _assistantPrompt =
            prefs.getString('assistant_prompt') ?? _assistantPrompt;
        _autoLaunch = prefs.getBool('auto_launch') ?? true;
        _darkMode = prefs.getBool('dark_mode') ?? true;
        _brightness = prefs.getDouble('brightness') ?? 0.8;
        _volume = prefs.getDouble('volume') ?? 0.7;
      });

      if (mounted) {
        context.read<AssistantState>().setAssistantPrompt(_assistantPrompt);
      }
    } catch (e) {
      print('Failed to load settings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('weather_api_key', _weatherApiKey);
      await prefs.setString('spotify_client_id', _spotifyClientId);
      await prefs.setString('spotify_redirect_url', _spotifyRedirectUrl);
      await prefs.setString('mqtt_broker', _mqttBroker);
      await prefs.setString('mqtt_username', _mqttUsername);
      await prefs.setString('mqtt_password', _mqttPassword);
      await prefs.setString('assistant_prompt', _assistantPrompt);
      await prefs.setBool('auto_launch', _autoLaunch);
      await prefs.setBool('dark_mode', _darkMode);
      await prefs.setDouble('brightness', _brightness);
      await prefs.setDouble('volume', _volume);

      // Apply prompt immediately to running assistant
      if (mounted) {
        context.read<AssistantState>().setAssistantPrompt(_assistantPrompt);
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Failed to save settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _expandController.forward();
      _rotateController.repeat();
    } else {
      _expandController.reverse();
      _rotateController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    return _isExpanded ? _buildExpandedSettings() : _buildCollapsedSettings();
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: (widget.accentColor ?? Colors.teal).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: widget.accentColor ?? Colors.teal,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildCollapsedSettings() {
    final accentColor = widget.accentColor ?? Colors.teal;

    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
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
            // Settings icon
            Center(
              child: AnimatedBuilder(
                animation: _rotateAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateAnimation.value * 2 * 3.14159,
                    child: Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: widget.size * 0.3,
                    ),
                  );
                },
              ),
            ),

            // Settings label
            Positioned(
              bottom: widget.size * 0.25,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: widget.size * 0.08,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Tap indicator
            Positioned(
              bottom: widget.size * 0.1,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Tap to configure',
                  style: TextStyle(
                    fontSize: widget.size * 0.06,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),

            // Expand arrow
            Positioned(
              top: widget.size * 0.05,
              right: widget.size * 0.05,
              child: Container(
                width: widget.size * 0.08,
                height: widget.size * 0.08,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.8),
                ),
                child: Icon(
                  Icons.expand_more,
                  color: Colors.white,
                  size: widget.size * 0.04,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedSettings() {
    final accentColor = widget.accentColor ?? Colors.teal;

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_expandAnimation.value * 0.5),
          child: Container(
            width: widget.size * 1.5,
            height: widget.size * 1.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accentColor.withOpacity(0.3),
                  accentColor.withOpacity(0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.8, 1.0],
              ),
              border: Border.all(
                color: accentColor.withOpacity(0.6),
                width: 3,
              ),
            ),
            child: Stack(
              children: [
                // Close button
                Positioned(
                  top: widget.size * 0.05,
                  right: widget.size * 0.05,
                  child: GestureDetector(
                    onTap: _toggleExpanded,
                    child: Container(
                      width: widget.size * 0.08,
                      height: widget.size * 0.08,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.8),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: widget.size * 0.04,
                      ),
                    ),
                  ),
                ),

                // Settings content
                Positioned(
                  top: widget.size * 0.15,
                  left: widget.size * 0.15,
                  right: widget.size * 0.15,
                  bottom: widget.size * 0.15,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSettingSection(
                          'API Configuration',
                          [
                            _buildTextField('Weather API Key', _weatherApiKey,
                                (value) => _weatherApiKey = value),
                            _buildTextField(
                                'Spotify Client ID',
                                _spotifyClientId,
                                (value) => _spotifyClientId = value),
                            _buildTextField(
                                'Spotify Redirect URL',
                                _spotifyRedirectUrl,
                                (value) => _spotifyRedirectUrl = value),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _buildSettingSection(
                          'MQTT Settings',
                          [
                            _buildTextField('MQTT Broker', _mqttBroker,
                                (value) => _mqttBroker = value),
                            _buildTextField('MQTT Username', _mqttUsername,
                                (value) => _mqttUsername = value),
                            _buildTextField('MQTT Password', _mqttPassword,
                                (value) => _mqttPassword = value,
                                isPassword: true),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _buildSettingSection(
                          'AI Assistant',
                          [
                            _buildMultilineField(
                              'Assistant Prompt Style',
                              _assistantPrompt,
                              (value) => _assistantPrompt = value,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _buildSettingSection(
                          'Preferences',
                          [
                            _buildSwitch('Auto Launch', _autoLaunch,
                                (value) => _autoLaunch = value),
                            _buildSwitch('Dark Mode', _darkMode,
                                (value) => _darkMode = value),
                            _buildSlider('Brightness', _brightness,
                                (value) => _brightness = value),
                            _buildSlider(
                                'Volume', _volume, (value) => _volume = value),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Save button
                        GestureDetector(
                          onTap: _saveSettings,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              'Save Settings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: widget.size * 0.06,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.size * 0.06,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged,
      {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: TextField(
        obscureText: isPassword,
        style: TextStyle(
          color: Colors.white,
          fontSize: widget.size * 0.05,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white70,
            fontSize: widget.size * 0.04,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
        ),
        onChanged: onChanged,
        controller: TextEditingController(text: value),
      ),
    );
  }

  Widget _buildMultilineField(
      String label, String value, Function(String) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: TextField(
        minLines: 3,
        maxLines: 6,
        style: TextStyle(
          color: Colors.white,
          fontSize: widget.size * 0.045,
        ),
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          labelStyle: TextStyle(
            color: Colors.white70,
            fontSize: widget.size * 0.04,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
        ),
        onChanged: onChanged,
        controller: TextEditingController(text: value),
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.size * 0.05,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: widget.accentColor ?? Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ${(value * 100).round()}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.size * 0.05,
            ),
          ),
          Slider(
            value: value,
            onChanged: onChanged,
            activeColor: widget.accentColor ?? Colors.teal,
            inactiveColor: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
