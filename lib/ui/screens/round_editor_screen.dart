import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_strings.dart';
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
    if (_selectedPlayers.length > AppConstants.maxStandardPlayers &&
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
                title: const Text(AppStrings.takePhotoOption),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await _storageService.takePhoto();
                  if (file != null) _setImage(type, file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text(AppStrings.chooseFromGalleryOption),
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
      SnackbarHelper.showError(
        context,
        AppStrings.selectAtLeastOnePlayerError,
      );
      return;
    }

    if ((widget.isFinishing || !widget.round.isActive) &&
        _selectedWinnerUid == null) {
      SnackbarHelper.showError(context, AppStrings.selectWinnerError);
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

      if (_selectedPlayers.length > AppConstants.maxStandardPlayers &&
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
          widget.isFinishing
              ? AppStrings.roundFinishedSuccess
              : AppStrings.roundUpdatedSuccess,
        );
      } else if (mounted) {
        SnackbarHelper.showError(context, AppStrings.saveRoundFailedError);
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, AppStrings.saveUploadError(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isFinishing
              ? AppStrings.finishRoundTitle
              : AppStrings.editRoundTitle,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(AppStrings.saving),
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
                      AppStrings.playersLabel,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(
                          AppConstants.cardBorderRadius,
                        ),
                        border: Border.all(color: AppColors.cardBorder),
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
                              borderRadius: BorderRadius.circular(
                                AppConstants.buttonBorderRadius,
                              ),
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

                                if (_selectedPlayers.length >
                                    AppConstants.maxStandardPlayers) {
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
                      AppStrings.selectWinnerLabel,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(
                          AppConstants.cardBorderRadius,
                        ),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: RadioGroup<String>(
                        groupValue: _selectedWinnerUid,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedWinnerUid = val);
                          }
                        },
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
                              activeColor: Theme.of(context).colorScheme.primary,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (!widget.isFinishing) ...[
                    const Text(
                      AppStrings.expansionsLabel,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(
                          AppConstants.cardBorderRadius,
                        ),
                        border: Border.all(color: AppColors.cardBorder),
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
                              borderRadius: BorderRadius.circular(
                                AppConstants.buttonBorderRadius,
                              ),
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
                      AppStrings.notesOptionalLabel,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: AppStrings.roundNotesHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.buttonBorderRadius,
                          ),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                  ],

                  const Text(
                    AppStrings.photosOptionalLabel,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.photosSubtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  RoundPhotoPickerCard(
                    label: AppStrings.winnerPhotoLabel,
                    bytes: _winnerPhotoBytes,
                    existingUrl: _existingWinnerPhotoUrl,
                    icon: Icons.person,
                    onPick: () => _pickImage('winner'),
                    onRemove: () => _removeImage('winner'),
                  ),
                  const SizedBox(height: 16),
                  RoundPhotoPickerCard(
                    label: AppStrings.boardPhotoLabel,
                    bytes: _boardPhotoBytes,
                    existingUrl: _existingBoardPhotoUrl,
                    icon: Icons.grid_on,
                    onPick: () => _pickImage('board'),
                    onRemove: () => _removeImage('board'),
                  ),
                  const SizedBox(height: 16),
                  RoundPhotoPickerCard(
                    label: AppStrings.groupPhotoLabel,
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
                        widget.isFinishing
                            ? AppStrings.finishRoundTitle
                            : AppStrings.saveChangesButton,
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
