import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class AIModelService {
  static final AIModelService _instance = AIModelService._internal();
  factory AIModelService() => _instance;
  AIModelService._internal();

  String _baseUrl = 'http://localhost:11434';
  bool _useMockMode = false;
  static const Duration _connectionTimeout = Duration(seconds: 4);
  static const Duration _generationTimeout = Duration(seconds: 20);
  String _systemPrompt =
      'You are HomePod Assistant, a practical AI helper for daily tasks. '
      'Be concise, friendly, and action-oriented. '
      'Prioritize clear steps, useful suggestions, and direct answers. '
      'If the user asks something ambiguous, ask one short clarification question. '
      'Avoid roleplay, long disclaimers, and unnecessary filler. '
      'For smart home tasks, propose safe, reversible actions first.';

  /// Set the base URL for the AI model
  void setBaseUrl(String url) {
    _baseUrl = url;
  }

  /// Customize assistant behavior prompt
  void setSystemPrompt(String prompt) {
    if (prompt.trim().isNotEmpty) {
      _systemPrompt = prompt.trim();
    }
  }

  /// Test connection to the AI model
  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/tags'))
          .timeout(_connectionTimeout);
      return response.statusCode == 200;
    } catch (e) {
      print('❌ AI connection test failed: $e');
      return false;
    }
  }

  /// Generate a response from the AI model
  Future<String> generateResponse(String input) async {
    try {
      // First try to connect to real AI
      final isConnected = await testConnection();
      
      if (!isConnected) {
        print('⚠️ AI not available, using mock responses');
        _useMockMode = true;
      }

      if (_useMockMode) {
        return _generateMockResponse(input);
      }

      // Real AI request
      final now = DateTime.now().toIso8601String();
      final request = {
        'model': 'llama2',
        'system': _systemPrompt,
        'prompt': input,
        'stream': false,
        'options': {
          'temperature': 0.4,
          'top_p': 0.9,
          'num_predict': 180,
        },
        'context': [],
        'raw': false,
        'template': 'Current time: $now\n\nUser request: {{ .Prompt }}\n\nAssistant:',
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request),
      ).timeout(_generationTimeout);
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['response'] ?? 'No response from AI model';
      } else {
        throw Exception('AI model returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error generating AI response: $e');
      _useMockMode = true;
      return _generateMockResponse(input);
    }
  }

  /// Generate a mock response for testing
  String _generateMockResponse(String input) {
    final random = Random();
    final responses = [
      "Got it. I heard: '$input'. How would you like me to help with that?",
      "I can help with that. For '$input', do you want a quick answer or step-by-step guidance?",
      "Understood: '$input'. I can summarize, suggest actions, or walk you through it.",
      "I heard '$input'. I can help you do this quickly—what outcome do you want?",
      "Thanks. For '$input', I can give the fastest next step right now.",
    ];
    
    return responses[random.nextInt(responses.length)];
  }

  /// Get available models
  Future<List<String>> getAvailableModels() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/tags'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List;
        return models.map((model) => model['name'] as String).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getting models: $e');
      return [];
    }
  }

  /// Check if using mock mode
  bool get isMockMode => _useMockMode;
} 