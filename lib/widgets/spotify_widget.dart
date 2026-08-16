import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:homepod_assistant/providers/spotifyd_provider.dart';

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spotify = context.watch<SpotifydProvider>();

    if (!spotify.isConnected) {
      return _buildNotConnectedWidget();
    }

    if (spotify.trackTitle == 'No track playing' || spotify.trackTitle.isEmpty) {
      return _buildNoTrackWidget();
    }

    return _buildMusicPlayerWidget(spotify);
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
              Icons.cloud_off,
              color: Colors.grey,
              size: widget.size * 0.2,
            ),
            const SizedBox(height: 8),
            Text(
              'Spotifyd Offline',
              style: TextStyle(
                color: Colors.grey,
                fontSize: widget.size * 0.07,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
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
        color: Colors.greenAccent.withOpacity(0.1),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              color: Colors.greenAccent,
              size: widget.size * 0.2,
            ),
            const SizedBox(height: 8),
            Text(
              'No Track Playing',
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: widget.size * 0.07,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicPlayerWidget(SpotifydProvider spotify) {
    final accentColor = widget.accentColor ?? Colors.greenAccent;

    if (spotify.isPlaying && !_rotateController.isAnimating) {
      _rotateController.repeat();
      _pulseController.repeat(reverse: true);
    } else if (!spotify.isPlaying && _rotateController.isAnimating) {
      _rotateController.stop();
      _pulseController.stop();
    }

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
          Positioned(
            top: widget.size * 0.1,
            left: widget.size * 0.1,
            right: widget.size * 0.1,
            child: AnimatedBuilder(
              animation: _rotateAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateAnimation.value * 2 * 3.14159,
                  child: _buildAlbumArtCircle(spotify, accentColor),
                );
              },
            ),
          ),

          Positioned(
            bottom: widget.size * 0.25,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    spotify.trackTitle,
                    style: TextStyle(
                      fontSize: widget.size * 0.07,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    spotify.trackArtist,
                    style: TextStyle(
                      fontSize: widget.size * 0.05,
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

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(
              painter: ProgressRingPainter(
                progress: spotify.progress,
                color: accentColor,
                strokeWidth: 4,
              ),
            ),
          ),

          Positioned(
            top: widget.size * 0.35,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => spotify.playPause(),
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
                          spotify.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                          size: widget.size * 0.08,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          Positioned(
            top: widget.size * 0.25,
            left: widget.size * 0.1,
            child: GestureDetector(
              onTap: () => spotify.previous(),
              child: Container(
                width: widget.size * 0.12,
                height: widget.size * 0.12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.8),
                ),
                child: Icon(
                  Icons.skip_previous,
                  color: Colors.black,
                  size: widget.size * 0.06,
                ),
              ),
            ),
          ),

          Positioned(
            top: widget.size * 0.25,
            right: widget.size * 0.1,
            child: GestureDetector(
              onTap: () => spotify.next(),
              child: Container(
                width: widget.size * 0.12,
                height: widget.size * 0.12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withOpacity(0.8),
                ),
                child: Icon(
                  Icons.skip_next,
                  color: Colors.black,
                  size: widget.size * 0.06,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArtCircle(SpotifydProvider spotify, Color accentColor) {
    final size = widget.size * 0.8;

    if (spotify.trackArtUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          imageUrl: spotify.trackArtUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: accentColor.withOpacity(0.3),
            child: Center(
              child: Icon(
                Icons.music_note,
                color: accentColor,
                size: size * 0.3,
              ),
            ),
          ),
          errorWidget: (context, url, error) => _buildDefaultArt(size, accentColor),
        ),
      );
    }

    return _buildDefaultArt(size, accentColor);
  }

  Widget _buildDefaultArt(double size, Color accentColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accentColor.withOpacity(0.3),
      ),
      child: Center(
        child: Icon(
          Icons.music_note,
          color: accentColor,
          size: size * 0.3,
        ),
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

    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -90 * 3.14159 / 180,
      progress * 2 * 3.14159,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
