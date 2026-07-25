import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/session_model.dart';
import '../../providers/group_provider.dart';
import '../../utils/date_formatters.dart';
import '../../utils/snackbar_helper.dart';

class SessionDetailScreen extends StatelessWidget {
  final SessionModel session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    // We listen to the GroupProvider to get the up-to-date session object
    final groupProvider = Provider.of<GroupProvider>(context);
    
    // Find the latest version of this session from the provider
    final latestSessionIndex = groupProvider.sessions.indexWhere((s) => s.id == session.id);
    final currentSession = latestSessionIndex != -1 ? groupProvider.sessions[latestSessionIndex] : session;

    final members = groupProvider.groupMembers.where((m) => currentSession.selectedPlayers.contains(m.uid)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormatter.toReadableDate(currentSession.date)),
        actions: [
          if (currentSession.isActive)
            TextButton(
              onPressed: () async {
                bool success = await groupProvider.finishSession(currentSession.id);
                if (success) {
                  SnackbarHelper.showSuccess(context, 'Session finished!');
                } else {
                  SnackbarHelper.showError(context, 'Failed to finish session.');
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Finish Session'),
            )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (currentSession.notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Notes: ${currentSession.notes}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          
          Container(
            padding: const EdgeInsets.all(16),
            color: currentSession.isActive ? Colors.green.shade100 : Colors.grey.shade200,
            child: Row(
              children: [
                Icon(currentSession.isActive ? Icons.play_circle_fill : Icons.stop_circle, 
                  color: currentSession.isActive ? Colors.green : Colors.grey),
                const SizedBox(width: 8),
                Text(
                  currentSession.isActive ? 'Active Session (Add Winners)' : 'Finished Session',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text('Total Games: ${currentSession.gameWinners.length}'),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Players & Wins', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final player = members[index];
                final wins = currentSession.gameWinners.where((uid) => uid == player.uid).length;

                return ListTile(
                  title: Text(player.name),
                  subtitle: Text('Wins: $wins'),
                  trailing: currentSession.isActive
                      ? ElevatedButton.icon(
                          onPressed: () async {
                            bool success = await groupProvider.addWinnerToSession(currentSession.id, player.uid);
                            if (success) {
                              SnackbarHelper.showSuccess(context, '${player.name} won a game!');
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Win'),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
