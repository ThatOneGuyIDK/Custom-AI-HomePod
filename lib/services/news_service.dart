import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';

class NewsService {
  static const String baseUrl = 'https://gnews.io/api/v4';

  final String apiKey;

  NewsService({required this.apiKey});

  Future<List<Map<String, dynamic>>> getGlobalHeadlines() async {
    final url = '$baseUrl/top-headlines?category=general&lang=en&country=us&max=10&apikey=$apiKey';
    final response = await _safeRequest(url, 'global headlines');
    return response.map((e) => _parseArticle(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getTechHeadlines() async {
    final url = '$baseUrl/top-headlines?category=technology&lang=en&country=us&max=10&apikey=$apiKey';
    final response = await _safeRequest(url, 'tech headlines');
    return response.map((e) => _parseArticle(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getLocalNews() async {
    final url = '$baseUrl/search?q=Virginia+news&lang=en&country=us&max=10&apikey=$apiKey';
    final response = await _safeRequest(url, 'local news');
    return response.map((e) => _parseArticle(e)).toList();
  }

  Future<List<dynamic>> _safeRequest(String url, String label) async {
    try {
      debugPrint('NewsService: Fetching $label from $url');
      final response = await http.get(Uri.parse(url));
      debugPrint('NewsService: $label response status ${response.statusCode}');
      
      if (response.statusCode == 429) {
        debugPrint('NewsService: $label rate limited, retrying in 3s...');
        await Future.delayed(const Duration(seconds: 3));
        final retryResponse = await http.get(Uri.parse(url));
        if (retryResponse.statusCode != 200) {
          final body = retryResponse.body.substring(0, retryResponse.body.length > 200 ? 200 : retryResponse.body.length);
          throw Exception('API error ($label) - Status ${retryResponse.statusCode}: $body');
        }
        return _parseApiResponse(retryResponse, label);
      }
      
      if (response.statusCode != 200) {
        final body = response.body.substring(0, response.body.length > 200 ? 200 : response.body.length);
        throw Exception('API error ($label) - Status ${response.statusCode}: $body');
      }
      
      return _parseApiResponse(response, label);
    } catch (e) {
      debugPrint('NewsService: $label error: $e');
      rethrow;
    }
  }

  List<dynamic> _parseApiResponse(http.Response response, String label) {
    final data = json.decode(response.body) as Map<String, dynamic>;
    if (data['status'] == 'error') {
      throw Exception('API error ($label): ${data['error'] ?? data['message'] ?? 'Unknown error'}');
    }
    final articles = data['articles'] as List<dynamic>? ?? [];
    debugPrint('NewsService: $label got ${articles.length} articles');
    return articles;
  }

  Map<String, dynamic> _parseArticle(dynamic article) {
    return {
      'title': article['title'] ?? '',
      'summary': article['description'] ?? '',
      'url': article['url'] ?? '',
      'source': article['source']?['name'] ?? 'Unknown',
      'publishedAt': article['publishedAt'] ?? '',
      'image': article['image'] ?? '',
    };
  }

}
