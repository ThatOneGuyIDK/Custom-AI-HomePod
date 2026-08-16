import 'package:http/http.dart' as http;
import 'dart:convert';

class CalendarService {
  static const String baseUrl = 'https://api.timetreeapp.com';

  final String apiKey;
  final String apiSecret;

  CalendarService({required this.apiKey, required this.apiSecret});

  Future<List<Map<String, dynamic>>> getCalendars() async {
    const url = '$baseUrl/calendars';
    final response = await _safeRequest(url, 'calendars list');
    return (response['calendars'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        [];
  }

  Future<List<Map<String, dynamic>>> getEvents({
    required String calendarId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final url = '$baseUrl/calendars/$calendarId/events';
    final queryParameters = <String, String>{
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
    };
    final uri = Uri.parse(url).replace(queryParameters: queryParameters);
    final response = await _safeRequest(uri.toString(), 'events');
    return (response['events'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        [];
  }

  Future<Map<String, dynamic>> createEvent({
    required String calendarId,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? description,
  }) async {
    final url = '$baseUrl/calendars/$calendarId/events';
    final body = {
      'title': title,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      if (description != null) 'description': description,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: _getHeaders(),
      body: json.encode(body),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create event: ${response.statusCode}');
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Map<String, String> _getHeaders() {
    return {
      'Authorization': 'Bearer ${_generateToken()}',
      'Content-Type': 'application/json',
      'X-Api-Key': apiKey,
    };
  }

  String _generateToken() {
    final tokenData = '$apiKey:$apiSecret:${DateTime.now().millisecondsSinceEpoch}';
    return base64Encode(utf8.encode(tokenData));
  }

  Future<Map<String, dynamic>> _safeRequest(String url, String label) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );
      if (response.statusCode == 429) {
        await Future.delayed(const Duration(seconds: 3));
        final retryResponse = await http.get(
          Uri.parse(url),
          headers: _getHeaders(),
        );
        if (retryResponse.statusCode != 200) {
          throw Exception('API error ($label) - Status ${retryResponse.statusCode}');
        }
        return json.decode(retryResponse.body) as Map<String, dynamic>;
      }
      if (response.statusCode != 200) {
        throw Exception('API error ($label) - Status ${response.statusCode}');
      }
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
