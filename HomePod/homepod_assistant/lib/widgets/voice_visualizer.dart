import 'package:flutter/material.dart';
import 'dart:math' as math;

class VoiceVisualizer extends StatefulWidget {
  final double volume;
  final bool isListening;
  final bool isProcessing;
  final Color color;

  const VoiceVisualizer({
    super.key,
    required this.volume,
    required this.isListening,
    this.isProcessing = false,
    this.color = const Color(0xFF1E3A8A),
  });

  @override
  State<VoiceVisualizer> createState() => _VoiceVisualizerState();
}

class _VoiceVisualizerState extends State<VoiceVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SiriVoiceVisualizerPainter(
            volume: widget.volume,
            isListening: widget.isListening,
            isProcessing: widget.isProcessing,
            t: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class SiriVoiceVisualizerPainter extends CustomPainter {
  final double volume;
  final bool isListening;
  final bool isProcessing;
  final double t;
  final Color color;

  SiriVoiceVisualizerPainter({
    required this.volume,
    required this.isListening,
    required this.isProcessing,
    required this.t,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    const blue = Color(0xFF1E3A8A);
    const orange = Color(0xFFFF6B35);

    final v = volume.clamp(0.0, 1.0);
    final breathe = 0.85 + 0.15 * math.sin(t * 2 * math.pi);

    final baseRadius = 70.0 * breathe;

    // -------------------------
    // IDLE
    // -------------------------
    if (!isListening && !isProcessing) {
      canvas.drawCircle(
        c,
        baseRadius * 0.35,
        Paint()..color = blue.withOpacity(0.15),
      );

      canvas.drawCircle(
        c,
        baseRadius * 0.35 + 6,
        Paint()
          ..color = orange.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      return;
    }

    // -------------------------
    // PROCESSING (simple rings)
    // -------------------------
    if (isProcessing) {
      for (int i = 0; i < 3; i++) {
        final p = (t + i * 0.33) % 1.0;

        canvas.drawCircle(
          c,
          baseRadius + p * 60,
          Paint()
            ..color = (i.isEven ? orange : blue).withOpacity((1 - p) * 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }
      return;
    }

    // -------------------------
    // LISTENING (SIRI BLOBS)
    // -------------------------

    final path1 = _blob(
      c,
      baseRadius + 10,
      18 + v * 25,
      t,
      5,
    );

    final path2 = _blob(
      c,
      baseRadius - 5,
      12 + v * 18,
      -t * 1.3,
      4,
    );

    canvas.drawPath(
      path1,
      Paint()
        ..color = blue.withOpacity(0.35)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path2,
      Paint()
        ..color = orange.withOpacity(0.25)
        ..style = PaintingStyle.fill,
    );

    // center core pulse
    final core = 14 + v * 14 + math.sin(t * 6.28) * 2;

    canvas.drawCircle(
      c,
      core,
      Paint()..color = blue.withOpacity(0.9),
    );
  }

  Path _blob(
    Offset c,
    double baseRadius,
    double amplitude,
    double time,
    double freq,
  ) {
    final path = Path();

    const points = 36;

    for (int i = 0; i <= points; i++) {
      final a = (i / points) * 2 * math.pi;

      final noise = math.sin(a * freq + time * 6.28) * amplitude;

      final r = baseRadius + noise;

      final x = c.dx + math.cos(a) * r;
      final y = c.dy + math.sin(a) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant SiriVoiceVisualizerPainter oldDelegate) {
    return oldDelegate.volume != volume ||
        oldDelegate.isListening != isListening ||
        oldDelegate.isProcessing != isProcessing ||
        oldDelegate.t != t;
  }
}
