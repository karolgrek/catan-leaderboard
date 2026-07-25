import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../utils/date_formatters.dart';
import '../../utils/snackbar_helper.dart';

class SessionEditorScreen extends StatefulWidget {
  const SessionEditorScreen({super.key});

  @override
  State<SessionEditorScreen> createState() => _SessionEditorScreenState();
}

class _SessionEditorScreenState extends State<SessionEditorScreen> {
  DateTime _selectedDate = DateTime.now();
  final _notesController = TextEditingController();
  final List<String> _selectedPlayers = [];

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveSession() async {
    if (_selectedPlayers.isEmpty) {
      SnackbarHelper.showError(context, 'Please select at least one player.');
      return;
    }

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    bool success = await groupProvider.createSession(
      _selectedDate,
      _notesController.text.trim(),
      _selectedPlayers,
    );

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      SnackbarHelper.showError(context, 'Failed to save session.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final members = groupProvider.groupMembers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Session'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSession,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Picker
            ListTile(
              title: const Text('Session Date'),
              subtitle: Text(DateFormatter.toReadableDate(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            // Notes Field
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            // Player Selection
            const Text('Select Players', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: members.isEmpty
                  ? const Center(child: Text('No players in this group.'))
                  : ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final isSelected = _selectedPlayers.contains(member.uid);
                        return CheckboxListTile(
                          title: Text(member.name),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedPlayers.add(member.uid);
                              } else {
                                _selectedPlayers.remove(member.uid);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
