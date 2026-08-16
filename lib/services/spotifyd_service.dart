import 'dart:io';

class SpotifydService {
  static const String _playerName = 'spotifyd';

  Future<bool> connect() async {
    try {
      final result = await _runPlayerctl(['status', '--player=$_playerName']);
      return result.exitCode == 0;
    } catch (e) {
      print('SpotifydService: Failed to connect: $e');
      return false;
    }
  }

  Future<bool> isConnected() async {
    try {
      final result = await _runPlayerctl(['status', '--player=$_playerName']);
      return result.exitCode == 0 && result.stdout.toString().isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<String> getPlayerStatus() async {
    try {
      final result = await _runPlayerctl(['status', '--player=$_playerName']);
      final output = result.stdout.toString().trim();
      if (output.contains('Playing')) return 'Playing';
      if (output.contains('Paused')) return 'Paused';
      return 'Stopped';
    } catch (e) {
      print('SpotifydService: Failed to get playback status: $e');
      return 'Stopped';
    }
  }

  Future<Map<String, dynamic>> getCurrentTrack() async {
    final track = <String, dynamic>{};

    try {
      track['title'] = await _getMetadata('title') ?? 'No track playing';
      track['artist'] = await _getMetadata('artist') ?? 'Unknown Artist';
      track['album'] = await _getMetadata('album') ?? 'Unknown Album';
      track['albumArtUrl'] = await _getMetadata('art-url') ?? '';
      track['length'] = await _getLength();
      track['uri'] = await _getMetadata('mpris:trackid') ?? '';

      final artists = await _getMetadata('artist');
      if (artists != null && artists.contains(',')) {
        track['artists'] = artists.split(',').map((a) => a.trim()).toList();
      }
    } catch (e) {
      print('SpotifydService: Failed to get current track: $e');
    }

    return track;
  }

  Future<double> getVolume() async {
    try {
      final result = await _runPlayerctl(['volume', '--player=$_playerName']);
      final output = result.stdout.toString().trim();
      if (output.isEmpty) return 0.5;
      final volume = double.tryParse(output);
      return volume ?? 0.5;
    } catch (e) {
      print('SpotifydService: Failed to get volume: $e');
      return 0.5;
    }
  }

  Future<int> getPosition() async {
    try {
      final result = await _runPlayerctl(['position', '--player=$_playerName']);
      final output = result.stdout.toString().trim();
      if (output.isEmpty) return 0;

      final parts = output.split(':');
      if (parts.length == 2) {
        final minutes = int.tryParse(parts[0]) ?? 0;
        final seconds = int.tryParse(parts[1]) ?? 0;
        return (minutes * 60 + seconds) * 1000;
      }

      return 0;
    } catch (e) {
      print('SpotifydService: Failed to get position: $e');
      return 0;
    }
  }

  Future<void> play() async {
    try {
      await _runPlayerctl(['play', '--player=$_playerName']);
    } catch (e) {
      print('SpotifydService: Failed to play: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _runPlayerctl(['pause', '--player=$_playerName']);
    } catch (e) {
      print('SpotifydService: Failed to pause: $e');
    }
  }

  Future<void> playPause() async {
    try {
      await _runPlayerctl(['play-pause', '--player=$_playerName']);
    } catch (e) {
      print('SpotifydService: Failed to play/pause: $e');
    }
  }

  Future<void> next() async {
    try {
      await _runPlayerctl(['next', '--player=$_playerName']);
    } catch (e) {
      print('SpotifydService: Failed to skip next: $e');
    }
  }

  Future<void> previous() async {
    try {
      await _runPlayerctl(['previous', '--player=$_playerName']);
    } catch (e) {
      print('SpotifydService: Failed to skip previous: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _runPlayerctl(['set-volume', '--player=$_playerName', clampedVolume.toStringAsFixed(4)]);
    } catch (e) {
      print('SpotifydService: Failed to set volume: $e');
    }
  }

  Future<void> seek(double seconds) async {
    try {
      await _runPlayerctl(['seek', '--player=$_playerName', '+${seconds.toStringAsFixed(1)}']);
    } catch (e) {
      print('SpotifydService: Failed to seek: $e');
    }
  }

  Future<String?> _getMetadata(String property) async {
    try {
      final result = await _runPlayerctl(['metadata', '-F', property, '--player=$_playerName']);
      final output = result.stdout.toString().trim();
      return output.isEmpty ? null : output;
    } catch (e) {
      return null;
    }
  }

  Future<int> _getLength() async {
    try {
      final result = await _runPlayerctl(['metadata', '-F', 'xesam:length', '--player=$_playerName']);
      final output = result.stdout.toString().trim();
      final length = double.tryParse(output);
      if (length != null) {
        return (length * 1000).round();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<ProcessResult> _runPlayerctl(List<String> arguments) async {
    return Process.run('playerctl', arguments);
  }
}
