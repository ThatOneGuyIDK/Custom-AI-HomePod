import 'package:flutter/material.dart';
import 'package:homepod_assistant/services/news_service.dart';
import 'package:homepod_assistant/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NewsProvider extends ChangeNotifier {
  final NewsService _service;

  bool _isLoading = false;
  String _error = '';

  List<Map<String, dynamic>> _globalNews = [];
  List<Map<String, dynamic>> _techNews = [];
  List<Map<String, dynamic>> _localNews = [];

  DateTime? _lastFetchTime;
  static const Duration cacheTimeout = Duration(minutes: 30);

  bool get isLoading => _isLoading;
  String get error => _error;
  List<Map<String, dynamic>> get globalNews => _globalNews;
  List<Map<String, dynamic>> get techNews => _techNews;
  List<Map<String, dynamic>> get localNews => _localNews;
  bool get hasCachedData => _globalNews.isNotEmpty || _techNews.isNotEmpty || _localNews.isNotEmpty;

  NewsProvider()
      : _service = NewsService(apiKey: AppConfig.newsApiKey) {
    _loadCachedNews();
    if (AppConfig.isValidApiKey(AppConfig.newsApiKey)) {
      Future.delayed(Duration.zero, () => fetchAllNews());
    }
  }

  Future<void> fetchAllNews({bool force = false}) async {
    if (!force && _isCacheValid()) {
      debugPrint('News cache valid, skipping fetch');
      return;
    }

    debugPrint('Fetching all news...');
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _globalNews = await _service.getGlobalHeadlines().catchError((e) {
        _error = 'Global news: $e';
        debugPrint(_error);
        return <Map<String, dynamic>>[];
      });

      await Future.delayed(const Duration(milliseconds: 600));

      _techNews = await _service.getTechHeadlines().catchError((e) {
        _error = 'Tech news: $e';
        debugPrint(_error);
        return <Map<String, dynamic>>[];
      });

      await Future.delayed(const Duration(milliseconds: 600));

      _localNews = await _service.getLocalNews().catchError((e) {
        _error = 'Local news: $e';
        debugPrint(_error);
        return <Map<String, dynamic>>[];
      });
      _lastFetchTime = DateTime.now();

      debugPrint('Fetched ${_globalNews.length} global, ${_techNews.length} tech, ${_localNews.length} local articles');

      await _cacheNews();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('News fetch error: $_error');
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isCacheValid() {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < cacheTimeout;
  }

  Future<void> _cacheNews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('news_global', json.encode(_globalNews));
      await prefs.setString('news_tech', json.encode(_techNews));
      await prefs.setString('news_local', json.encode(_localNews));
      await prefs.setInt('news_last_fetch', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Failed to cache news: $e');
    }
  }

  Future<void> _loadCachedNews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetch = prefs.getInt('news_last_fetch') ?? 0;

      if (DateTime.now().millisecondsSinceEpoch - lastFetch < cacheTimeout.inMilliseconds) {
        final globalJson = prefs.getString('news_global');
        final techJson = prefs.getString('news_tech');
        final localJson = prefs.getString('news_local');

        if (globalJson != null) {
          _globalNews = (json.decode(globalJson) as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
        if (techJson != null) {
          _techNews = (json.decode(techJson) as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
        if (localJson != null) {
          _localNews = (json.decode(localJson) as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }

        _lastFetchTime = DateTime.fromMillisecondsSinceEpoch(lastFetch);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load cached news: $e');
    }
  }

  List<Map<String, dynamic>> getArticlesByCategory(String category) {
    switch (category) {
      case 'Global':
        return _globalNews;
      case 'Technology':
        return _techNews;
      case 'Local':
        return _localNews;
      default:
        return [..._globalNews, ..._techNews, ..._localNews];
    }
  }
}
