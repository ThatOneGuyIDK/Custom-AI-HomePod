import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homepod_assistant/providers/assistant_state.dart';

class AssistantIndicator extends StatelessWidget {
  const AssistantIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AssistantState>(
      builder: (context, assistantState, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getIndicatorColor(assistantState.status),
            boxShadow: [
              BoxShadow(
                color: _getIndicatorColor(assistantState.status).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            _getIndicatorIcon(assistantState.status),
            color: Colors.white,
            size: 48,
          ),
        );
      },
    );
  }

  Color _getIndicatorColor(AssistantStatus status) {
    switch (status) {
      case AssistantStatus.idle:
        return Colors.grey[600]!;
      case AssistantStatus.listening:
        return Colors.blue;
      case AssistantStatus.processing:
        return Colors.orange;
      case AssistantStatus.speaking:
        return Colors.green;
      case AssistantStatus.error:
        return Colors.red;
    }
  }

  IconData _getIndicatorIcon(AssistantStatus status) {
    switch (status) {
      case AssistantStatus.idle:
        return Icons.mic_none;
      case AssistantStatus.listening:
        return Icons.mic;
      case AssistantStatus.processing:
        return Icons.hourglass_empty;
      case AssistantStatus.speaking:
        return Icons.volume_up;
      case AssistantStatus.error:
        return Icons.error;
    }
  }
} 