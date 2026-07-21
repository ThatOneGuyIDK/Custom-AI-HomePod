import 'package:flutter/material.dart';

class MusicApp extends StatefulWidget {
  const MusicApp({super.key});

  @override
  State<MusicApp> createState() => _MusicAppState();
}

class _MusicAppState extends State<MusicApp> {
  bool _isPlaying = false;
  String _currentTrack = "No track playing";
  String _currentArtist = "";
  final String _albumArtUrl = "";
  double _progress = 0.0;
  double _volume = 0.7;
  final String _searchQuery = "";
  List<Playlist> _playlists = [];
  List<Song> _recentSongs = [];
  List<Song> _searchResults = [];
  bool _isSearching = false;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeMusic();
  }

  void _initializeMusic() {
    _playlists = [
      Playlist("Liked Songs", "❤️", 127, Colors.red),
      Playlist("Recently Added", "🕒", 45, Colors.blue),
      Playlist("Chill Vibes", "😌", 23, Colors.green),
      Playlist("Workout Mix", "💪", 67, Colors.orange),
      Playlist("Party Time", "🎉", 89, Colors.purple),
    ];

    _recentSongs = [
      Song("Blinding Lights", "The Weeknd", "After Hours", "🎵", "3:20"),
      Song("Shape of You", "Ed Sheeran", "÷", "🎵", "3:53"),
      Song("Dance Monkey", "Tones and I", "The Kids Are Coming", "🎵", "3:29"),
      Song("Uptown Funk", "Mark Ronson ft. Bruno Mars", "Uptown Special", "🎵", "4:29"),
      Song("Despacito", "Luis Fonsi ft. Daddy Yankee", "Vida", "🎵", "4:41"),
    ];

    _searchResults = [];
  }

  void _searchMusic(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      // Simulate search results
      _searchResults = _recentSongs
          .where((song) =>
              song.title.toLowerCase().contains(query.toLowerCase()) ||
              song.artist.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _playSong(Song song) {
    setState(() {
      _currentTrack = song.title;
      _currentArtist = song.artist;
      _isPlaying = true;
      _progress = 0.0;
    });
    
    // Simulate progress
    _startProgressSimulation();
  }

  void _startProgressSimulation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _isPlaying && _progress < 1.0) {
        setState(() {
          _progress += 0.01;
        });
        _startProgressSimulation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple, width: 2),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.music_note, color: Colors.purple, size: 32),
                SizedBox(width: 12),
                Text(
                  'Music Player',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _buildTabButton('Now Playing', 0),
                const SizedBox(width: 8),
                _buildTabButton('Playlists', 1),
                const SizedBox(width: 8),
                _buildTabButton('Search', 2),
              ],
            ),
          ),
          
          // Content based on selected tab
          Expanded(
            child: _buildTabContent(),
          ),
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
            color: isSelected ? Colors.purple : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTabIndex) {
      case 0:
        return _buildNowPlayingTab();
      case 1:
        return _buildPlaylistsTab();
      case 2:
        return _buildSearchTab();
      default:
        return _buildNowPlayingTab();
    }
  }

  Widget _buildNowPlayingTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Album Art
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.3),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: Colors.purple, width: 2),
            ),
            child: const Icon(
              Icons.music_note,
              color: Colors.purple,
              size: 60,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Track Info
          Text(
            _currentTrack,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            _currentArtist,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Progress Bar
          Slider(
            value: _progress,
            onChanged: (value) {
              setState(() {
                _progress = value;
              });
            },
            activeColor: Colors.purple,
            inactiveColor: Colors.grey.withOpacity(0.3),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(_progress * 3.45).toStringAsFixed(0)}:${((_progress * 3.45 % 1) * 60).toStringAsFixed(0).padLeft(2, '0')}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              Text(
                '3:45',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  // Simulate previous track
                  if (_recentSongs.isNotEmpty) {
                    final currentIndex = _recentSongs.indexWhere((song) => song.title == _currentTrack);
                    final previousIndex = currentIndex > 0 ? currentIndex - 1 : _recentSongs.length - 1;
                    _playSong(_recentSongs[previousIndex]);
                  }
                },
                icon: const Icon(Icons.skip_previous, color: Colors.white, size: 32),
              ),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                  if (_isPlaying) {
                    _startProgressSimulation();
                  }
                },
                backgroundColor: Colors.purple,
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Simulate next track
                  if (_recentSongs.isNotEmpty) {
                    final currentIndex = _recentSongs.indexWhere((song) => song.title == _currentTrack);
                    final nextIndex = currentIndex < _recentSongs.length - 1 ? currentIndex + 1 : 0;
                    _playSong(_recentSongs[nextIndex]);
                  }
                },
                icon: const Icon(Icons.skip_next, color: Colors.white, size: 32),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Volume Control
          Row(
            children: [
              const Icon(Icons.volume_down, color: Colors.white, size: 20),
              Expanded(
                child: Slider(
                  value: _volume,
                  onChanged: (value) {
                    setState(() {
                      _volume = value;
                    });
                  },
                  activeColor: Colors.purple,
                  inactiveColor: Colors.grey.withOpacity(0.3),
                ),
              ),
              const Icon(Icons.volume_up, color: Colors.white, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _playlists.length,
      itemBuilder: (context, index) {
        final playlist = _playlists[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: playlist.color.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Text(
                playlist.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${playlist.songCount} songs',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // Show playlist contents
                  _showPlaylistContents(playlist);
                },
                icon: Icon(Icons.play_arrow, color: playlist.color, size: 24),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: _searchMusic,
            decoration: InputDecoration(
              hintText: 'Search for songs, artists...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: Colors.purple),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.purple, width: 2),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          
          const SizedBox(height: 20),
          
          // Search Results
          if (_isSearching && _searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final song = _searchResults[index];
                  return _buildSongTile(song);
                },
              ),
            )
          else if (_isSearching && _searchResults.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No results found',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Songs',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _recentSongs.length,
                      itemBuilder: (context, index) {
                        final song = _recentSongs[index];
                        return _buildSongTile(song);
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSongTile(Song song) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            song.icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  song.artist,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            song.duration,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _playSong(song),
            icon: const Icon(Icons.play_arrow, color: Colors.purple, size: 20),
          ),
        ],
      ),
    );
  }

  void _showPlaylistContents(Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 280,
          height: 350,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: playlist.color, width: 2),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: playlist.color.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      playlist.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${playlist.songCount} songs',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _recentSongs.length,
                  itemBuilder: (context, index) {
                    final song = _recentSongs[index];
                    return _buildSongTile(song);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Playlist {
  final String name;
  final String icon;
  final int songCount;
  final Color color;

  Playlist(this.name, this.icon, this.songCount, this.color);
}

class Song {
  final String title;
  final String artist;
  final String album;
  final String icon;
  final String duration;

  Song(this.title, this.artist, this.album, this.icon, this.duration);
} 