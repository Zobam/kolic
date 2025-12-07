import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../viewmodels/reading_plan_viewmodel.dart';
import 'reading_plan_setup_view.dart';

class ReadingPlanCalendarView extends StatefulWidget {
  const ReadingPlanCalendarView({super.key});

  @override
  State<ReadingPlanCalendarView> createState() =>
      _ReadingPlanCalendarViewState();
}

class _ReadingPlanCalendarViewState extends State<ReadingPlanCalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReadingPlanViewModel>();
    final readings = viewModel.getReadingForDate(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Reading Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReadingPlanSetupView()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Readings for ${DateFormat('MMM d, yyyy').format(_selectedDay)}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildReadingItem(
                      "Old Testament", readings['OT'] ?? "Not started"),
                  const SizedBox(height: 20),
                  _buildReadingItem(
                      "New Testament", readings['NT'] ?? "Not started"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingItem(String title, String reference) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          reference,
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.blueAccent),
        ),
      ],
    );
  }
}
