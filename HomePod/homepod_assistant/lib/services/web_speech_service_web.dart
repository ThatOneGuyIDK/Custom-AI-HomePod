import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('window.SpeechRecognition')
external JSAny? get speechRecognition;

@JS('window.webkitSpeechRecognition')
external JSAny? get webkitSpeechRecognition;

JSAny? _getRecognitionCtor() {
  return speechRecognition ?? webkitSpeechRecognition;
}

class WebSpeechService {
  bool _isListening = false;
  bool _isSupported = false;
  dynamic _recognition;

  final StreamController<String> _transcriptionController =
      StreamController<String>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<bool> _listeningController =
      StreamController<bool>.broadcast();

  WebSpeechService() {
    _isSupported = _detectSupport();
  }

  bool get isSupported => _isSupported;
  bool get isListening => _isListening;
  Stream<String> get transcriptionStream => _transcriptionController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<bool> get listeningStream => _listeningController.stream;
  Stream<bool> get isListeningStream => _listeningController.stream;

  bool _detectSupport() {
    return _getRecognitionCtor() != null;
  }

  bool _wireRecognition() {
    final ctor = _getRecognitionCtor();
    if (ctor == null) return false;

    _recognition = (ctor as JSFunction).callAsConstructor();
    return true;
  }

  Future<bool> initialize() async {
    if (!_detectSupport()) {
      _errorController.add('Web Speech API not supported');
      return false;
    }

    if (!_wireRecognition()) {
      _errorController.add('Failed to initialize Web Speech API');
      return false;
    }

    _recognition!
      ..setProperty('continuous'.toJS, true.toJS)
      ..setProperty('interimResults'.toJS, true.toJS)
      ..setProperty('lang'.toJS, 'en-US'.toJS);

    _recognition!.setProperty(
      'onstart'.toJS,
      ((JSAny? _) {
        _isListening = true;
        _listeningController.add(true);
      }).toJS,
    );

    _recognition!.setProperty(
      'onend'.toJS,
      ((JSAny? _) {
        _isListening = false;
        _listeningController.add(false);
      }).toJS,
    );

    _recognition!.setProperty(
      'onresult'.toJS,
      ((JSAny event) {
        final e = event as dynamic;

        final results = e.results;
        if (results == null || results.length == 0) return;

        final lastResult = results[results.length - 1];
        final transcript = lastResult[0].transcript?.toString().trim() ?? '';

        if (transcript.isNotEmpty) {
          _transcriptionController.add(transcript);
        }
      }).toJS,
    );

    _recognition!.setProperty(
      'onerror'.toJS,
      ((JSAny event) {
        final jsEvent = event as JSObject;

        final error = jsEvent.getProperty('error'.toJS);
        _errorController.add(error.toString());
      }).toJS,
    );

    return true;
  }

  Future<bool> testRecognition() async {
    if (_recognition == null) {
      _errorController.add('Recognition not initialized');
      return false;
    }
    try {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> startListening() async {
    if (_recognition == null) {
      _errorController.add('Not initialized');
      return false;
    }

    try {
      _isListening = true;
      _listeningController.add(true);

      _recognition!.callMethod('start');

      return true;
    } catch (e) {
      _isListening = false;
      _listeningController.add(false);
      _errorController.add('Start failed: $e');
      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      _recognition?.callMethod('abort');
    } catch (_) {}

    _isListening = false;
    _listeningController.add(false);
  }

  Future<bool> manualStart() async {
    try {
      if (_recognition == null) {
        final ok = await initialize();
        if (!ok) return false;
      }

      await stopListening();
      await Future.delayed(const Duration(milliseconds: 300));

      return await startListening();
    } catch (e) {
      _errorController.add('Manual start failed: $e');
      return false;
    }
  }

  Future<bool> forceRestart() async {
    try {
      await stopListening();
      await Future.delayed(const Duration(milliseconds: 500));
      return await startListening();
    } catch (e) {
      _errorController.add('Force restart failed: $e');
      return false;
    }
  }

  void dispose() {
    stopListening();
    _transcriptionController.close();
    _errorController.close();
    _listeningController.close();
  }
}
