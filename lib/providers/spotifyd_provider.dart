import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:homepod_assistant/services/spotifyd_service.dart';
import 'package:homepod_assistant/config/app_config.dart';

class SpotifydProvider extends ChangeNotifier {
  final SpotifydService _service;

  bool _isConnected = false;
  bool _isLoading = false;
  String _error = '';

  String _playbackStatus = 'Stopped';
  Map<String, dynamic> _currentTrack = {};
  double _volume = 0.5;
  int _position = 0;
  int _trackLength = 0;

  Timer? _pollTimer;

  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get playbackStatus => _playbackStatus;
  Map<String, dynamic> get currentTrack => _currentTrack;
  double get volume => _volume;
  int get position => _position;
  int get trackLength => _trackLength;
  bool get isPlaying => _playbackStatus == 'Playing';
  double get progress => _trackLength > 0 ? _position / _trackLength : 0.0;
  String get trackTitle => _currentTrack['title'] ?? 'No track playing';
  String get trackArtist => _currentTrack['artist'] ?? '';
  String get trackAlbum => _currentTrack['album'] ?? '';
  String get trackArtUrl => _currentTrack['albumArtUrl'] ?? '';

  SpotifydProvider({SpotifydService? service})
      : _service = service ?? SpotifydService() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final connected = await _service.connect();
      _isConnected = connected;
      _error = connected ? '' : 'Failed to connect to spotifyd. Ensure it is running.';
      _isLoading = false;

      if (connected) {
        await _refreshState();
        _startPolling();
      }
      notifyListeners();
    } catch (e) {
      _error = 'Connection error: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(AppConfig.spotifydPollInterval, (_) {
      _refreshState();
    });
  }

  Future<void> _refreshState() async {
    if (!_isConnected) return;

    try {
      final status = await _service.getPlayerStatus();
      final track = await _service.getCurrentTrack();
      final vol = await _service.getVolume();
      final pos = await _service.getPosition();

      final changed = status != _playbackStatus ||
          track['title'] != _currentTrack['title'] ||
          (vol - _volume).abs() > 0.01;

      _playbackStatus = status;
      _currentTrack = track;
      _volume = vol;
      _position = pos;
      _trackLength = (track['length'] as int?) ?? 0;

      if (changed) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('SpotifydProvider: Poll error: $e');
    }
  }

  Future<void> reconnect() async {
    _stopPolling();
    _isConnected = false;
    notifyListeners();
    await _initialize();
  }

  Future<void> playPause() async {
    try {
      await _service.playPause();
      await _refreshState();
    } catch (e) {
      _error = 'Play/Pause failed: $e';
      notifyListeners();
    }
  }

  Future<void> play() async {
    try {
      await _service.play();
      await _refreshState();
    } catch (e) {
      _error = 'Play failed: $e';
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await _service.pause();
      await _refreshState();
    } catch (e) {
      _error = 'Pause failed: $e';
      notifyListeners();
    }
  }

  Future<void> next() async {
    try {
      await _service.next();
      await _refreshState();
    } catch (e) {
      _error = 'Next failed: $e';
      notifyListeners();
    }
  }

  Future<void> previous() async {
    try {
      await _service.previous();
      await _refreshState();
    } catch (e) {
      _error = 'Previous failed: $e';
      notifyListeners();
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _service.setVolume(volume);
      _volume = volume;
      notifyListeners();
    } catch (e) {
      _error = 'Volume change failed: $e';
      notifyListeners();
    }
  }

  Future<void> seek(double progress) async {
    try {
      final seconds = (_trackLength / 1000 * progress);
      await _service.seek(seconds);
      await _refreshState();
    } catch (e) {
      _error = 'Seek failed: $e';
      notifyListeners();
    }
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
