import 'package:flutter/material.dart';
// import 'package:spotify_sdk/spotify_sdk.dart'; // Temporarily disabled for testing

class SpotifyWidget extends StatefulWidget {
  final double size;
  final Color? accentColor;
  
  const SpotifyWidget({
    super.key,
    this.size = 200,
    this.accentColor,
  });

  @override
  State<SpotifyWidget> createState() => _SpotifyWidgetState();
}

class _SpotifyWidgetState extends State<SpotifyWidget>
    with TickerProviderStateMixin {
  bool _isConnected = false;
  bool _isPlaying = false;
  String _currentTrack = 'Mock Song Title';
  String _currentArtist = 'Mock Artist';
  final String _albumArtUrl = '';
  double _progress = 0.3;
  final Duration _duration = const Duration(minutes: 3, seconds: 45);
  final Duration _position = const Duration(minutes: 1, seconds: 8);
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));
    
    _initializeSpotify();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _initializeSpotify() async {
    try {
      // Mock Spotify initialization for testing
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _isConnected = true;
      });
      
      // Start animations for demo
      _rotateController.repeat();
      _pulseController.repeat(reverse: true);
      
    } catch (e) {
      print('Failed to connect to Spotify: $e');
      setState(() {
        _isConnected = false;
      });
    }
  }

  Future<void> _playPause() async {
    if (!_isConnected) return;
    
    try {
      setState(() {
        _isPlaying = !_isPlaying;
      });
      
      if (_isPlaying) {
        _rotateController.repeat();
        _pulseController.repeat(reverse: true);
      } else {
        _rotateController.stop();
        _pulseController.stop();
      }
    } catch (e) {
      print('Failed to control playback: $e');
    }
  }

  Future<void> _skipNext() async {
    if (!_isConnected) return;
    
    try {
      // Mock next track
      setState(() {
        _currentTrack = 'Next Mock Song';
        _currentArtist = 'Next Mock Artist';
        _progress = 0.0;
      });
    } catch (e) {
      print('Failed to skip next: $e');
    }
  }

  Future<void> _skipPrevious() async {
    if (!_isConnected) return;
    
    try {
      // Mock previous track
      setState(() {
        _currentTrack = 'Previous Mock Song';
        _currentArtist = 'Previous Mock Artist';
        _progress = 0.0;
      });
    } catch (e) {
      print('Failed to skip previous: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return _buildNotConnectedWidget();
    }

    if (_currentTrack.isEmpty) {
      return _buildNoTrackWidget();
    }

    return _buildMusicPlayerWidget();
  }

  Widget _buildNotConnectedWidget() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withOpacity(0.1),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              color: Colors.grey,
              size: widget.size * 0.2,
            ),
            const SizedBox(height: 8),
            Text(
              'Spotify Not Connected',
              style: TextStyle(
                color: Colors.grey,
                fontSize: widget.size * 0.08,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to connect',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.7),
                fontSize: widget.size * 0.06,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTrackWidget() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green.withOpacity(0.1),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              color: Colors.green,
              size: widget.size * 0.2,
            ),
            const SizedBox(height: 8),
            Text(
              'No Track Playing',
              style: TextStyle(
                color: Colors.green,
                fontSize: widget.size * 0.08,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Start music on Spotify',
              style: TextStyle(
                color: Colors.green.withOpacity(0.7),
                fontSize: widget.size * 0.06,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicPlayerWidget() {
    final accentColor = widget.accentColor ?? Colors.green;
    
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            accentColor.withOpacity(0.2),
            accentColor.withOpacity(0.1),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        border: Border.all(
          color: accentColor.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Album art background (rotating when playing)
          Positioned(
            top: widget.size * 0.1,
            left: widget.size * 0.1,
            right: widget.size * 0.1,
            child: AnimatedBuilder(
              animation: _rotateAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateAnimation.value * 2 * 3.14159,
                  child: Container(
                    width: widget.size * 0.8,
                    height: widget.size * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.3),
                      image: _albumArtUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(_albumArtUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _albumArtUrl.isEmpty
                        ? Icon(
                            Icons.music_note,
                            color: accentColor,
                            size: widget.size * 0.3,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          
          // Track info overlay
          Positioned(
            bottom: widget.size * 0.25,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentTrack,
                    style: TextStyle(
                      fontSize: widget.size * 0.08,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _currentArtist,
                    style: TextStyle(
                      fontSize: widget.size * 0.06,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          
          // Progress ring
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(
              painter: ProgressRingPainter(
                progress: _progress,
                color: accentColor,
                strokeWidth: 4,
              ),
            ),
          ),
          
          // Play/Pause button
          Positioned(
            top: widget.size * 0.35,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _playPause,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: widget.size * 0.15,
                        height: widget.size * 0.15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor,
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: widget.size * 0.08,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Skip buttons
          Positioned(
            top: widget.size * 0.25,
            left: widget.size * 0.1,
            child: GestureDetector(
              onTap: _skipPrevious,
              child: Container(
                width: widget.size * 0.12,
                height: widget.size * 0.12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.8),
                ),
                child: Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                  size: widget.size * 0.06,
                ),
              ),
            ),
          ),
          
          Positioned(
            top: widget.size * 0.25,
            right: widget.size * 0.1,
            child: GestureDetector(
              onTap: _skipNext,
              child: Container(
                width: widget.size * 0.12,
                height: widget.size * 0.12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.8),
                ),
                child: Icon(
                  Icons.skip_next,
                  color: Colors.white,
                  size: widget.size * 0.06,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -90 * 3.14159 / 180, // Start from top
      progress * 2 * 3.14159, // Progress in radians
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 