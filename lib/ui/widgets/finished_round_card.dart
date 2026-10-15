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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Winner: ${winner.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${round.players.length} players participated', style: TextStyle(color: Colors.grey.shade600)),
                  if (round.expansions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text('Expansions: ${round.expansions.join(', ')}', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.deepOrange)),
                    ),
                  if (round.notes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text('Notes: ${round.notes}', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.blueGrey)),
                    ),
                  
                  if (round.winnerPhotoUrl != null || round.boardPhotoUrl != null || round.partyPhotoUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          if (round.winnerPhotoUrl != null) _buildThumbnail(context, round.winnerPhotoUrl!, Icons.emoji_events),
                          if (round.boardPhotoUrl != null) _buildThumbnail(context, round.boardPhotoUrl!, Icons.grid_on),
                          if (round.partyPhotoUrl != null) _buildThumbnail(context, round.partyPhotoUrl!, Icons.groups),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.grey.shade400),
                  onPressed: () {
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
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, String url, IconData icon) {
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
                          child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey.shade900,
                        child: const Center(child: Text('Failed to load image', style: TextStyle(color: Colors.white))),
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
        margin: const EdgeInsets.only(right: 8),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey.shade400)));
          },
          errorBuilder: (context, error, stackTrace) => Icon(icon, size: 20, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}
