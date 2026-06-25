class AppConfig {
  // Weather API Configuration
  static const String weatherApiKey = 'YOUR_OPENWEATHER_API_KEY_HERE';
  static const String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  
  // Spotify API Configuration
  static const String spotifyClientId = 'YOUR_SPOTIFY_CLIENT_ID_HERE';
  static const String spotifyClientSecret = 'YOUR_SPOTIFY_CLIENT_SECRET_HERE';
  static const String spotifyRedirectUrl = 'YOUR_SPOTIFY_REDIRECT_URL_HERE';
  static const List<String> spotifyScopes = [
    'user-read-private',
    'user-read-email',
    'user-read-playback-state',
    'user-modify-playback-state',
    'user-read-currently-playing',
    'streaming',
    'playlist-read-private',
    'playlist-read-collaborative',
  ];
  
  // MQTT Configuration
  static const String mqttBroker = 'localhost';
  static const int mqttPort = 1883;
  static const String mqttUsername = 'YOUR_MQTT_USERNAME_HERE';
  static const String mqttPassword = 'YOUR_MQTT_PASSWORD_HERE';
  static const String mqttClientId = 'homepod_assistant';
  
  // MQTT Topics
  static const Map<String, String> mqttTopics = {
    'lights': 'home/lights',
    'plugs': 'home/plugs',
    'thermostat': 'home/thermostat',
    'sensors': 'home/sensors',
    'status': 'homepod/status',
  };
  
  // Voice Assistant Configuration
  static const String wakeWord = 'Hey HomePod';
  static const double voiceSensitivity = 0.7;
  static const int maxRecordingDuration = 30; // seconds
  
  // UI Configuration
  static const bool enableAnimations = true;
  static const bool enableHapticFeedback = true;
  static const double defaultBrightness = 0.8;
  static const double defaultVolume = 0.7;
  
  // Network Configuration
  static const int connectionTimeout = 10000; // milliseconds
  static const int retryAttempts = 3;
  static const bool enableOfflineMode = true;
  
  // Storage Configuration
  static const int maxLogEntries = 1000;
  static const int maxCacheSize = 100; // MB
  static const bool enableAutoCleanup = true;
  
  // Security Configuration
  static const bool enableEncryption = true;
  static const bool enableCertificateValidation = true;
  static const List<String> allowedOrigins = [
    'https://localhost:8080',
    'https://your-domain.com',
  ];
  
  // Development Configuration
  static const bool enableDebugMode = true;
  static const bool enablePerformanceMonitoring = true;
  static const bool enableErrorReporting = true;
  
  // Feature Flags
  static const Map<String, bool> features = {
    'weather': true,
    'spotify': true,
    'smart_home': true,
    'news': true,
    'calendar': true,
    'voice_commands': true,
    'gesture_control': false,
    'face_recognition': false,
  };
  
  // API Rate Limits
  static const Map<String, int> rateLimits = {
    'weather': 60, // calls per minute
    'spotify': 100, // calls per minute
    'news': 30, // calls per minute
    'mqtt': 1000, // messages per minute
  };
  
  // Default Settings
  static const Map<String, dynamic> defaultSettings = {
    'theme': 'dark',
    'language': 'en',
    'timezone': 'auto',
    'units': 'metric',
    'notifications': true,
    'auto_update': true,
    'privacy_mode': false,
  };
  
  // Validation Methods
  static bool isValidApiKey(String key) {
    return key.isNotEmpty && key != 'YOUR_API_KEY_HERE' && key.length >= 10;
  }
  
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  static bool isFeatureEnabled(String feature) {
    return features[feature] ?? false;
  }
  
  // Configuration Helpers
  static String getMqttTopic(String deviceType, String deviceId, String action) {
    return '${mqttTopics[deviceType]}/$deviceId/$action';
  }
  
  static String getWeatherUrl(String endpoint) {
    return '$weatherBaseUrl/$endpoint?appid=$weatherApiKey&units=metric';
  }
  
  static Map<String, String> getSpotifyHeaders() {
    return {
      'Authorization': 'Bearer YOUR_ACCESS_TOKEN_HERE',
      'Content-Type': 'application/json',
    };
  }
  
  // Environment Detection
  static bool get isDevelopment => enableDebugMode;
  static bool get isProduction => !enableDebugMode;
  static bool get isTestMode => false; // Set to true for testing
  
  // Performance Configuration
  static const Map<String, int> performanceLimits = {
    'maxWidgets': 10,
    'maxAnimations': 5,
    'maxNetworkRequests': 20,
    'maxMemoryUsage': 512, // MB
  };
  
  // Error Handling Configuration
  static const Map<String, String> errorMessages = {
    'network_error': 'Network connection failed. Please check your internet connection.',
    'api_error': 'Service temporarily unavailable. Please try again later.',
    'permission_error': 'Permission denied. Please check your settings.',
    'authentication_error': 'Authentication failed. Please check your credentials.',
    'rate_limit_error': 'Too many requests. Please wait before trying again.',
  };
  
  // Localization Configuration
  static const Map<String, Map<String, String>> localizations = {
    'en': {
      'wake_word': 'Hey HomePod',
      'listening': 'Listening...',
      'processing': 'Processing...',
      'speaking': 'Speaking...',
      'error': 'Error occurred',
    },
    'es': {
      'wake_word': 'Hola HomePod',
      'listening': 'Escuchando...',
      'processing': 'Procesando...',
      'speaking': 'Hablando...',
      'error': 'Error ocurrido',
    },
    'fr': {
      'wake_word': 'Salut HomePod',
      'listening': 'Écoute...',
      'processing': 'Traitement...',
      'speaking': 'Parle...',
      'error': 'Erreur survenue',
    },
  };
  
  // Accessibility Configuration
  static const Map<String, bool> accessibilityFeatures = {
    'high_contrast': false,
    'large_text': false,
    'screen_reader': false,
    'reduced_motion': false,
    'color_blind_support': false,
  };
} 