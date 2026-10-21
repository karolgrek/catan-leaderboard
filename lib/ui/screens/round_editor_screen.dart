import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/session_model.dart';
import '../../providers/group_provider.dart';
import '../../services/storage_service.dart';
import '../../utils/snackbar_helper.dart';
import '../widgets/round_photo_picker.dart';

class RoundEditorScreen extends StatefulWidget {
  final String sessionId;
  final RoundModel round;
  final List<dynamic> members;
  final bool isFinishing;
  final String? preselectedWinnerUid;

  const RoundEditorScreen({
    super.key,
    required this.sessionId,
    required this.round,
    required this.members,
    this.isFinishing = false,
    this.preselectedWinnerUid,
  });

  @override
  State<RoundEditorScreen> createState() => _RoundEditorScreenState();
}

class _RoundEditorScreenState extends State<RoundEditorScreen> {
  final StorageService _storageService = StorageService();

  late List<String> _selectedPlayers;
  late List<String> _selectedExpansions;
  late TextEditingController _notesController;
  String? _selectedWinnerUid;

  bool _isLoading = false;

  XFile? _winnerPhoto;
  Uint8List? _winnerPhotoBytes;
  XFile? _boardPhoto;
  Uint8List? _boardPhotoBytes;
  XFile? _partyPhoto;
  Uint8List? _partyPhotoBytes;

  String? _existingWinnerPhotoUrl;
  String? _existingBoardPhotoUrl;
  String? _existingPartyPhotoUrl;

  final expansionsList = kCatanExpansions;

  @override
  void initState() {
    super.initState();
    _selectedPlayers = List<String>.from(widget.round.players);
    _selectedExpansions = widget.round.expansions
        .where((e) => e != 'Základ' && e != 'Base Game')
        .map(normalizeExpansionName)
        .toList();
    if (_selectedPlayers.length > 4 &&
        !_selectedExpansions.contains(kFiveSixPlayerExtension)) {
      _selectedExpansions.add(kFiveSixPlayerExtension);
    }
    _notesController = TextEditingController(text: widget.round.notes);

    if (widget.isFinishing) {
      _selectedWinnerUid = widget.preselectedWinnerUid;
    } else {
      _selectedWinnerUid = widget.round.winnerUid;
    }

    _existingWinnerPhotoUrl = widget.round.winnerPhotoUrl;
    _existingBoardPhotoUrl = widget.round.boardPhotoUrl;
    _existingPartyPhotoUrl = widget.round.partyPhotoUrl;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _storageService.takePhoto();
                  if (file != null) _setImage(type, file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _storageService.pickImage();
                  if (file != null) _setImage(type, file);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setImage(String type, XFile? file) async {
    Uint8List? bytes;
    if (file != null) {
      bytes = await file.readAsBytes();
    }
    setState(() {
      if (type == 'winner') {
        _winnerPhoto = file;
        _winnerPhotoBytes = bytes;
        if (file != null) _existingWinnerPhotoUrl = null;
      }
      if (type == 'board') {
        _boardPhoto = file;
        _boardPhotoBytes = bytes;
        if (file != null) _existingBoardPhotoUrl = null;
      }
      if (type == 'party') {
        _partyPhoto = file;
        _partyPhotoBytes = bytes;
        if (file != null) _existingPartyPhotoUrl = null;
      }
    });
  }

  void _removeImage(String type) {
    setState(() {
      if (type == 'winner') {
        _existingWinnerPhotoUrl = null;
        _winnerPhoto = null;
        _winnerPhotoBytes = null;
      }
      if (type == 'board') {
        _existingBoardPhotoUrl = null;
        _boardPhoto = null;
        _boardPhotoBytes = null;
      }
      if (type == 'party') {
        _existingPartyPhotoUrl = null;
        _partyPhoto = null;
        _partyPhotoBytes = null;
      }
    });
  }

  Future<void> _saveRound() async {
    if (_selectedPlayers.isEmpty) {
      SnackbarHelper.showError(context, 'Select at least 1 player');
      return;
    }

    if ((widget.isFinishing || !widget.round.isActive) &&
        _selectedWinnerUid == null) {
      SnackbarHelper.showError(context, 'Please select a winner');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final groupId = groupProvider.activeGroup!.id;

      String? finalWinnerPhotoUrl = _existingWinnerPhotoUrl;
      String? finalBoardPhotoUrl = _existingBoardPhotoUrl;
      String? finalPartyPhotoUrl = _existingPartyPhotoUrl;

      if (_winnerPhotoBytes != null) {
        finalWinnerPhotoUrl = await _storageService.uploadRoundPhotoBytes(
          bytes: _winnerPhotoBytes!,
          fileNameHint: _winnerPhoto?.name ?? 'winner.jpg',
          groupId: groupId,
          sessionId: widget.sessionId,
          roundId: widget.round.id,
          photoType: 'winner',
        );
      }
      if (_boardPhotoBytes != null) {
        finalBoardPhotoUrl = await _storageService.uploadRoundPhotoBytes(
          bytes: _boardPhotoBytes!,
          fileNameHint: _boardPhoto?.name ?? 'board.jpg',
          groupId: groupId,
          sessionId: widget.sessionId,
          roundId: widget.round.id,
          photoType: 'board',
        );
      }
      if (_partyPhotoBytes != null) {
        finalPartyPhotoUrl = await _storageService.uploadRoundPhotoBytes(
          bytes: _partyPhotoBytes!,
          fileNameHint: _partyPhoto?.name ?? 'party.jpg',
          groupId: groupId,
          sessionId: widget.sessionId,
          roundId: widget.round.id,
          photoType: 'party',
        );
      }

      if (_selectedPlayers.length > 4 &&
          !_selectedExpansions.contains(kFiveSixPlayerExtension)) {
        _selectedExpansions.add(kFiveSixPlayerExtension);
      }

      final updatedRound = RoundModel(
        id: widget.round.id,
        players: _selectedPlayers,
        winnerUid: _selectedWinnerUid,
        isActive: widget.isFinishing ? false : widget.round.isActive,
        expansions: _selectedExpansions,
        notes: _notesController.text.trim(),
        winnerPhotoUrl: finalWinnerPhotoUrl,
        boardPhotoUrl: finalBoardPhotoUrl,
        partyPhotoUrl: finalPartyPhotoUrl,
      );

      bool success = await groupProvider.updateRound(
        widget.sessionId,
        updatedRound,
      );

      if (success && mounted) {
        Navigator.pop(context);
        SnackbarHelper.showSuccess(
          context,
          widget.isFinishing ? 'Round finished successfully!' : 'Round updated!',
        );
      } else if (mounted) {
        SnackbarHelper.showError(context, 'Failed to save round.');
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Error saving/uploading: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFinishing ? 'Finish Round' : 'Edit Round'),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Saving...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.isFinishing) ...[
                    const Text(
                      'Players',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: widget.members.map((player) {
                          bool isSelected =
                              _selectedPlayers.contains(player.uid);
                          return CheckboxListTile(
                            title: Text(player.name),
                            value: isSelected,
                            dense: true,
                            activeColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedPlayers.add(player.uid);
                                } else {
                                  _selectedPlayers.remove(player.uid);
                                  if (_selectedWinnerUid == player.uid) {
                                    _selectedWinnerUid = null;
                                  }
                                }

                                if (_selectedPlayers.length > 4) {
                                  if (!_selectedExpansions.contains(
                                    kFiveSixPlayerExtension,
                                  )) {
                                    _selectedExpansions
                                        .add(kFiveSixPlayerExtension);
                                  }
                                } else {
                                  _selectedExpansions
                                      .remove(kFiveSixPlayerExtension);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (widget.isFinishing || !widget.round.isActive) ...[
                    const Text(
                      'Select Winner',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: widget.members
                            .where((m) => _selectedPlayers.contains(m.uid))
                            .map((member) {
                          final isSelected = _selectedWinnerUid == member.uid;
                          return RadioListTile<String>(
                            title: Text(
                              member.name,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            value: member.uid,
                            groupValue: _selectedWinnerUid,
                            activeColor: Theme.of(context).colorScheme.primary,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedWinnerUid = val);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (!widget.isFinishing) ...[
                    const Text(
                      'Expansions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: expansionsList.map((exp) {
                          bool isSelected = _selectedExpansions.contains(exp);
                          return CheckboxListTile(
                            title: Text(exp),
                            value: isSelected,
                            dense: true,
                            activeColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedExpansions.add(exp);
                                } else {
                                  _selectedExpansions.remove(exp);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Notes (Optional)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Round notes...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                  ],

                  const Text(
                    'Photos (Optional)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add memories and photos from this round!',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  RoundPhotoPickerCard(
                    label: 'Winner Photo',
                    bytes: _winnerPhotoBytes,
                    existingUrl: _existingWinnerPhotoUrl,
                    icon: Icons.person,
                    onPick: () => _pickImage('winner'),
                    onRemove: () => _removeImage('winner'),
                  ),
                  const SizedBox(height: 16),
                  RoundPhotoPickerCard(
                    label: 'Board Photo',
                    bytes: _boardPhotoBytes,
                    existingUrl: _existingBoardPhotoUrl,
                    icon: Icons.grid_on,
                    onPick: () => _pickImage('board'),
                    onRemove: () => _removeImage('board'),
                  ),
                  const SizedBox(height: 16),
                  RoundPhotoPickerCard(
                    label: 'Group Photo',
                    bytes: _partyPhotoBytes,
                    existingUrl: _existingPartyPhotoUrl,
                    icon: Icons.groups,
                    onPick: () => _pickImage('party'),
                    onRemove: () => _removeImage('party'),
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveRound,
                      child: Text(
                        widget.isFinishing ? 'Finish Round' : 'Save Changes',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
