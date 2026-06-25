import 'package:flutter/material.dart';

class NewsApp extends StatefulWidget {
  const NewsApp({super.key});

  @override
  State<NewsApp> createState() => _NewsAppState();
}

class _NewsAppState extends State<NewsApp> {
  List<NewsArticle> _articles = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Technology', 'Science', 'Business', 'Entertainment'];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    // Simulate loading
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _articles = [
        NewsArticle(
          title: 'New AI Breakthrough in Natural Language Processing',
          summary: 'Researchers develop advanced language models that better understand context and nuance.',
          category: 'Technology',
          timeAgo: '2 hours ago',
          imageUrl: '🤖',
        ),
        NewsArticle(
          title: 'SpaceX Successfully Launches New Satellite Constellation',
          summary: 'The company continues to expand its global internet coverage with latest launch.',
          category: 'Science',
          timeAgo: '4 hours ago',
          imageUrl: '🚀',
        ),
        NewsArticle(
          title: 'Major Tech Companies Announce Climate Initiative',
          summary: 'Collaborative effort to reduce carbon footprint across the industry.',
          category: 'Business',
          timeAgo: '6 hours ago',
          imageUrl: '🌱',
        ),
        NewsArticle(
          title: 'New Streaming Service Launches with Exclusive Content',
          summary: 'Competition heats up in the streaming entertainment market.',
          category: 'Entertainment',
          timeAgo: '8 hours ago',
          imageUrl: '📺',
        ),
        NewsArticle(
          title: 'Breakthrough in Quantum Computing Research',
          summary: 'Scientists achieve new milestone in quantum supremacy.',
          category: 'Science',
          timeAgo: '12 hours ago',
          imageUrl: '⚛️',
        ),
      ];
      
      _isLoading = false;
    });
  }

  List<NewsArticle> get _filteredArticles {
    if (_selectedCategory == 'All') {
      return _articles;
    }
    return _articles.where((article) => article.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.yellow, width: 2),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.notifications, color: Colors.yellow, size: 32),
                SizedBox(width: 12),
                Text(
                  'News',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Category Filter
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.transparent,
                    selectedColor: Colors.yellow,
                    side: BorderSide(
                      color: isSelected ? Colors.yellow : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                );
              },
            ),
          ),
          
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.yellow,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredArticles.length,
                itemBuilder: (context, index) {
                  final article = _filteredArticles[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.yellow.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              article.imageUrl,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    article.category,
                                    style: const TextStyle(
                                      color: Colors.yellow,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          article.summary,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          article.timeAgo,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          
          // Refresh Button
          Container(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _loadNews();
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NewsArticle {
  final String title;
  final String summary;
  final String category;
  final String timeAgo;
  final String imageUrl;

  NewsArticle({
    required this.title,
    required this.summary,
    required this.category,
    required this.timeAgo,
    required this.imageUrl,
  });
} 