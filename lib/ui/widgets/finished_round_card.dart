import 'package:flutter/material.dart';
import '../../models/session_model.dart';
import '../../providers/group_provider.dart';
import '../dialogs/round_dialogs.dart';

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
                    showEditRoundDialog(context, groupProvider, sessionId, round, members);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
