import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/member.dart';
import '../viewmodels/attendance_viewmodel.dart';

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    // We can reuse AttendanceViewModel since it holds the date and logic
    final viewModel = context.watch<AttendanceViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: viewModel.selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                viewModel.setDate(picked);
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              DateFormat('EEEE, MMMM d, yyyy').format(viewModel.selectedDate),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Member>>(
        stream: viewModel.membersStream,
        builder: (context, memberSnapshot) {
          if (memberSnapshot.hasError) {
            return Center(child: Text('Error: ${memberSnapshot.error}'));
          }
          if (memberSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final members = memberSnapshot.data ?? [];

          return StreamBuilder<List<String>>(
            stream: viewModel.presentMembersStream,
            builder: (context, presentSnapshot) {
              final presentIds = presentSnapshot.data ?? [];

              return ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  final isPresent = presentIds.contains(member.id);

                  return ListTile(
                    title: Text('${member.firstName} ${member.lastName}'),
                    // No onTap details dialog here, strictly attendance
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isPresent ? Colors.green : Colors.grey[300],
                        foregroundColor:
                            isPresent ? Colors.white : Colors.black,
                      ),
                      onPressed: () {
                        viewModel.toggleAttendance(member.id, !isPresent);
                      },
                      child: Text(isPresent ? 'Present' : 'Absent'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
