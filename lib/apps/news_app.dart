import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homepod_assistant/providers/news_provider.dart';
import 'package:intl/intl.dart';

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, provider, _) {
        return _NewsAppContent(provider: provider);
      },
    );
  }
}

class _NewsAppContent extends StatefulWidget {
  final NewsProvider provider;

  const _NewsAppContent({required this.provider});

  @override
  State<_NewsAppContent> createState() => _NewsAppContentState();
}

class _NewsAppContentState extends State<_NewsAppContent> {
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Global', 'Technology', 'Local'];

  @override
  Widget build(BuildContext context) {
    final articles = widget.provider.getArticlesByCategory(_selectedCategory);

    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.yellow, width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.yellow.withValues(alpha: 0.2),
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

          SizedBox(
            height: 40,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _categories.map((category) {
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
                        color: isSelected ? Colors.yellow : Colors.grey.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          if (widget.provider.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.yellow,
                ),
              ),
            )
          else if (widget.provider.error.isNotEmpty && articles.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        widget.provider.error,
                        style: TextStyle(
                          color: Colors.red.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (articles.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.newspaper,
                      color: Colors.grey,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No news available',
                      style: TextStyle(
                        color: Colors.grey.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.yellow.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _getCategoryIcon(_getArticleCategory(article)),
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article['title']?.toString() ?? '',
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
                                    article['source']?.toString() ?? 'Unknown',
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
                          article['summary']?.toString() ?? '',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTimeAgo(article['publishedAt']?.toString() ?? ''),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          Container(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: () {
                widget.provider.fetchAllNews(force: true);
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

  String _getArticleCategory(Map<String, dynamic> article) {
    final source = (article['source']?.toString() ?? '').toLowerCase();
    if (source.contains('daily progress')) return 'Local';
    return 'Global';
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Local':
        return '📍';
      case 'Technology':
        return '💻';
      default:
        return '🌍';
    }
  }

  String _formatTimeAgo(String publishedAt) {
    if (publishedAt.isEmpty) return '';
    try {
      final date = DateTime.tryParse(publishedAt);
      if (date == null) return publishedAt;
      final difference = DateTime.now().difference(date);
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return DateFormat('MMM d').format(date);
      }
    } catch (e) {
      return publishedAt;
    }
  }
}
