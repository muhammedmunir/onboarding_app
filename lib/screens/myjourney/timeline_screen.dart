import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  DateTime _currentDate = DateTime.now();
  late List<DateTime> _visibleDays;
  DateTime? _selectedDate;
  final ScrollController _scrollController = ScrollController();

  // Sample data for events
  List<Map<String, dynamic>> _events = [
    {
      'title': 'Weekly Meeting',
      'startTime': '10:00 AM',
      'endTime': '11:30 AM',
      'location': 'Platinum Tower',
      'description':
          'Meeting place at Platinum Tower. Please bring your laptop and note book for...',
      'link': 'https://meet.google.com/abc-xyz-123',
      'date': DateTime(2025, 9, 12, 10, 0), // September 12, 2025, 10:00 AM
    },
    {
      'title': 'Seminar Flutterflow',
      'startTime': '2:00 PM',
      'endTime': '4:00 PM',
      'location': 'Warisan Tower',
      'description':
          'Seminar place at Warisan Tower. Please bring your laptop and note book for...',
      'link': '',
      'date': DateTime(2025, 9, 12, 14, 0), // September 12, 2025, 2:00 PM
    },
    {
      'title': 'Meeting with Client',
      'startTime': '4:30 PM',
      'endTime': '5:30 PM',
      'location': 'UOA Tower',
      'description':
          'Meeting place at UOA Tower. Please bring your laptop and note book for...',
      'link': 'https://zoom.us/j/123456789',
      'date': DateTime(2025, 9, 12, 16, 30), // September 12, 2025, 4:30 PM
    },
  ];

  // Controllers for the add event form
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  DateTime _newEventDate = DateTime.now();
  TimeOfDay _newEventStartTime = TimeOfDay.now();
  TimeOfDay _newEventEndTime =
      TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _generateVisibleDays();

    // Scroll to current date after initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentDate();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _generateVisibleDays() {
    // Generate days for the current month
    final firstDay = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDay = DateTime(_currentDate.year, _currentDate.month + 1, 0);

    _visibleDays = [];
    for (int i = 0; i < lastDay.day; i++) {
      _visibleDays.add(DateTime(_currentDate.year, _currentDate.month, i + 1));
    }
  }

  void _scrollToCurrentDate() {
    if (_currentDate.month == DateTime.now().month &&
        _currentDate.year == DateTime.now().year) {
      final currentDateIndex = _visibleDays.indexWhere((date) =>
          date.day == DateTime.now().day &&
          date.month == DateTime.now().month &&
          date.year == DateTime.now().year);

      if (currentDateIndex != -1) {
        final double scrollPosition = currentDateIndex * 70.0;
        _scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      _generateVisibleDays();
      _selectedDate = DateTime(_currentDate.year, _currentDate.month, 1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(0);
      });
    });
  }

  void _goToNextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      _generateVisibleDays();
      _selectedDate = DateTime(_currentDate.year, _currentDate.month, 1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(0);
      });
    });
  }

  void _showMonthYearPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Month and Year'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Year selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        setState(() {
                          _currentDate = DateTime(
                              _currentDate.year - 1, _currentDate.month, 1);
                        });
                      },
                    ),
                    Text(
                      _currentDate.year.toString(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        setState(() {
                          _currentDate = DateTime(
                              _currentDate.year + 1, _currentDate.month, 1);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Month grid
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final month = index + 1;
                    final monthName =
                        DateFormat('MMM').format(DateTime(2023, month, 1));
                    final isCurrentMonth = month == _currentDate.month;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _currentDate = DateTime(_currentDate.year, month, 1);
                          _generateVisibleDays();
                          _selectedDate = DateTime(
                              _currentDate.year, _currentDate.month, 1);
                          Navigator.pop(context);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollController.jumpTo(0);
                          });
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color:
                              isCurrentMonth ? Colors.blue : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            monthName,
                            style: TextStyle(
                              color:
                                  isCurrentMonth ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddEventDialog() {
    // Reset form fields
    _titleController.clear();
    _startTimeController.text = DateFormat('h:mm a').format(DateTime.now());
    _endTimeController.text = DateFormat('h:mm a')
        .format(DateTime.now().add(const Duration(hours: 1)));
    _locationController.clear();
    _descriptionController.clear();
    _linkController.clear();
    _newEventDate = _selectedDate ?? DateTime.now();
    _newEventStartTime = TimeOfDay.now();
    _newEventEndTime = TimeOfDay(
        hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Event'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Date selection
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _newEventDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _newEventDate = pickedDate;
                                });
                              }
                            },
                            child: Text(
                              DateFormat('MMM d, yyyy').format(_newEventDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Start and end time
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _startTimeController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Start Time *',
                              border: OutlineInputBorder(),
                            ),
                            onTap: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: _newEventStartTime,
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _newEventStartTime = pickedTime;
                                  _startTimeController.text =
                                      pickedTime.format(context);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _endTimeController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'End Time *',
                              border: OutlineInputBorder(),
                            ),
                            onTap: () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: _newEventEndTime,
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _newEventEndTime = pickedTime;
                                  _endTimeController.text =
                                      pickedTime.format(context);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _linkController,
                      decoration: const InputDecoration(
                        labelText: 'Link (optional)',
                        hintText: 'https://example.com',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty) {
                      // Create new event
                      final newEvent = {
                        'title': _titleController.text,
                        'startTime': _startTimeController.text,
                        'endTime': _endTimeController.text,
                        'location': _locationController.text,
                        'description': _descriptionController.text,
                        'link': _linkController.text,
                        'date': DateTime(
                          _newEventDate.year,
                          _newEventDate.month,
                          _newEventDate.day,
                          _newEventStartTime.hour,
                          _newEventStartTime.minute,
                        ),
                      };

                      // Add to events list
                      setState(() {
                        _events.add(newEvent);
                        // Sort events by time
                        _events.sort((a, b) => (a['date'] as DateTime)
                            .compareTo(b['date'] as DateTime));
                      });

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Event'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getDayAbbreviation(DateTime date) {
    return DateFormat('E').format(date).substring(0, 3);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  bool _hasEvents(DateTime date) {
    return _events.any((event) {
      final eventDate = event['date'] as DateTime;
      return eventDate.day == date.day &&
          eventDate.month == date.month &&
          eventDate.year == date.year;
    });
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, yyyy').format(_selectedDate!);

    // Get events for selected date and sort by time
    final eventsForSelectedDate = _events.where((event) {
      final eventDate = event['date'] as DateTime;
      return eventDate.day == _selectedDate!.day &&
          eventDate.month == _selectedDate!.month &&
          eventDate.year == _selectedDate!.year;
    }).toList();

    // Sort events by time
    eventsForSelectedDate.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, size: 40, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                // Welcome text
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to TNB,',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Siti Zubaidah',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Month and year navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: _goToPreviousMonth,
                ),
                GestureDetector(
                  onTap: _showMonthYearPicker,
                  child: Text(
                    DateFormat('MMMM yyyy').format(_currentDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: _goToNextMonth,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Horizontal scrollable days
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _visibleDays.length,
              itemBuilder: (context, index) {
                final day = _visibleDays[index];
                final isToday = _isToday(day);
                final hasEvents = _hasEvents(day);
                final isSelected = _selectedDate != null &&
                    day.day == _selectedDate!.day &&
                    day.month == _selectedDate!.month &&
                    day.year == _selectedDate!.year;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = day;
                    });
                  },
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue
                          : isToday
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isToday ? Colors.blue : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDayAbbreviation(day),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        if (hasEvents)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Selected date
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (_isToday(_selectedDate!))
                  Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          // Events list (Timeline)
          Expanded(
            child: ListView.builder(
              itemCount: eventsForSelectedDate.length,
              itemBuilder: (context, index) {
                final event = eventsForSelectedDate[index];
                final eventDate = event['date'] as DateTime;

                return TimelineEventItem(
                  title: event['title'],
                  startTime: event['startTime'],
                  endTime: event['endTime'],
                  location: event['location'],
                  description: event['description'],
                  link: event['link'],
                  onLinkTap: (link) {
                    if (link.isNotEmpty) {
                      _launchUrl(link);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: const Color.fromRGBO(224, 124, 124, 1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class TimelineEventItem extends StatelessWidget {
  final String title;
  final String startTime;
  final String endTime;
  final String location;
  final String description;
  final String link;
  final Function(String) onLinkTap;

  const TimelineEventItem({
    super.key,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.description,
    required this.link,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time indicator
          Container(
            width: 80,
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startTime,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  endTime,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
                if (link.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => onLinkTap(link),
                    child: Text(
                      link,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}