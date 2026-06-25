import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homepod_assistant/providers/assistant_state.dart';

class VolumeControl extends StatelessWidget {
  const VolumeControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AssistantState>(
      builder: (context, assistantState, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Volume down button
            GestureDetector(
              onTap: () {
                // Volume control - this would be handled by the voice service
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Volume control coming soon!')),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volume_down,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Volume indicator
            Container(
              width: 100,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: assistantState.currentVolume,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Volume up button
            GestureDetector(
              onTap: () {
                // Volume control - this would be handled by the voice service
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Volume control coming soon!')),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volume_up,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 