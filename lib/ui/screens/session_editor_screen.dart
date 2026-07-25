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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Picker
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              color: Colors.white,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: const Text('Session Date', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormatter.toReadableDate(_selectedDate)),
                trailing: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                ),
                onTap: _pickDate,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            // Notes Field
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 48.0),
                  child: Icon(Icons.edit_note),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            // Player Selection
            const Text('Select Players', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: members.isEmpty
                  ? Center(child: Text('No players in this group.', style: TextStyle(color: Colors.grey.shade500)))
                  : ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final isSelected = _selectedPlayers.contains(member.uid);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: CheckboxListTile(
                            title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            value: isSelected,
                            activeColor: Theme.of(context).colorScheme.primary,
                            tileColor: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300),
                            ),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedPlayers.add(member.uid);
                                } else {
                                  _selectedPlayers.remove(member.uid);
                                }
                              });
                            },
                          ),
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
