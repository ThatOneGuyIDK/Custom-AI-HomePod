import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homepod_assistant/providers/app_config.dart';
import 'package:homepod_assistant/providers/assistant_state.dart';
import 'package:homepod_assistant/services/brightness_service.dart';
import 'package:homepod_assistant/services/volume_service.dart';
import 'package:homepod_assistant/services/network_service.dart';
import 'package:homepod_assistant/services/system_info_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsApp extends StatefulWidget {
  const SettingsApp({super.key});

  @override
  State<SettingsApp> createState() => _SettingsAppState();
}

class _SettingsAppState extends State<SettingsApp> {
  // Mock settings (to be replaced with real implementations)
  bool _notificationsEnabled = true;
  String _selectedTheme = 'Dark';
  final String _searchQuery = '';

  // Real system settings
  double _realBrightness = 0.5;
  double _realVolume = 0.5;
  bool _isMuted = false;
  String _assistantPrompt =
      'You are HomePod Assistant, a practical AI helper for daily tasks. '
      'Be concise, friendly, and action-oriented. '
      'Prioritize clear steps, useful suggestions, and direct answers. '
      'If the user asks something ambiguous, ask one short clarification question. '
      'Avoid roleplay, long disclaimers, and unnecessary filler. '
      'For smart home tasks, propose safe, reversible actions first.';
  NetworkStatus _networkStatus = NetworkStatus(
    isConnected: false,
    networkName: 'Unknown',
    ipAddress: 'Unknown',
    timestamp: DateTime.now(),
  );
  AppVersionInfo _appVersion = AppVersionInfo(
    appName: 'HomePod Assistant',
    packageName: 'com.example.homepod_assistant',
    version: '1.0.0',
    buildNumber: '1',
  );
  SystemStats _systemStats = SystemStats(
    memoryUsage: 0.0,
    cpuUsage: 0.0,
    diskUsage: 0.0,
    uptime: Duration.zero,
    temperature: 0.0,
  );
  bool _isLoading = true;

  final List<String> _themes = ['Dark', 'Light', 'Blue', 'Green', 'Purple', 'Orange', 'Pink', 'Auto'];

  @override
  void initState() {
    super.initState();
    _loadRealSystemSettings();
  }

  Future<void> _loadRealSystemSettings() async {
    try {
      // Load real brightness
      _realBrightness = await BrightnessService.getBrightness();
      
      // Load real volume
      _realVolume = await VolumeService.getMasterVolume();
      _isMuted = await VolumeService.isMuted();
      
      // Load network status
      _networkStatus = await NetworkService.getNetworkStatus();
      
      // Load app version
      _appVersion = await SystemInfoService.getAppVersion();
      
      // Load system stats
      // Load assistant prompt
      final prefs = await SharedPreferences.getInstance();
      _assistantPrompt = prefs.getString('assistant_prompt') ?? _assistantPrompt;
      
      if (mounted) {
        context.read<AssistantState>().setAssistantPrompt(_assistantPrompt);
      }
      
      _systemStats = await SystemInfoService.getSystemStats();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading system settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.settings, color: Colors.grey, size: 32),
                SizedBox(width: 12),
                Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Settings List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Notifications
                _buildSettingTile(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Enable push notifications',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeColor: Colors.grey,
                  ),
                ),
                
                                                  const Divider(color: Colors.white24),
                 
                 // Manual Brightness
                 _buildSettingTile(
                   icon: Icons.brightness_6,
                   title: 'Brightness',
                   subtitle: 'Manual brightness control',
                   trailing: SizedBox(
                     width: 100,
                     child: Slider(
                       value: _realBrightness,
                       onChanged: (value) async {
                         try {
                           await BrightnessService.setBrightness(value);
                           setState(() {
                             _realBrightness = value;
                           });
                         } catch (e) {
                           print('Error setting brightness: $e');
                         }
                       },
                       activeColor: Colors.grey,
                       inactiveColor: Colors.grey.withOpacity(0.3),
                     ),
                   ),
                 ),
                 
                 const Divider(color: Colors.white24),
                
                // Volume
                _buildSettingTile(
                  icon: Icons.volume_up,
                  title: 'Volume',
                  subtitle: 'System volume level',
                  trailing: SizedBox(
                    width: 100,
                                          child: Slider(
                        value: _realVolume,
                        onChanged: (value) async {
                          try {
                            await VolumeService.setMasterVolume(value);
                            setState(() {
                              _realVolume = value;
                            });
                          } catch (e) {
                            print('Error setting volume: $e');
                          }
                        },
                      activeColor: Colors.grey,
                      inactiveColor: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ),
                
                                 const Divider(color: Colors.white24),
                
                                 // Theme
                 _buildSettingTile(
                   icon: Icons.palette,
                   title: 'Theme',
                   subtitle: 'App appearance',
                   trailing: DropdownButton<String>(
                     value: _selectedTheme,
                     onChanged: (String? newValue) {
                       if (newValue != null) {
                         setState(() {
                           _selectedTheme = newValue;
                         });
                         _applyTheme(newValue);
                       }
                     },
                     dropdownColor: Colors.black,
                     style: const TextStyle(color: Colors.white),
                     underline: Container(),
                     items: _themes.map<DropdownMenuItem<String>>((String value) {
                       return DropdownMenuItem<String>(
                         value: value,
                         child: Text(value),
                       );
                     }).toList(),
                   ),
                 ),
                
                const Divider(color: Colors.white24),
                
                // Weather Location
                Consumer<AppConfig>(
                  builder: (context, appConfig, child) {
                    return _buildSettingTile(
                      icon: Icons.location_on,
                      title: 'Weather Location',
                      subtitle: appConfig.weatherLocation,
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () => _showWeatherLocationDialog(context, appConfig),
                      ),
                    );
                  },
                ),
                
                const Divider(color: Colors.white24),
                
                // AI Assistant Prompt
                _buildSettingTile(
                  icon: Icons.psychology,
                  title: 'AI Assistant Prompt',
                  subtitle: 'Customize assistant behavior',
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: () => _showPromptDialog(context),
                  ),
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Reset to defaults
                    setState(() {
                      _notificationsEnabled = true;
                      _realBrightness = 0.7;
                      _realVolume = 0.5;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings reset to defaults!'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Save settings
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('assistant_prompt', _assistantPrompt);
                    
                    if (mounted) {
                      context.read<AssistantState>().setAssistantPrompt(_assistantPrompt);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings saved!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
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

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      trailing: trailing,
      contentPadding: EdgeInsets.zero,
    );
  }

     void _applyTheme(String theme) {
     // Apply theme changes
     switch (theme) {
       case 'Dark':
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: const Text('Dark theme applied'),
             backgroundColor: Colors.grey[800],
           ),
         );
         break;
       case 'Light':
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: const Text('Light theme applied'),
             backgroundColor: Colors.grey[300],
           ),
         );
         break;
       case 'Blue':
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Blue theme applied'),
             backgroundColor: Colors.blue,
           ),
         );
         break;
       case 'Green':
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Green theme applied'),
             backgroundColor: Colors.green,
           ),
         );
         break;
       case 'Purple':
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Purple theme applied'),
             backgroundColor: Colors.purple,
           ),
         );
         break;
       case 'Orange':
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Orange theme applied'),
             backgroundColor: Colors.orange,
           ),
         );
         break;
       case 'Pink':
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Pink theme applied'),
             backgroundColor: Colors.pink,
           ),
         );
         break;
       case 'Auto':
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Auto theme applied (follows system)'),
             backgroundColor: Colors.blue,
           ),
         );
         break;
     }
   }
   
   void _showPromptDialog(BuildContext context) {
    final controller = TextEditingController(text: _assistantPrompt);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 600,
          height: 500,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.psychology, color: Colors.grey, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'AI Assistant Prompt',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              
              // Prompt Editor
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: controller,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: 'Enter assistant system prompt...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey, width: 2),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
              
              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _assistantPrompt = controller.text;
                        });
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
   }

   void _showWeatherLocationDialog(BuildContext context, AppConfig appConfig) {
     showDialog(
       context: context,
       builder: (context) => WeatherLocationDialog(appConfig: appConfig),
     );
   }
 }
 
 class WeatherLocationDialog extends StatefulWidget {
   final AppConfig appConfig;
   
   const WeatherLocationDialog({super.key, required this.appConfig});
 
   @override
   State<WeatherLocationDialog> createState() => _WeatherLocationDialogState();
 }
 
 class _WeatherLocationDialogState extends State<WeatherLocationDialog> {
   String _searchQuery = '';
   final TextEditingController _searchController = TextEditingController();
 
   @override
   void dispose() {
     _searchController.dispose();
     super.dispose();
   }
 
   @override
   Widget build(BuildContext context) {
     return Dialog(
       backgroundColor: Colors.transparent,
       child: Container(
         width: 320,
         height: 400,
         decoration: BoxDecoration(
           color: Colors.black.withOpacity(0.95),
           borderRadius: BorderRadius.circular(20),
           border: Border.all(color: Colors.grey, width: 2),
         ),
         child: Column(
           children: [
             // Header
             Container(
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: Colors.grey.withOpacity(0.2),
                 borderRadius: const BorderRadius.only(
                   topLeft: Radius.circular(18),
                   topRight: Radius.circular(18),
                 ),
               ),
               child: const Row(
                 children: [
                   Icon(Icons.location_on, color: Colors.grey, size: 24),
                   SizedBox(width: 12),
                   Text(
                     'Weather Location',
                     style: TextStyle(
                       color: Colors.white,
                       fontSize: 20,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 ],
               ),
             ),
             
             // Search Field
             Padding(
               padding: const EdgeInsets.all(20),
               child: TextField(
                 controller: _searchController,
                 onChanged: (value) {
                   setState(() {
                     _searchQuery = value;
                   });
                 },
                 decoration: InputDecoration(
                   hintText: 'Search for a city...',
                   hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                   prefixIcon: const Icon(Icons.search, color: Colors.grey),
                   filled: true,
                   fillColor: Colors.white.withOpacity(0.1),
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                     borderSide: BorderSide.none,
                   ),
                   focusedBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                     borderSide: const BorderSide(color: Colors.grey, width: 2),
                   ),
                 ),
                 style: const TextStyle(color: Colors.white),
               ),
             ),
             
             // Location List
             Expanded(
               child: Consumer<AppConfig>(
                 builder: (context, config, child) {
                   final allLocations = config.getSuggestedLocations();
                   final locations = _searchQuery.isEmpty 
                       ? config.favoriteLocations 
                       : allLocations
                           .where((location) => 
                               location.toLowerCase().contains(_searchQuery.toLowerCase()))
                           .toList();
                   
                   return ListView.builder(
                     padding: const EdgeInsets.symmetric(horizontal: 20),
                     itemCount: locations.length,
                     itemBuilder: (context, index) {
                       final location = locations[index];
                       final isCurrent = location == config.weatherLocation;
                       final isFavorite = config.favoriteLocations.contains(location);
                       
                       return ListTile(
                         leading: Icon(
                           isCurrent ? Icons.my_location : Icons.location_on,
                           color: isCurrent ? Colors.grey : Colors.white70,
                         ),
                         title: Text(
                           location,
                           style: TextStyle(
                             color: isCurrent ? Colors.grey : Colors.white,
                             fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                           ),
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                         ),
                         trailing: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             if (isCurrent)
                               const Icon(Icons.check, color: Colors.grey, size: 20)
                             else if (isFavorite)
                               const Icon(Icons.favorite, color: Colors.red, size: 20)
                             else
                               IconButton(
                                 icon: const Icon(Icons.favorite_border, color: Colors.white70, size: 20),
                                 onPressed: () => config.addFavoriteLocation(location),
                               ),
                           ],
                         ),
                         onTap: () {
                           config.setWeatherLocation(location);
                           Navigator.of(context).pop();
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                               content: Text('Weather location set to $location'),
                               backgroundColor: Colors.green,
                             ),
                           );
                         },
                       );
                     },
                   );
                 },
               ),
             ),
           ],
         ),
       ),
     );
   }
} 