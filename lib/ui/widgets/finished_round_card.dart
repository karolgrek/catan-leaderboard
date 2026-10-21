import 'package:flutter/material.dart';
import '../../models/session_model.dart';
import '../../providers/group_provider.dart';
import '../screens/round_editor_screen.dart';
import '../theme/app_theme.dart';
import 'round_photo_picker.dart';

class FinishedRoundCard extends StatelessWidget {
  final int index;
  final RoundModel round;
  final dynamic winner;
  final List<dynamic> members;
  final String sessionId;
  final GroupProvider groupProvider;

  const FinishedRoundCard({
    super.key,
    required this.index,
    required this.round,
    required this.winner,
    required this.members,
    required this.sessionId,
    required this.groupProvider,
  });

  void _openEditor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoundEditorScreen(
          sessionId: sessionId,
          round: round,
          members: members,
          isFinishing: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhotos = round.winnerPhotoUrl != null ||
        round.boardPhotoUrl != null ||
        round.partyPhotoUrl != null;

    final playerNames = round.players.map((uid) {
      final p = members
          .cast<dynamic>()
          .firstWhere((m) => m.uid == uid, orElse: () => null);
      return p != null ? p.name : uid;
    }).join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      elevation: 0,
      color: AppColors.cardSurface,
      child: InkWell(
        onTap: () => _openEditor(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.chitBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.chitBorder,
                    width: 1.8,
                  ),
                ),
                child: Center(
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Winner: ${winner.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Players: $playerNames',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final displayExpansions = List<String>.from(
                          round.expansions
                              .where((e) => e != 'Základ' && e != 'Base Game')
                              .map(normalizeExpansionName),
                        );
                        if (round.players.length > 4 &&
                            !displayExpansions.contains(
                              kFiveSixPlayerExtension,
                            )) {
                          displayExpansions.insert(0, kFiveSixPlayerExtension);
                        }
                        if (displayExpansions.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Expansions: ${displayExpansions.join(', ')}',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                              color: AppColors.primaryBrick,
                            ),
                          ),
                        );
                      },
                    ),
                    if (round.notes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Notes: ${round.notes}',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    if (hasPhotos)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            if (round.winnerPhotoUrl != null)
                              RoundPhotoThumbnail(
                                url: round.winnerPhotoUrl!,
                                label: 'Winner',
                                icon: Icons.person,
                              ),
                            if (round.boardPhotoUrl != null)
                              RoundPhotoThumbnail(
                                url: round.boardPhotoUrl!,
                                label: 'Board',
                                icon: Icons.grid_on,
                              ),
                            if (round.partyPhotoUrl != null)
                              RoundPhotoThumbnail(
                                url: round.partyPhotoUrl!,
                                label: 'Party',
                                icon: Icons.groups,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 2.0),
                child: Icon(
                  Icons.edit_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
