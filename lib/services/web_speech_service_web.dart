import 'dart:async';
import 'dart:js' as js;
import 'package:js/js.dart';

@JS()
external dynamic get window;

@JS('window.webkitSpeechRecognition')
external dynamic get WebKitSpeechRecognition;

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
  final StreamController<String> _speechController =
      StreamController<String>.broadcast();

  WebSpeechService() {
    _isSupported = _detectSupport();
  }

  bool get isSupported => _isSupported;
  bool get isListening => _isListening;
  Stream<String> get transcriptionStream => _transcriptionController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<bool> get listeningStream => _listeningController.stream;
  Stream<String> get speechStream => _speechController.stream;
  Stream<bool> get isListeningStream => _listeningController.stream;

  bool _detectSupport() {
    try {
      final ctor = _getRecognitionConstructor();
      return ctor != null && ctor != js.undefined;
    } catch (e) {
      return false;
    }
  }

  dynamic _getRecognitionConstructor() {
    try {
      // Try webkit version (Safari, Edge)
      if (WebKitSpeechRecognition != null && WebKitSpeechRecognition != js.undefined) {
        return WebKitSpeechRecognition;
      }
      // Try standard version (Chrome, Firefox)
      return js.context['SpeechRecognition'];
    } catch (e) {
      return null;
    }
  }

  bool _wireRecognition() {
    try {
      final ctor = _getRecognitionConstructor();
      if (ctor == null || ctor == js.undefined) {
        return false;
      }

      _recognition = js.JsObject.fromBrowserObject(ctor).callMethod('new', []);

      // Set up event listeners with defensive error handling
      _recognition['onstart'] = js.allowInterop(() {
        try {
          _isListening = true;
          _listeningController.add(true);
        } catch (e) {
          // Ignore errors
        }
      });

      _recognition['onend'] = js.allowInterop(() {
        try {
          _isListening = false;
          _listeningController.add(false);
        } catch (e) {
          // Ignore errors
        }
      });

      _recognition['onresult'] = js.allowInterop((dynamic event) {
        try {
          if (event != null) {
            final results = event['results'];
            if (results != null && results.length > 0) {
              final lastResult = results[results.length - 1];
              final transcript = lastResult[0]['transcript'] ?? '';
              if (transcript.isNotEmpty) {
                _transcriptionController.add(transcript);
              }
            }
          }
        } catch (e) {
          // Ignore result processing errors
        }
      });

      _recognition['onerror'] = js.allowInterop((dynamic event) {
        try {
          final error = event['error'] ?? 'unknown';
          _errorController.add(error.toString());
        } catch (e) {
          // Ignore error handling errors
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  void _handleResult(dynamic event) {
    try {
      if (event != null && event['results'] != null) {
        final results = event['results'];
        if (results.length > 0) {
          final lastResult = results[results.length - 1];
          final transcript = lastResult[0]['transcript'] ?? '';
          if (transcript.isNotEmpty) {
            _transcriptionController.add(transcript);
          }
        }
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<bool> initialize() async {
    if (!_isSupported) {
      _errorController.add('Web Speech API not supported');
      return false;
    }

    if (!_wireRecognition()) {
      _errorController.add('Failed to initialize Web Speech API');
      return false;
    }

    try {
      _recognition['continuous'] = true;
      _recognition['interimResults'] = true;
      _recognition['lang'] = 'en-US';
      return true;
    } catch (e) {
      _errorController.add('Failed to configure Web Speech API: $e');
      return false;
    }
  }

  Future<bool> testRecognition() async {
    if (_recognition == null) {
      return false;
    }
    try {
      _recognition['start']();
      await Future.delayed(const Duration(seconds: 1));
      _recognition['abort']();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> startListening() async {
    if (_recognition == null) {
      _errorController.add('Web Speech API not initialized');
      return false;
    }

    try {
      _recognition['start']();
      return true;
    } catch (e) {
      _errorController.add('Failed to start listening: $e');
      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      if (_recognition != null) {
        _recognition['abort']();
      }
    } catch (e) {
      // Ignore
    }
    _isListening = false;
    _listeningController.add(false);
  }

  Future<bool> manualStart() async => false;

  Future<bool> forceRestart() async => false;

  void dispose() {
    stopListening();
    _transcriptionController.close();
    _errorController.close();
    _listeningController.close();
    _speechController.close();
  }
}
