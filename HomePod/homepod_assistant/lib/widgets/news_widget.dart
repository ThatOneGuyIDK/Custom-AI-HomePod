import 'package:flutter/material.dart';
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
  List<NewsItem> _newsItems = [];
  List<CalendarEvent> _calendarEvents = [];
  bool _isLoading = true;
  String _error = '';
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
    
    _loadData();
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
    if (_newsItems.isEmpty && _calendarEvents.isEmpty) return;
    
    setState(() {
      _currentIndex = (_currentIndex + 1) % (_newsItems.length + _calendarEvents.length);
    });
    
    _slideController.forward(from: 0.0);
    _fadeController.forward(from: 0.0);
  }

  void _previousItem() {
    if (_newsItems.isEmpty && _calendarEvents.isEmpty) return;
    
    setState(() {
      _currentIndex = _currentIndex == 0 
          ? (_newsItems.length + _calendarEvents.length - 1)
          : _currentIndex - 1;
    });
    
    _slideController.forward(from: 0.0);
    _fadeController.forward(from: 0.0);
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // Load sample news data (replace with actual API calls)
      await _loadSampleNews();
      await _loadSampleCalendar();
      
      setState(() {
        _isLoading = false;
      });
      
      _fadeController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSampleNews() async {
    // Sample news data - replace with actual news API
    _newsItems = [
      NewsItem(
        title: 'Tech Innovation Breakthrough',
        summary: 'New AI technology shows promising results',
        category: 'Technology',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NewsItem(
        title: 'Weather Alert: Storm Approaching',
        summary: 'Heavy rain expected this evening',
        category: 'Weather',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NewsItem(
        title: 'Local Community Event',
        summary: 'Annual festival this weekend',
        category: 'Local',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  Future<void> _loadSampleCalendar() async {
    // Sample calendar data - replace with actual calendar API
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

  Widget _getCurrentItem() {
    final totalItems = _newsItems.length + _calendarEvents.length;
    if (totalItems == 0) return const SizedBox.shrink();
    
    if (_currentIndex < _newsItems.length) {
      return _buildNewsItem(_newsItems[_currentIndex]);
    } else {
      final calendarIndex = _currentIndex - _newsItems.length;
      return _buildCalendarEvent(_calendarEvents[calendarIndex]);
    }
  }

  String _getCurrentCategory() {
    if (_currentIndex < _newsItems.length) {
      return _newsItems[_currentIndex].category;
    } else {
      return 'Calendar';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_error.isNotEmpty) {
      return _buildErrorWidget();
    }

    if (_newsItems.isEmpty && _calendarEvents.isEmpty) {
      return _buildNoDataWidget();
    }

    return _buildNewsDisplay();
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: (widget.accentColor ?? Colors.orange).withOpacity(0.3),
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
        color: Colors.red.withOpacity(0.1),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
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
                color: Colors.red.withOpacity(0.7),
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
        color: Colors.grey.withOpacity(0.1),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
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
                color: Colors.grey.withOpacity(0.7),
                fontSize: widget.size * 0.06,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsDisplay() {
    final accentColor = widget.accentColor ?? Colors.orange;
    final totalItems = _newsItems.length + _calendarEvents.length;
    
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            accentColor.withOpacity(0.2),
            accentColor.withOpacity(0.1),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        border: Border.all(
          color: accentColor.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Navigation arrows
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
                  color: accentColor.withOpacity(0.8),
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
                  color: accentColor.withOpacity(0.8),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: widget.size * 0.06,
                ),
              ),
            ),
          ),
          
          // Main content area
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
          
          // Category indicator
          Positioned(
            top: widget.size * 0.05,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.8),
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
          
          // Progress indicator
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
                          : Colors.white.withOpacity(0.3),
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

  Widget _buildNewsItem(NewsItem news) {
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
          news.title,
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
          news.summary,
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
          _formatTimestamp(news.timestamp),
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
}

class NewsItem {
  final String title;
  final String summary;
  final String category;
  final DateTime timestamp;

  NewsItem({
    required this.title,
    required this.summary,
    required this.category,
    required this.timestamp,
  });
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