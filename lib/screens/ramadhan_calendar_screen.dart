import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RamadhanCalendarScreen extends StatefulWidget {
  final bool hasLocation;

  const RamadhanCalendarScreen({
    super.key,
    required this.hasLocation,
  });

  @override
  State<RamadhanCalendarScreen> createState() => _RamadhanCalendarScreenState();
}

class _RamadhanCalendarScreenState extends State<RamadhanCalendarScreen> {
  final DateTime _ramadhanStart = DateTime(2025, 3, 1); // Updated to 2025
  final List<Map<String, String>> _ramadhanDays = [];

  @override
  void initState() {
    super.initState();
    _generateRamadhanCalendar();
  }

  void _generateRamadhanCalendar() {
    for (int i = 0; i < 30; i++) {
      final date = _ramadhanStart.add(Duration(days: i));
      final dayNumber = i + 1;

      // Calculate approximate Sehri and Iftar times (you should replace these with actual API data)
      final sehriHour = 4 + (i ~/ 15); // Adjusts as month progresses
      final iftarHour = 18 + (i ~/ 15); // Adjusts as month progresses

      _ramadhanDays.add({
        'date': DateFormat('MMMM d, yyyy').format(date),
        'day': 'Ramadhan $dayNumber',
        'sehri':
            DateFormat('h:mm a').format(DateTime(2025, 3, 1, sehriHour, 30)),
        'iftar':
            DateFormat('h:mm a').format(DateTime(2025, 3, 1, iftarHour, 45)),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ramadhan Calendar 2025'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _ramadhanDays.length,
        itemBuilder: (context, index) {
          final day = _ramadhanDays[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day['date']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    day['day']!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sehri: ${day['sehri']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Iftar: ${day['iftar']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
