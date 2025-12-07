import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/reading_plan_viewmodel.dart';

class ReadingPlanSetupView extends StatefulWidget {
  const ReadingPlanSetupView({super.key});

  @override
  State<ReadingPlanSetupView> createState() => _ReadingPlanSetupViewState();
}

class _ReadingPlanSetupViewState extends State<ReadingPlanSetupView> {
  DateTime? _otStartDate;
  int _otChapters = 1;
  DateTime? _ntStartDate;
  int _ntChapters = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plan = context.read<ReadingPlanViewModel>().plan;
      setState(() {
        _otStartDate = plan.otStartDate;
        _otChapters = plan.otChaptersPerDay;
        _ntStartDate = plan.ntStartDate;
        _ntChapters = plan.ntChaptersPerDay;
      });
    });
  }

  Future<void> _pickDate(bool isOt) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isOt)
          _otStartDate = picked;
        else
          _ntStartDate = picked;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    await context.read<ReadingPlanViewModel>().savePlan(
          otStartDate: _otStartDate,
          otChapters: _otChapters,
          ntStartDate: _ntStartDate,
          ntChapters: _ntChapters,
        );
    setState(() => _isLoading = false);
    if (mounted)
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Plan Saved')));
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes if needed, but we used local state for form
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Reading Plan')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Old Testament Plan',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ListTile(
                    title: Text(_otStartDate == null
                        ? 'Select Start Date'
                        : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_otStartDate!)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _pickDate(true),
                  ),
                  DropdownButtonFormField<int>(
                    value: _otChapters,
                    decoration:
                        const InputDecoration(labelText: 'Chapters per day'),
                    items: List.generate(5, (index) => index + 1)
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text('$e')))
                        .toList(),
                    onChanged: (val) => setState(() => _otChapters = val!),
                  ),
                  const Divider(height: 40),
                  const Text('New Testament Plan',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ListTile(
                    title: Text(_ntStartDate == null
                        ? 'Select Start Date'
                        : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_ntStartDate!)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _pickDate(false),
                  ),
                  DropdownButtonFormField<int>(
                    value: _ntChapters,
                    decoration:
                        const InputDecoration(labelText: 'Chapters per day'),
                    items: List.generate(5, (index) => index + 1)
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text('$e')))
                        .toList(),
                    onChanged: (val) => setState(() => _ntChapters = val!),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save Plan'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
