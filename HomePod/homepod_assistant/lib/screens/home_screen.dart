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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _showDebugPanel = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2E),
      body: Consumer<AssistantState>(
        builder: (context, assistantState, child) {
          return SafeArea(
            child: Stack(
              children: [
                // Background gradient
                const _Background(),

                // Main center stack
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Siri-style voice visualizer (behind everything)
                      VoiceVisualizer(
                        volume: assistantState.currentVolume,
                        isListening: assistantState.isListening,
                        isProcessing:
                            assistantState.status == AssistantStatus.processing,
                        color: Colors.blue,
                      ),

                      const AppIconRing(),
                      const ClockWidget(),
                      // Tap layer
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          final state = assistantState;
                          if (state.isListening) {
                            await state.stopListening();
                          } else {
                            await state.startListening();
                          }
                        },
                        child: const SizedBox(
                          width: 200,
                          height: 200,
                        ),
                      ),
                    ],
                  ),
                ),

                // Speech UI
                if (assistantState.lastQuery.isNotEmpty ||
                    assistantState.lastResponse.isNotEmpty)
                  _SpeechPanel(assistantState: assistantState),

                // Debug panel
                if (_showDebugPanel)
                  _DebugPanel(
                    assistantState: assistantState,
                    onClose: () {
                      setState(() => _showDebugPanel = false);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Color(0xFF3A3A3C),
            Color(0xFF2C2C2E),
          ],
        ),
      ),
    );
  }
}

class _SpeechPanel extends StatelessWidget {
  final AssistantState assistantState;

  const _SpeechPanel({required this.assistantState});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
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
    );
  }
}

class _DebugPanel extends StatelessWidget {
  final AssistantState assistantState;
  final VoidCallback onClose;

  const _DebugPanel({
    required this.assistantState,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 40,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
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
                  'DEBUG PANEL',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${assistantState.status.name}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Listening: ${assistantState.isListening}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Volume: ${(assistantState.currentVolume * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Last Query: ${assistantState.lastQuery.isEmpty ? "None" : assistantState.lastQuery}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Last Response: ${assistantState.lastResponse.isEmpty ? "None" : assistantState.lastResponse}',
              style: const TextStyle(color: Colors.white70),
            ),
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
    );
  }
}
