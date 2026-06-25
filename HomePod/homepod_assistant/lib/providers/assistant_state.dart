import 'package:flutter/foundation.dart';
import 'package:homepod_assistant/services/voice_assistant_service.dart';

enum AssistantStatus {
  idle,
  listening,
  processing,
  speaking,
  error,
}

class AssistantState extends ChangeNotifier {
  final VoiceAssistantService _voiceService = VoiceAssistantService();
  
  AssistantStatus _status = AssistantStatus.idle;
  bool _isListening = false;
  double _currentVolume = 0.0;
  String _lastQuery = '';
  String _lastResponse = '';
  String _currentTranscription = '';
  final List<String> _debugLogs = [];

  AssistantState() {
    _initializeVoiceService();
  }

  // Getters
  AssistantStatus get status => _status;
  bool get isListening => _isListening;
  double get currentVolume => _currentVolume;
  String get lastQuery => _lastQuery;
  String get lastResponse => _lastResponse;
  /// Get current transcription
  String get currentTranscription => _currentTranscription;
  
  /// Get debug logs
  List<String> get debugLogs => _debugLogs;
  
  /// Get voice service for testing
  VoiceAssistantService get voiceService => _voiceService;

  void _initializeVoiceService() {
    // Listen to voice service streams
    _voiceService.speechStream.listen((speech) {
      _lastQuery = speech;
      _status = AssistantStatus.processing;
      notifyListeners();
    });

    _voiceService.responseStream.listen((response) {
      _lastResponse = response;
      _status = _isListening ? AssistantStatus.listening : AssistantStatus.idle;
      notifyListeners();
    });

    _voiceService.volumeStream.listen((volume) {
      _currentVolume = volume;
      notifyListeners();
    });

    _voiceService.isListeningStream.listen((listening) {
      _isListening = listening;
      _status = listening ? AssistantStatus.listening : AssistantStatus.idle;
      notifyListeners();
    });

    // Listen to transcription stream for real-time display
    _voiceService.transcriptionStream.listen((transcription) {
      _currentTranscription = transcription;
      notifyListeners();
    });

    // Listen to debug stream
    _voiceService.debugStream.listen((debugMessage) {
      _debugLogs.add(debugMessage);
      if (_debugLogs.length > 20) {
        _debugLogs.removeAt(0);
      }
      notifyListeners();
    });
  }

  Future<void> startListening() async {
    try {
      await _voiceService.startListening();
    } catch (e) {
      _status = AssistantStatus.error;
      _debugLogs.add("❌ Error starting listening: $e");
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    try {
      await _voiceService.stopListening();
    } catch (e) {
      _status = AssistantStatus.error;
      _debugLogs.add("❌ Error stopping listening: $e");
      notifyListeners();
    }
  }

    Future<void> stopSpeaking() async {
      try {
        await _voiceService.stopSpeaking();
      } catch (e) {
        _status = AssistantStatus.error;
        _debugLogs.add("❌ Error stopping speaking: $e");
        notifyListeners();
      }
    }
  void setWakeWord(String wakeWord) {
    _voiceService.setWakeWord(wakeWord);
  }

  void setStopKeyword(String stopKeyword) {
    _voiceService.setStopKeyword(stopKeyword);
  }

  void setAIModelUrl(String url) {
    _voiceService.setAIModelUrl(url);
  }

  void setAssistantPrompt(String prompt) {
    _voiceService.setAssistantPrompt(prompt);
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
} 