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
    this.color = const Color(0xFF1E3A8A), // Navy blue instead of blue
  });

  @override
  State<VoiceVisualizer> createState() => _VoiceVisualizerState();
}

class _VoiceVisualizerState extends State<VoiceVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(VoiceVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.isListening || widget.isProcessing) && 
        !(oldWidget.isListening || oldWidget.isProcessing)) {
      _animationController.repeat();
      _pulseController.repeat(reverse: true);
    } else if (!(widget.isListening || widget.isProcessing) && 
               (oldWidget.isListening || oldWidget.isProcessing)) {
      _animationController.stop();
      _pulseController.stop();
      _animationController.reset();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animation, _pulseAnimation]),
      builder: (context, child) {
        return CustomPaint(
          size: const Size(500, 500),
          painter: SiriVoiceVisualizerPainter(
            volume: widget.volume,
            isListening: widget.isListening,
            isProcessing: widget.isProcessing,
            animationValue: _animation.value,
            pulseValue: _pulseAnimation.value,
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
  final double animationValue;
  final double pulseValue;
  final Color color;

  SiriVoiceVisualizerPainter({
    required this.volume,
    required this.isListening,
    required this.isProcessing,
    required this.animationValue,
    required this.pulseValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Define navy and orange colors
    const navyColor = Color(0xFF1E3A8A); // Deep navy blue
    const orangeColor = Color(0xFFFF6B35); // Vibrant orange
    
    // Base radius for the visualizer
    const baseRadius = 80.0;
    
    if (isProcessing) {
      // Draw pulsing circle animation for AI thinking
      const numRings = 5;
      for (int i = 0; i < numRings; i++) {
        final ringProgress = (animationValue + (i * 0.2)) % 1.0;
        final ringRadius = baseRadius + (ringProgress * 60.0);
        final opacity = (1.0 - ringProgress) * 0.6;
        
        // Use purple/orange color for processing
        final ringColor = i % 2 == 0 
            ? const Color(0xFF9333EA).withOpacity(opacity) // Purple
            : orangeColor.withOpacity(opacity);
        
        final ringPaint = Paint()
          ..color = ringColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;
        
        canvas.drawCircle(center, ringRadius, ringPaint);
      }
      
      // Draw pulsing center dot
      final centerPulse = 0.8 + (pulseValue * 0.4);
      final centerPaint = Paint()
        ..color = const Color(0xFF9333EA).withOpacity(0.8)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(center, 15.0 * centerPulse, centerPaint);
      
    } else if (isListening) {
      // Draw Siri-style wavy pulsing waves with radius fluctuation
      const numWaves = 6;
      for (int i = 0; i < numWaves; i++) {
        final waveProgress = (animationValue + (i * 0.15)) % 1.0;
        
        // Calculate radius fluctuation based on volume and animation
        final radiusFluctuation = math.sin(waveProgress * 2 * math.pi) * (20.0 + volume * 30.0);
        final baseWaveRadius = baseRadius + (i * 15.0) + radiusFluctuation; // Fluctuating radius
        
        // Calculate opacity based on wave progress and volume
        final opacity = (1.0 - waveProgress) * (0.4 + volume * 0.3);
        
        // Calculate wave thickness based on volume
        final waveThickness = 3.0 + (volume * 8.0); // Thicker waves when louder
        
        // Alternate between navy and orange for waves
        final waveColor = i % 2 == 0 ? navyColor : orangeColor;
        
        // Draw wavy circle with depth
        final wavePath = Path();
        bool firstPoint = true;
        
        // Create wavy circle with multiple frequency components for depth
        for (int j = 0; j <= 360; j += 2) {
          final angle = j * math.pi / 180;
          
          // Multiple wave frequencies for depth effect
          final wave1 = 15.0 * math.sin(angle * 3 + animationValue * 2 * math.pi);
          final wave2 = 8.0 * math.sin(angle * 7 + animationValue * 3 * math.pi);
          final wave3 = 5.0 * math.sin(angle * 12 + animationValue * 1.5 * math.pi);
          
          // Combine waves and scale by volume
          final waveOffset = (wave1 + wave2 + wave3) * (0.5 + volume * 0.5);
          final radius = baseWaveRadius + waveOffset;
          
          final x = center.dx + radius * math.cos(angle);
          final y = center.dy + radius * math.sin(angle);
          
          if (firstPoint) {
            wavePath.moveTo(x, y);
            firstPoint = false;
          } else {
            wavePath.lineTo(x, y);
          }
        }
        wavePath.close();
        
        // Draw the wavy wave with thickness
        final wavePaint = Paint()
          ..color = waveColor.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = waveThickness
          ..strokeCap = StrokeCap.round;

        canvas.drawPath(wavePath, wavePaint);
        
        // Draw inner glow for depth effect
        final glowPath = Path();
        firstPoint = true;
        
        for (int j = 0; j <= 360; j += 2) {
          final angle = j * math.pi / 180;
          
          final wave1 = 12.0 * math.sin(angle * 3 + animationValue * 2 * math.pi);
          final wave2 = 6.0 * math.sin(angle * 7 + animationValue * 3 * math.pi);
          final wave3 = 4.0 * math.sin(angle * 12 + animationValue * 1.5 * math.pi);
          
          final waveOffset = (wave1 + wave2 + wave3) * (0.5 + volume * 0.5);
          final radius = baseWaveRadius + waveOffset - waveThickness * 0.5;
          
          final x = center.dx + radius * math.cos(angle);
          final y = center.dy + radius * math.sin(angle);
          
          if (firstPoint) {
            glowPath.moveTo(x, y);
            firstPoint = false;
          } else {
            glowPath.lineTo(x, y);
          }
        }
        glowPath.close();
        
        final glowPaint = Paint()
          ..color = waveColor.withOpacity(opacity * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

        canvas.drawPath(glowPath, glowPaint);
      }
      
      // Draw central pulsing circle (Siri's core) with wavy edge - Navy
      final coreRadius = baseRadius * (0.2 + pulseValue * 0.3);
      final corePath = Path();
      bool firstPoint = true;
      
      for (int j = 0; j <= 360; j += 3) {
        final angle = j * math.pi / 180;
        final waveOffset = 3.0 * math.sin(angle * 8 + animationValue * 2 * math.pi) * (0.5 + volume * 0.5);
        final radius = coreRadius + waveOffset;
        
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        
        if (firstPoint) {
          corePath.moveTo(x, y);
          firstPoint = false;
        } else {
          corePath.lineTo(x, y);
        }
      }
      corePath.close();
      
      final corePaint = Paint()
        ..color = navyColor.withOpacity(0.9)
        ..style = PaintingStyle.fill;
      
      canvas.drawPath(corePath, corePaint);
      
      // Draw inner glow effect with wavy edge - Orange glow
      final glowRadius = coreRadius + 5.0;
      final glowPath2 = Path();
      firstPoint = true;
      
      for (int j = 0; j <= 360; j += 3) {
        final angle = j * math.pi / 180;
        final waveOffset = 4.0 * math.sin(angle * 8 + animationValue * 2 * math.pi) * (0.5 + volume * 0.5);
        final radius = glowRadius + waveOffset;
        
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        
        if (firstPoint) {
          glowPath2.moveTo(x, y);
          firstPoint = false;
        } else {
          glowPath2.lineTo(x, y);
        }
      }
      glowPath2.close();
      
      final glowPaint2 = Paint()
        ..color = orangeColor.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawPath(glowPath2, glowPaint2);
      
      // Draw volume-responsive outer ring with wavy edge - Navy
      final outerRingRadius = baseRadius + 60.0 + (volume * 30.0);
      final outerPath = Path();
      firstPoint = true;
      
      for (int j = 0; j <= 360; j += 2) {
        final angle = j * math.pi / 180;
        final waveOffset = 10.0 * math.sin(angle * 5 + animationValue * 2 * math.pi) * (0.5 + volume * 0.5);
        final radius = outerRingRadius + waveOffset;
        
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        
        if (firstPoint) {
          outerPath.moveTo(x, y);
          firstPoint = false;
        } else {
          outerPath.lineTo(x, y);
        }
      }
      outerPath.close();
      
      final outerRingPaint = Paint()
        ..color = navyColor.withOpacity(0.2 + volume * 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 + (volume * 3.0); // Thicker when louder
      
      canvas.drawPath(outerPath, outerRingPaint);
      
      // Draw subtle dots around the outer ring (Siri's characteristic dots) - Orange
      const numDots = 12;
      for (int i = 0; i < numDots; i++) {
        final angle = (i * 2 * math.pi / numDots) + (animationValue * 2 * math.pi * 0.5);
        final dotRadius = outerRingRadius + 15.0;
        final x = center.dx + dotRadius * math.cos(angle);
        final y = center.dy + dotRadius * math.sin(angle);
        
        final dotOpacity = 0.4 * (0.5 + volume * 0.5);
        final dotPaint = Paint()
          ..color = orangeColor.withOpacity(dotOpacity)
          ..style = PaintingStyle.fill;
        
        final dotSize = 2.0 + (volume * 3.0); // Larger dots when louder
        canvas.drawCircle(Offset(x, y), dotSize, dotPaint);
      }
      
      // Draw enhanced smooth wave effect (Siri's signature wave) - Navy
      final waveAmplitude = 20.0 + (volume * 15.0); // More amplitude when louder
      const waveFrequency = 8.0;
      const waveRadius2 = baseRadius + 40.0;
      
      final wavePath2 = Path();
      firstPoint = true;
      
      for (int i = 0; i <= 360; i += 3) {
        final angle = i * math.pi / 180;
        final waveOffset = waveAmplitude * math.sin(angle * waveFrequency + animationValue * 2 * math.pi);
        final radius = waveRadius2 + waveOffset;
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        
        if (firstPoint) {
          wavePath2.moveTo(x, y);
          firstPoint = false;
        } else {
          wavePath2.lineTo(x, y);
        }
      }
      wavePath2.close();
      
      final wavePathPaint = Paint()
        ..color = navyColor.withOpacity(0.3 + volume * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 + (volume * 4.0); // Thicker when louder
      
      canvas.drawPath(wavePath2, wavePathPaint);
      
    } else {
      // Idle state - subtle Siri-style indicator with wavy edge - Navy
      const idleRadius = baseRadius * 0.3;
      final idlePath = Path();
      bool firstPoint = true;
      
      for (int j = 0; j <= 360; j += 5) {
        final angle = j * math.pi / 180;
        final waveOffset = 2.0 * math.sin(angle * 6 + pulseValue * 2 * math.pi);
        final radius = idleRadius + waveOffset;
        
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        
        if (firstPoint) {
          idlePath.moveTo(x, y);
          firstPoint = false;
        } else {
          idlePath.lineTo(x, y);
        }
      }
      idlePath.close();
      
      final idlePaint = Paint()
        ..color = navyColor.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawPath(idlePath, idlePaint);
      
      // Subtle pulsing core with wavy edge - Orange
      final coreRadius = idleRadius * 0.6 * (0.7 + pulseValue * 0.3);
      final corePath2 = Path();
      firstPoint = true;
      
      for (int j = 0; j <= 360; j += 5) {
        final angle = j * math.pi / 180;
        final waveOffset = 1.5 * math.sin(angle * 6 + pulseValue * 2 * math.pi);
        final radius = coreRadius + waveOffset;
        
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        
        if (firstPoint) {
          corePath2.moveTo(x, y);
          firstPoint = false;
        } else {
          corePath2.lineTo(x, y);
        }
      }
      corePath2.close();
      
      final corePaint2 = Paint()
        ..color = orangeColor.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      
      canvas.drawPath(corePath2, corePaint2);
      
      // Very subtle outer ring with wavy edge - Navy
      final outerRadius = idleRadius + 10.0;
      final outerPath2 = Path();
      firstPoint = true;
      
      for (int j = 0; j <= 360; j += 5) {
        final angle = j * math.pi / 180;
        final waveOffset = 1.0 * math.sin(angle * 6 + pulseValue * 2 * math.pi);
        final radius = outerRadius + waveOffset;
        
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        
        if (firstPoint) {
          outerPath2.moveTo(x, y);
          firstPoint = false;
        } else {
          outerPath2.lineTo(x, y);
        }
      }
      outerPath2.close();
      
      final outerPaint = Paint()
        ..color = navyColor.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      canvas.drawPath(outerPath2, outerPaint);
    }
  }

  @override
  bool shouldRepaint(SiriVoiceVisualizerPainter oldDelegate) {
    return oldDelegate.volume != volume ||
           oldDelegate.isListening != isListening ||
           oldDelegate.animationValue != animationValue ||
           oldDelegate.pulseValue != pulseValue ||
           oldDelegate.color != color;
  }
} 