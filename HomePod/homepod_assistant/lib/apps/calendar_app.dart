import 'package:flutter/material.dart';

class CalendarApp extends StatefulWidget {
  const CalendarApp({super.key});

  @override
  State<CalendarApp> createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  DateTime _selectedDate = DateTime.now();
  List<CalendarEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    // Simulate loading
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _events = [
        CalendarEvent(
          title: 'Team Meeting',
          time: '9:00 AM',
          duration: '1 hour',
          type: EventType.work,
          description: 'Weekly team sync and project updates',
        ),
        CalendarEvent(
          title: 'Lunch with Sarah',
          time: '12:30 PM',
          duration: '1 hour',
          type: EventType.personal,
          description: 'Catch up over lunch',
        ),
        CalendarEvent(
          title: 'Doctor Appointment',
          time: '3:00 PM',
          duration: '30 min',
          type: EventType.health,
          description: 'Annual checkup',
        ),
        CalendarEvent(
          title: 'Movie Night',
          time: '7:00 PM',
          duration: '2 hours',
          type: EventType.entertainment,
          description: 'Watch the new sci-fi movie',
        ),
      ];

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.black.withValues(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.pink, width: 2),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.pink.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.pink, size: 32),
                SizedBox(width: 12),
                Text(
                  'Calendar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Date Display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.pink.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMonthName(_selectedDate.month),
                      style: const TextStyle(
                        color: Colors.pink,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_selectedDate.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _getDayName(_selectedDate.weekday),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${_selectedDate.year}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.pink,
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  // Events Header
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        const Text(
                          'Today\'s Events',
                          style: TextStyle(
                            color: Colors.pink,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_events.length} events',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Events List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  _getEventColor(event.type).withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _getEventColor(event.type),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: Colors.white.withOpacity(0.6),
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${event.time} (${event.duration})',
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                              fontSize: 11,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                _getEventIcon(event.type),
                                color: _getEventColor(event.type),
                                size: 18,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.subtract(const Duration(days: 1));
                    });
                  },
                  icon: const Icon(Icons.chevron_left,
                      color: Colors.white, size: 18),
                  label: const Text('Prev', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime.now();
                    });
                  },
                  icon: const Icon(Icons.today, color: Colors.white, size: 18),
                  label: const Text('Today', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.add(const Duration(days: 1));
                    });
                  },
                  icon: const Icon(Icons.chevron_right,
                      color: Colors.white, size: 18),
                  label: const Text('Next', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.work:
        return Colors.blue;
      case EventType.personal:
        return Colors.green;
      case EventType.health:
        return Colors.red;
      case EventType.entertainment:
        return Colors.purple;
    }
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.work:
        return Icons.work;
      case EventType.personal:
        return Icons.person;
      case EventType.health:
        return Icons.favorite;
      case EventType.entertainment:
        return Icons.movie;
    }
  }
}

class CalendarEvent {
  final String title;
  final String time;
  final String duration;
  final EventType type;
  final String description;

  CalendarEvent({
    required this.title,
    required this.time,
    required this.duration,
    required this.type,
    required this.description,
  });
}

enum EventType {
  work,
  personal,
  health,
  entertainment,
}
