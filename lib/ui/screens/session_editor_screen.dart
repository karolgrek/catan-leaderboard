import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_strings.dart';
import '../../models/session_model.dart';
import '../../providers/group_provider.dart';
import '../../utils/date_formatters.dart';
import '../../utils/snackbar_helper.dart';

class SessionEditorScreen extends StatefulWidget {
  final SessionModel? session;

  const SessionEditorScreen({super.key, this.session});

  @override
  State<SessionEditorScreen> createState() => _SessionEditorScreenState();
}

class _SessionEditorScreenState extends State<SessionEditorScreen> {
  late DateTime _selectedDate;
  late TextEditingController _notesController;
  late List<String> _selectedPlayers;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.session?.date ?? DateTime.now();
    _notesController = TextEditingController(text: widget.session?.notes ?? '');
    _selectedPlayers = widget.session != null
        ? List<String>.from(widget.session!.selectedPlayers)
        : [];
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(AppConstants.minPickerYear),
      lastDate: DateTime(AppConstants.maxPickerYear),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveSession() async {
    if (_selectedPlayers.isEmpty) {
      SnackbarHelper.showError(
        context,
        AppStrings.selectAtLeastOnePlayerError,
      );
      return;
    }

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    bool success;

    if (widget.session != null) {
      success = await groupProvider.updateSession(
        widget.session!.id,
        _selectedDate,
        _notesController.text.trim(),
        _selectedPlayers,
      );
    } else {
      success = await groupProvider.createSession(
        _selectedDate,
        _notesController.text.trim(),
        _selectedPlayers,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      SnackbarHelper.showError(context, AppStrings.saveSessionFailedError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final members = groupProvider.groupMembers;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.session != null
              ? AppStrings.editSessionTitle
              : AppStrings.newSessionTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSession,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.cardBorderRadius,
                ),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
              color: AppColors.cardSurface,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: const Text(
                  AppStrings.sessionDateLabel,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(DateFormatter.toReadableDate(_selectedDate)),
                trailing: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                onTap: _pickDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.cardBorderRadius,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: AppStrings.notesOptionalLabel,
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 48.0),
                  child: Icon(Icons.edit_note),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            const Text(
              AppStrings.selectPlayersTitle,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: members.isEmpty
                  ? const Center(
                      child: Text(
                        AppStrings.noPlayersInGroup,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final isSelected =
                            _selectedPlayers.contains(member.uid);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: CheckboxListTile(
                            title: Text(
                              member.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            value: isSelected,
                            activeColor: Theme.of(context).colorScheme.primary,
                            tileColor: isSelected
                                ? AppColors.chitBackground
                                : AppColors.cardSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.buttonBorderRadius,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : AppColors.cardBorder,
                              ),
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
