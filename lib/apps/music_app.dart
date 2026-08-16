import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:homepod_assistant/providers/spotifyd_provider.dart';

class MusicApp extends StatefulWidget {
  const MusicApp({super.key});

  @override
  State<MusicApp> createState() => _MusicAppState();
}

class _MusicAppState extends State<MusicApp> {
  int _currentTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSeeking = false;
  double _seekProgress = 0.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spotify = context.watch<SpotifydProvider>();

    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.greenAccent, width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.headphones,
                  color: spotify.isConnected ? Colors.greenAccent : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Spotify',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!spotify.isConnected)
                  Text(
                    'Offline',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          if (!spotify.isConnected)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      color: Colors.grey,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Spotifyd not connected',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ensure spotifyd is running',
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => spotify.reconnect(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reconnect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (spotify.isConnected) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _buildTabButton('Now Playing', 0),
                  const SizedBox(width: 8),
                  _buildTabButton('Controls', 1),
                ],
              ),
            ),

            Expanded(
              child: _buildTabContent(spotify),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.greenAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(SpotifydProvider spotify) {
    switch (_currentTabIndex) {
      case 0:
        return _buildNowPlayingTab(spotify);
      case 1:
        return _buildControlsTab(spotify);
      default:
        return _buildNowPlayingTab(spotify);
    }
  }

  Widget _buildNowPlayingTab(SpotifydProvider spotify) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildAlbumArt(spotify),

          const SizedBox(height: 20),

          Text(
            spotify.trackTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            spotify.trackArtist,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (spotify.trackAlbum.isNotEmpty && spotify.trackAlbum != 'Unknown Album') ...[
            const SizedBox(height: 4),
            Text(
              spotify.trackAlbum,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 20),

          _buildProgressBar(spotify),

          const SizedBox(height: 24),

          _buildPlaybackControls(spotify),

          const SizedBox(height: 20),

          _buildVolumeControl(spotify),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(SpotifydProvider spotify) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.greenAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: spotify.isPlaying
              ? Colors.greenAccent.withOpacity(0.6)
              : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: spotify.trackArtUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: spotify.trackArtUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: Icon(
                    Icons.music_note,
                    color: Colors.greenAccent.withOpacity(0.5),
                    size: 48,
                  ),
                ),
                errorWidget: (context, url, error) => _buildDefaultAlbumArt(spotify),
              ),
            )
          : _buildDefaultAlbumArt(spotify),
    );
  }

  Widget _buildDefaultAlbumArt(SpotifydProvider spotify) {
    return Center(
      child: Icon(
        Icons.music_note,
        color: spotify.isPlaying ? Colors.greenAccent : Colors.grey,
        size: 48,
      ),
    );
  }

  Widget _buildProgressBar(SpotifydProvider spotify) {
    final progress = _isSeeking ? _seekProgress : spotify.progress;
    final currentPosition = _formatPosition(
      (_isSeeking ? _seekProgress * spotify.trackLength : spotify.position).round(),
    );
    final total = _formatPosition(spotify.trackLength);

    return Column(
      children: [
        Slider(
          value: progress.clamp(0.0, 1.0),
          onChanged: (value) {
            setState(() {
              _isSeeking = true;
              _seekProgress = value;
            });
          },
          onChangeEnd: (value) async {
            await spotify.seek(value);
            setState(() {
              _isSeeking = false;
            });
          },
          activeColor: Colors.greenAccent,
          inactiveColor: Colors.grey.withOpacity(0.3),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currentPosition,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
            Text(
              total,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaybackControls(SpotifydProvider spotify) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: spotify.isPlaying || spotify.trackTitle != 'No track playing'
              ? () => spotify.previous()
              : null,
          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 32),
        ),
        FloatingActionButton(
          onPressed: spotify.isPlaying || spotify.trackTitle != 'No track playing'
              ? () => spotify.playPause()
              : null,
          backgroundColor: Colors.greenAccent,
          child: Icon(
            spotify.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.black,
          ),
        ),
        IconButton(
          onPressed: spotify.isPlaying
              ? () => spotify.next()
              : null,
          icon: const Icon(Icons.skip_next, color: Colors.white, size: 32),
        ),
      ],
    );
  }

  Widget _buildVolumeControl(SpotifydProvider spotify) {
    return Row(
      children: [
        Icon(
          spotify.volume < 0.3
              ? Icons.volume_mute
              : spotify.volume < 0.7
                  ? Icons.volume_down
                  : Icons.volume_up,
          color: Colors.white70,
          size: 20,
        ),
        Expanded(
          child: Slider(
            value: spotify.volume,
            onChanged: (value) => spotify.setVolume(value),
            activeColor: Colors.greenAccent,
            inactiveColor: Colors.grey.withOpacity(0.3),
          ),
        ),
        Icon(
          Icons.volume_up,
          color: Colors.white70,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildControlsTab(SpotifydProvider spotify) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Playback Status',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusRow('Status', spotify.playbackStatus),
          _buildStatusRow('Position', _formatPosition(spotify.position)),
          _buildStatusRow('Duration', _formatPosition(spotify.trackLength)),
          _buildStatusRow('Volume', '${(spotify.volume * 100).round()}%'),
          _buildStatusRow('Progress', '${(spotify.progress * 100).round()}%'),

          const SizedBox(height: 24),
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildActionButtons(spotify),

          const SizedBox(height: 24),
          _buildReconnectButton(spotify),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SpotifydProvider spotify) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Play',
                Icons.play_arrow,
                () => spotify.play(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                'Pause',
                Icons.pause,
                () => spotify.pause(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Previous',
                Icons.skip_previous,
                () => spotify.previous(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                'Next',
                Icons.skip_next,
                () => spotify.next(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildReconnectButton(SpotifydProvider spotify) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () => spotify.reconnect(),
        icon: const Icon(Icons.refresh, size: 18),
        label: const Text('Reconnect to Spotifyd'),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.greenAccent),
          foregroundColor: Colors.greenAccent,
        ),
      ),
    );
  }

  String _formatPosition(int milliseconds) {
    if (milliseconds <= 0) return '0:00';
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}
