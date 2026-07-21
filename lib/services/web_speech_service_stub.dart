import 'dart:async';

class WebSpeechService {
  bool _isListening = false;

  final StreamController<String> _transcriptionController =
      StreamController<String>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<bool> _listeningController =
      StreamController<bool>.broadcast();
  final StreamController<String> _speechController =
      StreamController<String>.broadcast();

  bool get isSupported => false;
  bool get isListening => _isListening;
  Stream<String> get transcriptionStream => _transcriptionController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<bool> get listeningStream => _listeningController.stream;
  Stream<String> get speechStream => _speechController.stream;
  Stream<bool> get isListeningStream => _listeningController.stream;

  Future<bool> initialize() async => false;

  Future<bool> testRecognition() async => false;

  Future<bool> startListening() async {
    _errorController.add('Web Speech API is not supported on this platform.');
    return false;
  }

  Future<void> stopListening() async {
    _isListening = false;
    _listeningController.add(false);
  }

  Future<bool> manualStart() async => startListening();

  Future<bool> forceRestart() async {
    await stopListening();
    return startListening();
  }

  void dispose() {
    _transcriptionController.close();
    _errorController.close();
    _listeningController.close();
    _speechController.close();
  }
}
