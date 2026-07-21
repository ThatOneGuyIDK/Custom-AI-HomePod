import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:homepod_assistant/services/ai_model_service.dart';
import 'package:homepod_assistant/services/web_speech_service.dart';
import 'dart:math' as math;

class VoiceAssistantService {
  static final VoiceAssistantService _instance =
      VoiceAssistantService._internal();
  factory VoiceAssistantService() => _instance;
  VoiceAssistantService._internal();

  // Audio components
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final WebSpeechService _webSpeechService = WebSpeechService();
  final AIModelService _aiService = AIModelService();

  // Stream controllers for real-time updates
  final StreamController<String> _speechStreamController =
      StreamController<String>.broadcast();
  final StreamController<String> _responseStreamController =
      StreamController<String>.broadcast();
  final StreamController<double> _volumeStreamController =
      StreamController<double>.broadcast();
  final StreamController<bool> _isListeningController =
      StreamController<bool>.broadcast();
  final StreamController<String> _debugStreamController =
      StreamController<String>.broadcast();
  final StreamController<String> _transcriptionStreamController =
      StreamController<String>.broadcast();

  // Configuration
  String _wakeWord = "Hey HomePod";
  String _stopKeyword = "stop";
  bool _isInitialized = false;
  bool _isListening = false;
  bool _speechEnabled = false;
  Timer? _volumeTimer;
  String _currentTranscription = '';
  DateTime? _wakeWindowExpiresAt;
  Timer? _restartTimer;
  Timer? _speechCompletionTimer;
  String _pendingTranscript = '';
  String _lastHandledTranscript = '';
  DateTime? _lastHandledAt;
  int _restartAttempts = 0;
  static const int _maxRestartAttempts = 5;
  static const Duration _postWakeWindow = Duration(seconds: 8);
  static const Duration _speechCompletionDebounce =
      Duration(milliseconds: 1200);
  bool _hasAudioInput = false; // Track if we've detected any audio input
  double _lastAudioLevel = 0.0; // Track the last audio level detected
  bool _isSpeaking = false; // Prevent self-listening while TTS is active
  bool _useWebSpeechApi = false; // Use Web Speech API instead of speech_to_text
  String _speechServiceType =
      "auto"; // "auto", "speech_to_text", "web_speech_api", "unavailable"
  bool _isProcessingQuery =
      false; // Track if we're currently processing an AI query

  // Getters
  Stream<String> get speechStream => _speechStreamController.stream;
  Stream<String> get responseStream => _responseStreamController.stream;
  Stream<double> get volumeStream => _volumeStreamController.stream;
  Stream<bool> get isListeningStream => _isListeningController.stream;
  Stream<String> get debugStream => _debugStreamController.stream;
  Stream<String> get transcriptionStream =>
      _transcriptionStreamController.stream;

  void _debugLog(String message) {
    _debugStreamController.add(message);
  }

  /// Initialize the voice assistant
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _debugLog("🔧 Initializing Voice Assistant...");

      // Request microphone permission
      _debugLog("🎤 Requesting microphone permission...");
      final micPermission = await Permission.microphone.request();
      _debugLog("🎤 Microphone permission status: $micPermission");

      if (micPermission != PermissionStatus.granted) {
        _debugLog("❌ Microphone permission denied!");
        _debugLog("💡 This might be due to:");
        _debugLog("   - Browser security (requires HTTPS for microphone)");
        _debugLog("   - Running on localhost (HTTP not allowed)");
        _debugLog("   - Browser blocking microphone access");
        _speechEnabled = false;
        _speechServiceType = "unavailable";
        _isInitialized = true;
        _debugLog("⛔ Voice Assistant initialized without speech input");
        return;
      }

      // System diagnostics
      _debugLog("🔍 System Diagnostics:");
      _debugLog("   - Current URL: ${Uri.base}");
      _debugLog("   - Protocol: ${Uri.base.scheme}");
      _debugLog("   - Host: ${Uri.base.host}");
      _debugLog("   - Port: ${Uri.base.port}");
      _debugLog("   - Is HTTPS: ${Uri.base.scheme == 'https'}");

      // Skip Web Speech API entirely - use speech_to_text which was working
      _debugLog("🎯 Using speech_to_text package (Web Speech API disabled)");

      // On web platform, use Web Speech API; on other platforms, use speech_to_text
      if (kIsWeb) {
        _debugLog("🌐 Web platform detected - attempting Web Speech API...");
        if (_webSpeechService.isSupported) {
          _debugLog("✅ Web Speech API is supported");
          _speechEnabled = await _webSpeechService.initialize();
          if (_speechEnabled) {
            _useWebSpeechApi = true;
            _debugLog("✅ Web Speech API initialized successfully");

            // Set up transcription listener
            _webSpeechService.transcriptionStream.listen((transcript) {
              _currentTranscription = transcript;

              _transcriptionStreamController.add(
                transcript,
              );

              _scheduleDebouncedSpeechCompletion(
                transcript.toLowerCase(),
              );
            });

            // Set up error listener
            _webSpeechService.errorStream.listen((error) {
              _debugLog("❌ Web Speech API error: $error");
            });
          } else {
            _debugLog("❌ Failed to initialize Web Speech API");
          }
        } else {
          _debugLog("❌ Web Speech API not supported in this browser");
        }
      } else {
        _debugLog("📱 Non-web platform - using speech_to_text package");
      }

      // Skip speech_to_text on web platform entirely - it has type mismatch issues with browser events
      if (!_useWebSpeechApi && !kIsWeb) {
        _debugLog("🎯 Attempting speech_to_text package...");
        _debugLog("🌐 Note: Speech recognition requires internet connection");
        _debugLog("🔒 Note: Microphone access requires HTTPS (not localhost)");

        try {
          _speechEnabled = await _speechToText.initialize(
            onError: (dynamic error) {
              try {
                // Handle both SpeechRecognitionError and Event types from browser
                final errorMsg = error is Map
                    ? error['error']
                    : (error.errorMsg ?? 'unknown');
                final isPermanent = error is Map
                    ? error['permanent'] ?? false
                    : (error.permanent ?? false);

                _debugLog("❌ Speech recognition error: $errorMsg");
                _debugLog(
                    "❌ Error details: ${isPermanent ? 'Permanent' : 'Temporary'} error");
                _debugLog("🌐 Current URL: ${Uri.base}");

                // Provide specific guidance based on error type
                if (errorMsg.toString().contains('network')) {
                  _debugLog(
                      "🌐 Network error - trying to connect to speech service...");
                  _debugLog("💡 This might be due to:");
                  _debugLog("   - Ngrok tunnel blocking speech API calls");
                  _debugLog("   - CORS issues with speech service");
                  _debugLog("   - Firewall blocking speech API");
                  _debugLog("   - Speech service temporarily unavailable");
                } else if (errorMsg.toString().contains('not-allowed')) {
                  _debugLog("🚫 Microphone access denied - HTTPS required");
                  _debugLog(
                      "💡 Make sure you clicked 'Allow' on the microphone permission");
                } else if (errorMsg.toString().contains('no-speech')) {
                  _debugLog("🔇 No speech detected - this is normal");
                }

                // Don't stop listening for temporary errors, just log them
                if (isPermanent) {
                  _isListening = false;
                  _isListeningController.add(false);
                  _debugLog("🛑 Stopping due to permanent error");
                } else {
                  _debugLog("⚠️ Temporary error - will retry...");
                }
              } catch (e) {
                _debugLog("⚠️ Error handler error (ignoring): $e");
              }
            },
            onStatus: (dynamic status) {
              try {
                _debugLog("📊 Speech recognition status: $status");
                if (status == 'done' || status == 'notListening') {
                  _debugLog("🔄 Speech recognition stopped, restarting...");
                  // Restart listening if we're supposed to be listening
                  if (_isListening) {
                    _restartTimer?.cancel();
                    _restartTimer =
                        Timer(const Duration(milliseconds: 1000), () {
                      if (_isListening &&
                          _restartAttempts < _maxRestartAttempts) {
                        _restartAttempts++;
                        _debugLog(
                            "🔄 Restart attempt $_restartAttempts/$_maxRestartAttempts");
                        _startListeningInternal();
                      } else if (_restartAttempts >= _maxRestartAttempts) {
                        _debugLog(
                            "❌ Max restart attempts reached; stopping listening");
                        _isListening = false;
                        _isListeningController.add(false);
                      }
                    });
                  }
                }
              } catch (e) {
                _debugLog("⚠️ Status handler error (ignoring): $e");
              }
            },
          );
        } catch (e) {
          _debugLog("❌ Speech_to_text initialization error: $e");
          _speechEnabled = false;
        }
      } else if (kIsWeb) {
        _debugLog(
            "⚠️ Speech_to_text disabled on web platform (browser compatibility issues)");
        _debugLog("💡 Using Web Speech API instead...");
      }

      _debugLog("🎯 Speech recognition enabled: $_speechEnabled");

      if (!_speechEnabled && !_useWebSpeechApi) {
        _debugLog("❌ Both speech recognition methods failed!");
        _debugLog("💡 Requirements not met:");
        _debugLog("   - HTTPS connection (not localhost)");
        _debugLog("   - Internet connection (for cloud services)");
        _debugLog("   - Browser microphone permission");
        _debugLog("   - Supported browser (Chrome, Edge, Safari)");
        _speechEnabled = false;
        _speechServiceType = "unavailable";
      } else if (_useWebSpeechApi) {
        _debugLog("✅ Web Speech API active!");
        _debugLog("🎤 Using browser's native speech recognition");
        _speechServiceType = "web_speech_api";
      } else {
        _debugLog("✅ speech_to_text package initialized successfully!");
        _debugLog("🎤 Using speech_to_text package for recognition");
        _speechServiceType = "speech_to_text";
      }

      // Initialize TTS
      _debugLog("🔊 Initializing TTS...");
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.awaitSpeakCompletion(true);

      // Set up TTS callbacks
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        _debugLog("🔊 TTS started");
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _debugLog("🔊 TTS completed");
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        _debugLog("❌ TTS error: $msg");
      });

      _isInitialized = true;
      _debugLog("✅ Voice Assistant initialized successfully!");
      _debugLog("🔧 Speech Service: $_speechServiceType");

      if (_useWebSpeechApi) {
        _debugLog("🌐 WEB SPEECH API MODE ACTIVE!");
        _debugLog("💡 Using browser's native speech recognition");
        _debugLog("💡 May work offline in some browsers");
        _debugLog("💡 Click center area and speak clearly!");
      } else {
        _debugLog("🎤 SPEECH_TO_TEXT MODE ACTIVE!");
        _debugLog("💡 Using speech_to_text package");
        _debugLog("💡 Requires internet connection");
        _debugLog("💡 You can now speak and it will transcribe your voice!");
      }
    } catch (e) {
      _debugLog("❌ Error initializing Voice Assistant: $e");
      _speechEnabled = false;
      _speechServiceType = "unavailable";
      _isInitialized = true;
    }
  }

  /// Start listening for voice input
  Future<void> startListening() async {
    _debugLog("🎤 Starting to listen...");

    if (!_isInitialized) {
      _debugLog("🔄 Not initialized, initializing first...");
      await initialize();
    }

    try {
      if (!_speechEnabled) {
        _debugLog("❌ Speech recognition not available!");
        throw Exception('Speech recognition not available');
      }

      _isListening = true;
      _isListeningController.add(true);
      _currentTranscription = '';
      _wakeWindowExpiresAt = null;
      _transcriptionStreamController.add(_currentTranscription);
      _restartAttempts = 0; // Reset restart attempts
      _debugLog("✅ Listening state set to true");

      // Start volume monitoring
      _startVolumeMonitoring();

      if (_useWebSpeechApi) {
        _debugLog("🌐 Starting Web Speech API...");
        bool started = await _webSpeechService.startListening();
        if (!started) {
          _debugLog("❌ Failed to start Web Speech API, trying manual start...");
          started = await _webSpeechService.manualStart();

          if (!started) {
            _debugLog("❌ Manual start failed, trying force restart...");
            bool restarted = await _webSpeechService.forceRestart();
            if (restarted) {
              started = await _webSpeechService.startListening();
            }
          }

          if (!started) {
            _debugLog("❌ Web Speech API still not working; stopping listening");
            _isListening = false;
            _isListeningController.add(false);
          }
        }
      } else {
        _debugLog("🎤 Starting speech_to_text...");
        await _startListeningInternal();
      }
    } catch (e) {
      _debugLog("❌ Error starting listening: $e");
      _isListening = false;
      _isListeningController.add(false);
    }
  }

  /// Internal method to start listening
  Future<void> _startListeningInternal() async {
    _debugLog("🎯 Starting speech recognition...");
    try {
      await _speechToText.listen(
        onResult: (result) {
          _debugLog(
              "🎯 Speech result: ${result.recognizedWords} (final: ${result.finalResult})");

          if (_isSpeaking) {
            _debugLog("🔇 Ignoring recognition while TTS is speaking");
            return;
          }

          // Update transcription in real-time (even partial results)
          if (result.recognizedWords.isNotEmpty) {
            _currentTranscription = result.recognizedWords;
            _transcriptionStreamController.add(_currentTranscription);
            _debugLog("📝 Live transcription: '$result.recognizedWords'");

            if (_isListening && !_isSpeaking) {
              _scheduleDebouncedSpeechCompletion(
                  result.recognizedWords.toLowerCase());
            }
          }

          if (result.finalResult) {
            final recognizedWords = result.recognizedWords.toLowerCase();
            _debugLog("✅ Final recognized words: '$recognizedWords'");

            // Reset restart attempts on successful recognition
            _restartAttempts = 0;

            _speechCompletionTimer?.cancel();
            _pendingTranscript = '';
            _handleRecognizedInput(recognizedWords);

            // Clear transcription after processing
            _currentTranscription = '';
            _transcriptionStreamController.add(_currentTranscription);
          }
        },
        listenFor: const Duration(seconds: 120), // Extended to 2 minutes
        pauseFor: const Duration(seconds: 10), // Much longer pause
        localeId: "en_US",
        partialResults: true, // Enable partial results for real-time feedback
        cancelOnError: false, // Don't cancel on temporary errors
        listenMode: stt.ListenMode
            .confirmation, // Use confirmation mode for better accuracy
      );

      _debugLog("✅ Started listening for voice input");
    } catch (e) {
      _debugLog("❌ Error in _startListeningInternal: $e");
      // Don't throw here, let the restart mechanism handle it
    }
  }

  /// Stop listening and process the audio
  Future<void> stopListening() async {
    _debugLog("🛑 Stopping listening...");
    try {
      _isListening = false;
      _isListeningController.add(false);
      _currentTranscription = '';
      _wakeWindowExpiresAt = null;
      _pendingTranscript = '';
      _transcriptionStreamController.add(_currentTranscription);
      _restartAttempts = 0; // Reset restart attempts

      // Stop timers
      _volumeTimer?.cancel();
      _restartTimer?.cancel();
      _speechCompletionTimer?.cancel();

      if (_useWebSpeechApi) {
        // Stop Web Speech API
        await _webSpeechService.stopListening();
      } else {
        // Stop speech_to_text
        await _speechToText.stop();
      }

      _debugLog("✅ Stopped listening");
    } catch (e) {
      _debugLog("❌ Error stopping listening: $e");
    }
  }

  /// Process wake word detection
  void _processWakeWordDetection(String recognizedWords) {
    _debugLog("🔔 Wake word detected: $recognizedWords");

    // Remove wake word and process the rest
    final cleanInput = _removeWakeWord(recognizedWords);
    if (cleanInput.isNotEmpty) {
      _debugLog("💬 Processing wake word input: '$cleanInput'");
      _processRecognizedSpeech(cleanInput);
    }
  }

  /// Unified input gate for recognized speech.
  void _handleRecognizedInput(String recognizedWords) {
    final normalized = recognizedWords.trim().toLowerCase();
    if (normalized.isEmpty || !_isListening) return;

    if (_isRecentlyHandled(normalized)) {
      _debugLog("🔁 Ignoring duplicate transcript: '$normalized'");
      return;
    }

    if (_isWakeWordDetected(normalized)) {
      _debugLog("🔔 Wake word detected!");
      _markHandled(normalized);
      _processWakeWordDetection(normalized);
    } else if (_isStopKeywordDetected(normalized)) {
      _debugLog("💬 Processing stop keyword...");
      _markHandled(normalized);
      _processRecognizedSpeech(normalized);
    } else {
      _debugLog("🙉 Ignored speech without wake word");
    }
  }

  /// Auto-complete speech if transcript stops changing, without waiting for complete silence.
  void _scheduleDebouncedSpeechCompletion(String transcript) {
    if (!_isListening || _isSpeaking) return;

    final normalized = transcript.trim().toLowerCase();
    if (normalized.isEmpty) return;

    _pendingTranscript = normalized;
    _speechCompletionTimer?.cancel();
    _speechCompletionTimer = Timer(_speechCompletionDebounce, () {
      if (!_isListening || _isSpeaking) return;

      final pending = _pendingTranscript.trim();
      if (pending.isEmpty) return;

      // Only auto-complete likely commands to avoid random background fragments.
      final hasWake = _isWakeWordDetected(pending);
      final hasStop = _isStopKeywordDetected(pending);
      if (!hasWake && !hasStop) {
        _debugLog("🔇 Ignoring non-command background transcript: '$pending'");
        return;
      }

      _debugLog("⏱️ Auto-finalizing speech without waiting for full silence");
      _handleRecognizedInput(pending);
      _pendingTranscript = '';
      _currentTranscription = '';
      _transcriptionStreamController.add(_currentTranscription);
    });
  }

  bool _isRecentlyHandled(String transcript) {
    final last = _lastHandledAt;
    if (last == null) return false;
    return transcript == _lastHandledTranscript &&
        DateTime.now().difference(last) < const Duration(seconds: 2);
  }

  void _markHandled(String transcript) {
    _lastHandledTranscript = transcript;
    _lastHandledAt = DateTime.now();
  }

  /// Process recognized speech
  Future<void> _processRecognizedSpeech(String input) async {
    try {
      _debugLog("💬 Processing speech: '$input'");

      // Consume wake window on first accepted command
      _wakeWindowExpiresAt = null;

      // Check for stop keyword first
      if (_isStopKeywordDetected(input)) {
        _debugLog("🛑 Stop keyword detected: '$input'");
        _isProcessingQuery = false; // Cancel any pending query
        _responseStreamController.add('');
        await stopSpeaking();
        await speak("Stopping");
        return;
      }

      // Clean the input by removing punctuation
      final cleanedInput = _removePunctuation(input);
      _debugLog("🧹 Cleaned input: '$input' -> '$cleanedInput'");

      // Add to speech stream
      _speechStreamController.add(cleanedInput);

      // Process with AI
      _debugLog("🤖 Sending to AI...");
      _isProcessingQuery = true;
      final response = await _processWithAI(cleanedInput);

      // Check if query was cancelled while processing
      if (!_isProcessingQuery) {
        _responseStreamController.add('');
        _debugLog("🚫 Query was cancelled, not speaking response");
        return;
      }

      _isProcessingQuery = false;

      if (response.isNotEmpty) {
        _responseStreamController.add(response);
        _debugLog("🔊 Speaking response: '$response'");
        await speak(response);
      } else {
        _responseStreamController.add('');
      }
    } catch (e) {
      _isProcessingQuery = false;
      _responseStreamController
          .add("I'm sorry, I ran into a problem. Please try again.");
      _debugLog("❌ Error processing recognized speech: $e");
    }
  }

  /// Process text with AI model
  Future<String> _processWithAI(String input) async {
    try {
      _debugLog("🤖 Processing with AI: '$input'");
      // Send to AI model using AIModelService
      final response = await _aiService.generateResponse(input);
      _debugLog("🤖 AI response: '$response'");
      return response;
    } catch (e) {
      _debugLog("❌ Error processing with AI: $e");
      return "I'm sorry, I encountered an error. Please try again.";
    }
  }

  /// Check if wake word is detected
  bool _isWakeWordDetected(String input) {
    final detected = input.contains(_wakeWord.toLowerCase());
    _debugLog(
        "🔍 Wake word check: '$input' contains '${_wakeWord.toLowerCase()}' = $detected");
    return detected;
  }

  /// Check if stop keyword is detected
  bool _isStopKeywordDetected(String input) {
    final detected = input.contains(_stopKeyword.toLowerCase());
    _debugLog(
        "🛑 Stop keyword check: '$input' contains '${_stopKeyword.toLowerCase()}' = $detected");
    return detected;
  }

  /// Remove wake word from input
  String _removeWakeWord(String input) {
    final cleaned =
        input.replaceAll(RegExp(_wakeWord, caseSensitive: false), '').trim();
    _debugLog("🧹 Removed wake word: '$input' -> '$cleaned'");
    return cleaned;
  }

  /// Remove punctuation from input
  String _removePunctuation(String input) {
    // Remove common punctuation marks but keep apostrophes in contractions
    final cleaned = input.replaceAll(RegExp(r'[.!?,;:"()\[\]{}]'), '').trim();
    return cleaned;
  }

  /// Speak text using TTS
  Future<void> speak(String text) async {
    bool wasListening = false;
    try {
      wasListening = _isListening;
      if (wasListening) {
        _debugLog("🔇 Pausing listening while TTS speaks");
        await stopListening();
      }

      _isSpeaking = true;
      _debugLog("🔊 Speaking: '$text'");
      await _flutterTts.speak(text);
    } catch (e) {
      _debugLog("❌ Error speaking text: $e");
    } finally {
      _isSpeaking = false;

      if (wasListening && !_isListening) {
        _debugLog(
            "⏱️ Waiting 500ms before resuming listening to avoid self-listening...");
        await Future.delayed(const Duration(milliseconds: 500));
        _debugLog("🎤 Resuming listening after TTS");
        await startListening();
      }
    }
  }

  /// Stop TTS playback immediately
  Future<void> stopSpeaking() async {
    try {
      _debugLog("⏹️ Stopping TTS playback...");
      _isSpeaking = false;
      await _flutterTts.stop();
    } catch (e) {
      _debugLog("❌ Error stopping TTS: $e");
    }
  }

  /// Start volume monitoring using speech recognition
  void _startVolumeMonitoring() {
    _debugLog("📊 Starting volume monitoring...");
    _volumeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isListening) {
        // When not listening, keep volume at 0
        _volumeStreamController.add(0.0);
        _hasAudioInput = false;
        _lastAudioLevel = 0.0;
        timer.cancel();
        return;
      }

      // For real speech recognition, be very responsive to actual audio
      const baseVolume = 0.0; // Start at 0

      // Check if we have any transcription (indicates audio was detected)
      if (_currentTranscription.isNotEmpty) {
        // We have audio input - show responsive volume
        _hasAudioInput = true;
        final audioLevel = 0.4 +
            (math.sin(DateTime.now().millisecondsSinceEpoch * 0.03) * 0.25);
        _lastAudioLevel = audioLevel;
        _volumeStreamController.add(audioLevel);
        _debugLog(
            "🎤 Real voice detected! Volume: ${(audioLevel * 100).toStringAsFixed(1)}%");
      } else {
        // No audio input detected - keep volume very low but show we're listening
        _hasAudioInput = false;
        final volume = baseVolume +
            (math.sin(DateTime.now().millisecondsSinceEpoch * 0.01) * 0.02);
        _volumeStreamController.add(volume.clamp(0.0, 0.05));
      }
    });
  }

  /// Set wake word
  void setWakeWord(String wakeWord) {
    _wakeWord = wakeWord;
    _debugLog("🔔 Wake word set to: '$wakeWord'");
  }

  /// Set stop keyword
  void setStopKeyword(String stopKeyword) {
    _stopKeyword = stopKeyword;
    _debugLog("🛑 Stop keyword set to: '$stopKeyword'");
  }

  /// Set AI model URL
  void setAIModelUrl(String url) {
    _aiService.setBaseUrl(url);
    _debugLog("🤖 AI model URL set to: '$url'");
  }

  /// Set assistant system prompt/persona
  void setAssistantPrompt(String prompt) {
    _aiService.setSystemPrompt(prompt);
    _debugLog("🧠 Assistant prompt updated");
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Check if speech recognition is available
  bool get speechEnabled => _speechEnabled;

  /// Get current transcription
  String get currentTranscription => _currentTranscription;

  /// Check if audio input has been detected
  bool get hasAudioInput => _hasAudioInput;

  /// Get the last detected audio level
  double get lastAudioLevel => _lastAudioLevel;

  /// Test microphone access without speech recognition
  Future<bool> testMicrophoneAccess() async {
    try {
      _debugLog("🎤 Testing microphone access...");

      // Check permission status
      final permissionStatus = await Permission.microphone.status;
      _debugLog("🎤 Current permission status: $permissionStatus");

      if (permissionStatus == PermissionStatus.denied) {
        _debugLog("❌ Microphone permission denied");
        return false;
      }

      if (permissionStatus == PermissionStatus.restricted) {
        _debugLog("🚫 Microphone access restricted");
        return false;
      }

      if (permissionStatus == PermissionStatus.permanentlyDenied) {
        _debugLog("🚫 Microphone permanently denied");
        return false;
      }

      if (permissionStatus == PermissionStatus.granted) {
        _debugLog("✅ Microphone permission granted");
        return true;
      }

      // Request permission if not determined
      if (permissionStatus == PermissionStatus.denied) {
        _debugLog("🤔 Permission denied, requesting...");
        final result = await Permission.microphone.request();
        _debugLog("🎤 Permission request result: $result");
        return result == PermissionStatus.granted;
      }

      return false;
    } catch (e) {
      _debugLog("❌ Error testing microphone: $e");
      return false;
    }
  }

  /// Check if speech recognition is available
  Future<bool> testSpeechRecognition() async {
    try {
      _debugLog("🎯 Testing speech recognition availability...");

      // Test if speech recognition can be initialized
      final available = await _speechToText.initialize(
        onError: (error) {
          _debugLog("❌ Speech recognition test error: ${error.errorMsg}");
        },
        onStatus: (status) {
          _debugLog("📊 Speech recognition test status: $status");
        },
      );

      _debugLog("🎯 Speech recognition available: $available");
      return available;
    } catch (e) {
      _debugLog("❌ Error testing speech recognition: $e");
      return false;
    }
  }

  /// Get detailed system information for debugging
  Future<Map<String, dynamic>> getSystemInfo() async {
    final info = <String, dynamic>{};

    try {
      // Test microphone
      info['microphone_access'] = await testMicrophoneAccess();

      // Test speech recognition
      info['speech_recognition'] = await testSpeechRecognition();

      // Check initialization status
      info['initialized'] = _isInitialized;

      // Check listening status
      info['listening'] = _isListening;

      // Check audio input detection
      info['has_audio_input'] = _hasAudioInput;
      info['last_audio_level'] = _lastAudioLevel;

      _debugLog("📊 System Info: $info");
    } catch (e) {
      _debugLog("❌ Error getting system info: $e");
    }

    return info;
  }

  /// Dispose resources
  void dispose() {
    _debugLog("🧹 Disposing Voice Assistant...");
    _speechStreamController.close();
    _responseStreamController.close();
    _volumeStreamController.close();
    _isListeningController.close();
    _debugStreamController.close();
    _transcriptionStreamController.close();
    _volumeTimer?.cancel();
    _restartTimer?.cancel();
    _speechCompletionTimer?.cancel();
    _speechToText.cancel();
  }
}
