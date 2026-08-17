import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/session_model.dart';
import '../../providers/group_provider.dart';
import '../../services/storage_service.dart';
import '../../utils/snackbar_helper.dart';

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

  File? _winnerPhoto;
  File? _boardPhoto;
  File? _partyPhoto;

  String? _existingWinnerPhotoUrl;
  String? _existingBoardPhotoUrl;
  String? _existingPartyPhotoUrl;
  
  final expansionsList = ['Seafarers', 'Cities & Knights', 'Traders & Barbarians', 'Explorers & Pirates'];

  @override
  void initState() {
    super.initState();
    _selectedPlayers = List<String>.from(widget.round.players);
    _selectedExpansions = List<String>.from(widget.round.expansions);
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
      }
    );
  }

  void _setImage(String type, File? file) {
    setState(() {
      if (type == 'winner') {
        _winnerPhoto = file;
        if (file != null) _existingWinnerPhotoUrl = null; // overriding existing
      }
      if (type == 'board') {
        _boardPhoto = file;
        if (file != null) _existingBoardPhotoUrl = null;
      }
      if (type == 'party') {
        _partyPhoto = file;
        if (file != null) _existingPartyPhotoUrl = null;
      }
    });
  }
  
  void _removeExistingImage(String type) {
    setState(() {
      if (type == 'winner') _existingWinnerPhotoUrl = null;
      if (type == 'board') _existingBoardPhotoUrl = null;
      if (type == 'party') _existingPartyPhotoUrl = null;
    });
  }

  Future<void> _saveRound() async {
    if (_selectedPlayers.isEmpty) {
      SnackbarHelper.showError(context, 'Select at least 1 player');
      return;
    }
    
    // If we are finishing or it's an already finished round, we need a winner
    if ((widget.isFinishing || !widget.round.isActive) && _selectedWinnerUid == null) {
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

      // Upload new photos if they exist
      if (_winnerPhoto != null) {
        finalWinnerPhotoUrl = await _storageService.uploadRoundPhoto(_winnerPhoto!, groupId, widget.sessionId, widget.round.id, 'winner');
        if (finalWinnerPhotoUrl == null) {
          if (mounted) SnackbarHelper.showError(context, 'Failed to upload Winner Photo.');
          setState(() => _isLoading = false);
          return;
        }
      }
      if (_boardPhoto != null) {
        finalBoardPhotoUrl = await _storageService.uploadRoundPhoto(_boardPhoto!, groupId, widget.sessionId, widget.round.id, 'board');
        if (finalBoardPhotoUrl == null) {
          if (mounted) SnackbarHelper.showError(context, 'Failed to upload Board Photo.');
          setState(() => _isLoading = false);
          return;
        }
      }
      if (_partyPhoto != null) {
        finalPartyPhotoUrl = await _storageService.uploadRoundPhoto(_partyPhoto!, groupId, widget.sessionId, widget.round.id, 'party');
        if (finalPartyPhotoUrl == null) {
          if (mounted) SnackbarHelper.showError(context, 'Failed to upload Party Photo.');
          setState(() => _isLoading = false);
          return;
        }
      }

      final updatedRound = RoundModel(
        id: widget.round.id,
        players: _selectedPlayers,
        winnerUid: _selectedWinnerUid,
        isActive: widget.isFinishing ? false : widget.round.isActive, // If finishing, make false. Otherwise keep status.
        expansions: _selectedExpansions,
        notes: _notesController.text.trim(),
        winnerPhotoUrl: finalWinnerPhotoUrl,
        boardPhotoUrl: finalBoardPhotoUrl,
        partyPhotoUrl: finalPartyPhotoUrl,
      );

      bool success = await groupProvider.updateRound(widget.sessionId, updatedRound);
      
      if (success && mounted) {
        Navigator.pop(context);
        SnackbarHelper.showSuccess(context, widget.isFinishing ? 'Round finished successfully!' : 'Round updated!');
      } else {
        if (mounted) SnackbarHelper.showError(context, 'Failed to save round.');
      }
    } catch (e) {
      if (mounted) SnackbarHelper.showError(context, 'An error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPhotoPicker(String label, String type, File? file, String? existingUrl, IconData icon) {
    bool hasImage = file != null || existingUrl != null;
    
    return GestureDetector(
      onTap: () => _pickImage(type),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          image: hasImage
              ? DecorationImage(
                  image: file != null ? FileImage(file) as ImageProvider : NetworkImage(existingUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: !hasImage 
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: Colors.grey.shade500),
                  const SizedBox(height: 8),
                  Text(label, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                  Text('Tap to add photo', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              )
            : Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 16,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.white),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        if (file != null) _setImage(type, null);
                        if (existingUrl != null) _removeExistingImage(type);
                      },
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFinishing ? 'Finish Round' : 'Edit Round'),
      ),
      body: _isLoading 
        ? const Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Saving...'),
            ],
          ))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.isFinishing) ...[
                  const Text('Players', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: widget.members.map((player) {
                        bool isSelected = _selectedPlayers.contains(player.uid);
                        return CheckboxListTile(
                          title: Text(player.name),
                          value: isSelected,
                          dense: true,
                          activeColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedPlayers.add(player.uid);
                              } else {
                                _selectedPlayers.remove(player.uid);
                                if (_selectedWinnerUid == player.uid) _selectedWinnerUid = null;
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Winner Selector (Shown if finishing or if it's already finished)
                if (widget.isFinishing || !widget.round.isActive) ...[
                  const Text('Select Winner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: widget.members.where((m) => _selectedPlayers.contains(m.uid)).map((member) {
                        final isSelected = _selectedWinnerUid == member.uid;
                        return RadioListTile<String>(
                          title: Text(member.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          value: member.uid,
                          groupValue: _selectedWinnerUid,
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedWinnerUid = val);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (!widget.isFinishing) ...[
                  const Text('Expansions (Optional)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

                  const Text('Notes (Optional)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      hintText: 'Any special notes for this round?',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                ],
                
                const Text('Photos (Optional)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Add memories from this round!', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                const SizedBox(height: 16),
                
                _buildPhotoPicker('Winner Photo', 'winner', _winnerPhoto, _existingWinnerPhotoUrl, Icons.emoji_events),
                const SizedBox(height: 16),
                _buildPhotoPicker('Board Photo', 'board', _boardPhoto, _existingBoardPhotoUrl, Icons.grid_on),
                const SizedBox(height: 16),
                _buildPhotoPicker('Party Photo', 'party', _partyPhoto, _existingPartyPhotoUrl, Icons.groups),
                
                const SizedBox(height: 48),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveRound,
                    child: Text(widget.isFinishing ? 'Finish Round' : 'Save Changes', style: const TextStyle(fontSize: 18)),
                  ),
                )
              ],
            ),
          ),
    );
  }
}
