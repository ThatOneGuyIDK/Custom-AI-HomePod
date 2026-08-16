import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homepod_assistant/providers/news_provider.dart';
import 'package:intl/intl.dart';

class NewsWidget extends StatefulWidget {
  final double size;
  final Color? accentColor;

  const NewsWidget({
    super.key,
    this.size = 200,
    this.accentColor,
  });

  @override
  State<NewsWidget> createState() => _NewsWidgetState();
}

class _NewsWidgetState extends State<NewsWidget>
    with TickerProviderStateMixin {
  List<CalendarEvent> _calendarEvents = [];
  int _currentIndex = 0;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _loadSampleCalendar();
    _startAutoRotation();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startAutoRotation() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _nextItem();
        _startAutoRotation();
      }
    });
  }

  void _nextItem() {
    if (_allItems.isEmpty) return;

    setState(() {
      _currentIndex = (_currentIndex + 1) % _allItems.length;
    });

    _slideController.forward(from: 0.0);
    _fadeController.forward(from: 0.0);
  }

  void _previousItem() {
    if (_allItems.isEmpty) return;

    setState(() {
      _currentIndex = _currentIndex == 0
          ? (_allItems.length - 1)
          : _currentIndex - 1;
    });

    _slideController.forward(from: 0.0);
    _fadeController.forward(from: 0.0);
  }

  List<Map<String, dynamic>> _getNewsArticles(NewsProvider provider) {
    final allNews = [...provider.globalNews, ...provider.techNews, ...provider.localNews];
    return allNews.cast<Map<String, dynamic>>();
  }

  List<dynamic> get _allItems {
    if (!mounted) return [];
    return [..._newsArticles, ..._calendarEvents];
  }

  List<Map<String, dynamic>> get _newsArticles {
    if (!mounted) return [];
    return _getNewsArticles(context.read<NewsProvider>());
  }

  String _getCurrentCategory() {
    if (_newsArticles.isEmpty && _calendarEvents.isEmpty) return 'News';

    if (_currentIndex < _newsArticles.length) {
      final article = _newsArticles[_currentIndex];
      final source = (article['source']?.toString() ?? '').toLowerCase();
      if (source.contains('daily progress')) return 'Local';
      return 'News';
    } else {
      return 'Calendar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && !provider.hasCachedData) {
          return _buildLoadingWidget();
        }

        if (provider.error.isNotEmpty && _allItems.isEmpty) {
          return _buildErrorWidget();
        }

        if (_allItems.isEmpty) {
          return _buildNoDataWidget();
        }

        return _buildNewsDisplay(provider);
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: (widget.accentColor ?? Colors.orange).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: widget.accentColor ?? Colors.orange,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: widget.size * 0.2,
            ),
            const SizedBox(height: 8),
            Text(
              'Loading Error',
              style: TextStyle(
                color: Colors.red,
                fontSize: widget.size * 0.08,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to retry',
              style: TextStyle(
                color: Colors.red.withValues(alpha: 0.7),
                fontSize: widget.size * 0.06,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.newspaper,
              color: Colors.grey,
              size: widget.size * 0.2,
            ),
            const SizedBox(height: 8),
            Text(
              'No Updates',
              style: TextStyle(
                color: Colors.grey,
                fontSize: widget.size * 0.08,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Check back later',
              style: TextStyle(
                color: Colors.grey.withValues(alpha: 0.7),
                fontSize: widget.size * 0.06,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsDisplay(NewsProvider provider) {
    final accentColor = widget.accentColor ?? Colors.orange;
    final totalItems = _allItems.length;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            accentColor.withValues(alpha: 0.2),
            accentColor.withValues(alpha: 0.1),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: widget.size * 0.4,
            left: widget.size * 0.05,
            child: GestureDetector(
              onTap: _previousItem,
              child: Container(
                width: widget.size * 0.1,
                height: widget.size * 0.1,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.8),
                ),
                child: Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                  size: widget.size * 0.06,
                ),
              ),
            ),
          ),

          Positioned(
            top: widget.size * 0.4,
            right: widget.size * 0.05,
            child: GestureDetector(
              onTap: _nextItem,
              child: Container(
                width: widget.size * 0.1,
                height: widget.size * 0.1,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.8),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: widget.size * 0.06,
                ),
              ),
            ),
          ),

          Positioned(
            top: widget.size * 0.15,
            left: widget.size * 0.2,
            right: widget.size * 0.2,
            bottom: widget.size * 0.15,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _getCurrentItem(),
              ),
            ),
          ),

          Positioned(
            top: widget.size * 0.05,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getCurrentCategory(),
                  style: TextStyle(
                    fontSize: widget.size * 0.06,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: widget.size * 0.05,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalItems, (index) {
                  return Container(
                    width: widget.size * 0.02,
                    height: widget.size * 0.02,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentIndex
                          ? accentColor
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCurrentItem() {
    if (_allItems.isEmpty) return const SizedBox.shrink();

    if (_currentIndex < _newsArticles.length) {
      return _buildNewsItem(_newsArticles[_currentIndex]);
    } else {
      final calendarIndex = _currentIndex - _newsArticles.length;
      if (calendarIndex < _calendarEvents.length) {
        return _buildCalendarEvent(_calendarEvents[calendarIndex]);
      }
      return const SizedBox.shrink();
    }
  }

  Widget _buildNewsItem(Map<String, dynamic> article) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.newspaper,
          color: Colors.white,
          size: widget.size * 0.15,
        ),
        const SizedBox(height: 8),
        Text(
          article['title']?.toString() ?? '',
          style: TextStyle(
            fontSize: widget.size * 0.07,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          article['summary']?.toString() ?? '',
          style: TextStyle(
            fontSize: widget.size * 0.05,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          _formatTimeAgo(article['publishedAt']?.toString() ?? ''),
          style: TextStyle(
            fontSize: widget.size * 0.04,
            color: Colors.white54,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarEvent(CalendarEvent event) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.event,
          color: Colors.white,
          size: widget.size * 0.15,
        ),
        const SizedBox(height: 8),
        Text(
          event.title,
          style: TextStyle(
            fontSize: widget.size * 0.07,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          event.isAllDay
              ? 'All Day'
              : _formatTime(event.time),
          style: TextStyle(
            fontSize: widget.size * 0.05,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
        if (event.location.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            event.location,
            style: TextStyle(
              fontSize: widget.size * 0.04,
              color: Colors.white54,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Future<void> _loadSampleCalendar() async {
    _calendarEvents = [
      CalendarEvent(
        title: 'Team Meeting',
        time: DateTime.now().add(const Duration(hours: 1)),
        location: 'Conference Room A',
        isAllDay: false,
      ),
      CalendarEvent(
        title: 'Dentist Appointment',
        time: DateTime.now().add(const Duration(days: 1, hours: 10)),
        location: 'Dr. Smith Office',
        isAllDay: false,
      ),
      CalendarEvent(
        title: 'Weekend Trip',
        time: DateTime.now().add(const Duration(days: 2)),
        location: 'Mountain Resort',
        isAllDay: true,
      ),
    ];
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

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
}

class CalendarEvent {
  final String title;
  final DateTime time;
  final String location;
  final bool isAllDay;

  CalendarEvent({
    required this.title,
    required this.time,
    required this.location,
    this.isAllDay = false,
  });
}