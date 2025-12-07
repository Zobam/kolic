import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/attendance_viewmodel.dart';
import '../models/member.dart';
import 'add_member_view.dart';

class MembersListView extends StatelessWidget {
  const MembersListView({super.key});

  @override
  Widget build(BuildContext context) {
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
              // If loading present status, we can still show members but maybe disable buttons?
              // Or just wait. Let's just show.
              final presentIds = presentSnapshot.data ?? [];

              return ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  final isPresent = presentIds.contains(member.id);

                  return ListTile(
                    title: Text('${member.firstName} ${member.lastName}'),
                    subtitle: Text(member.phoneNumber),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMemberView()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
