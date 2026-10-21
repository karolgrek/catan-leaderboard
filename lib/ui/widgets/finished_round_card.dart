import 'package:flutter/material.dart';
import '../../models/session_model.dart';
import '../../providers/group_provider.dart';
import '../screens/round_editor_screen.dart';

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
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 0,
      color: Colors.white,
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
                  color: Colors.amber.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
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
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Players: $playerNames',
                      style: TextStyle(
                        color: Colors.grey.shade700,
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
                              color: Colors.deepOrange,
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
                              _buildThumbnail(
                                context,
                                round.winnerPhotoUrl!,
                                'Winner',
                                Icons.person,
                              ),
                            if (round.boardPhotoUrl != null)
                              _buildThumbnail(
                                context,
                                round.boardPhotoUrl!,
                                'Board',
                                Icons.grid_on,
                              ),
                            if (round.partyPhotoUrl != null)
                              _buildThumbnail(
                                context,
                                round.partyPhotoUrl!,
                                'Party',
                                Icons.groups,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Icon(
                  Icons.edit_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(
    BuildContext context,
    String url,
    String label,
    IconData icon,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InteractiveViewer(
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: 300,
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey.shade400,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) =>
                  Icon(icon, size: 24, color: Colors.grey.shade400),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                color: Colors.black.withOpacity(0.55),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
