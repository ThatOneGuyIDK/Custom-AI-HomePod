import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assistant_state.dart';
import '../widgets/clock_widget.dart';
import '../widgets/app_icon_ring.dart';
import '../widgets/voice_visualizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _showDebugPanel = true; // Set to true to see debug info

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2E), // Dark gray background
      body: Consumer<AssistantState>(
        builder: (context, assistantState, child) {
          if (assistantState.status == AssistantStatus.listening) {
            _pulseController.repeat(reverse: true);
          } else {
            _pulseController.stop();
            _pulseController.reset();
          }

          return SafeArea(
            child: Center(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    // Background gradient
                    Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.0,
                          colors: [
                            Color(0xFF3A3A3C), // Lighter gray
                            Color(0xFF2C2C2E), // Dark gray
                          ],
                        ),
                      ),
                    ),
                    
                    // Main content - Clock in center with app ring around it
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Circular Voice Visualizer (behind everything)
                          VoiceVisualizer(
                            volume: assistantState.currentVolume,
                            isListening: assistantState.isListening,
                            isProcessing: assistantState.status == AssistantStatus.processing,
                            color: Colors.blue,
                          ),
                          
                          // App Icon Ring (larger, behind clock)
                          const AppIconRing(),
                          
                          // Clock Widget in center (on top)
                          const ClockWidget(),
                          
                          // Invisible button over clock for voice activation
                          GestureDetector(
                            onTap: () async {
                              if (assistantState.status == AssistantStatus.idle) {
                                await assistantState.startListening();
                              } else {
                                await assistantState.stopListening();
                              }
                            },
                            child: Container(
                              width: 200, // Large enough to cover clock
                              height: 200,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent, // Completely transparent
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Speech text display (bottom)
                    if (assistantState.lastQuery.isNotEmpty || assistantState.lastResponse.isNotEmpty)
                      Positioned(
                        bottom: 40,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (assistantState.lastQuery.isNotEmpty)
                                Text(
                                  'You: ${assistantState.lastQuery}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              if (assistantState.lastResponse.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Assistant: ${assistantState.lastResponse}',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    
                    // Comprehensive Debug Panel (top left)
                    if (_showDebugPanel)
                      Positioned(
                        top: 40,
                        left: 40,
                        child: Container(
                          width: 320,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '🔧 DEBUG PANEL',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showDebugPanel = false;
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Status: ${assistantState.isListening ? "Listening" : "Idle"}'),
                              Text('Listening: ${assistantState.isListening ? "✅ YES" : "❌ NO"}'),
                              Text('Volume: ${(assistantState.currentVolume * 100).toStringAsFixed(1)}%'),
                              Text('Last Query: ${assistantState.lastQuery.isEmpty ? "None" : assistantState.lastQuery}'),
                              Text('Last Response: ${assistantState.lastResponse.isEmpty ? "None" : assistantState.lastResponse}'),
                              if (assistantState.currentTranscription.isNotEmpty)
                                Text(
                                  'Live: "${assistantState.currentTranscription}"',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 