import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/member.dart';
import '../viewmodels/attendance_viewmodel.dart';

class MemberDetailsDialog extends StatefulWidget {
  final Member member;

  const MemberDetailsDialog({super.key, required this.member});

  @override
  State<MemberDetailsDialog> createState() => _MemberDetailsDialogState();
}

class _MemberDetailsDialogState extends State<MemberDetailsDialog> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late DateTime _selectedDate;
  late String _selectedGender;
  final List<String> _genders = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _initializeAppState();
  }

  void _initializeAppState() {
    _firstNameController = TextEditingController(text: widget.member.firstName);
    _lastNameController = TextEditingController(text: widget.member.lastName);
    _phoneController = TextEditingController(text: widget.member.phoneNumber);
    _selectedDate = widget.member.dateOfBirth;
    _selectedGender = widget.member.gender;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final updatedMember = Member(
        id: widget.member.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        dateOfBirth: _selectedDate,
        gender: _selectedGender,
        phoneNumber: _phoneController.text,
      );

      context.read<AttendanceViewModel>().updateMember(updatedMember);

      // Update widget.member reference for view mode, though technically
      // stream in parent list will update. But for immediate simple view switch:
      setState(() {
        _isEditing = false;
        // Ideally we shouldn't mute widget.member directly as it's final.
        // We rely on the View Mode reading from 'updatedMember' or just closing.
        // But since we want to stay open, better to update local state logic.
        // Wait, 'widget.member' is immutable from parent.
        // We should just pop the dialog on save? Requirement says "stay open".
        // If we stay open, we need to show the NEW details.
        // So we might need a local 'currentMember' state variable.
      });
      // Updating local state to show new values in View Mode
      // We can just rely on the controllers' values and _selected vars which holds the new data
    }
  }

  @override
  Widget build(BuildContext context) {
    // If not editing, show View Mode using current state values (which match widget.member initially)

    return AlertDialog(
      title: Text(_isEditing ? 'Edit Member' : 'Member Details'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: _isEditing ? _buildEditForm() : _buildViewMode(),
        ),
      ),
      actions: _isEditing
          ? [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _initializeAppState(); // Reset changes
                  });
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ]
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                child: const Text('Edit'),
              ),
            ],
    );
  }

  Widget _buildViewMode() {
    // We display values from controllers/state variables to reflect updates immediately if "stay open"
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _detailRow('First Name:', _firstNameController.text),
        _detailRow('Last Name:', _lastNameController.text),
        _detailRow('Phone:', _phoneController.text),
        _detailRow('Gender:', _selectedGender),
        _detailRow(
            'Date of Birth:', DateFormat('yyyy-MM-dd').format(_selectedDate)),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(labelText: 'First Name'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(labelText: 'Last Name'),
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
            keyboardType: TextInputType.phone,
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(labelText: 'Gender'),
            items: _genders
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (val) => setState(() => _selectedGender = val!),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title:
                Text('DOB: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(context),
          ),
        ],
      ),
    );
  }
}
