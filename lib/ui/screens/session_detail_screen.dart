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
    final groupProvider = Provider.of<GroupProvider>(context);
    final latestSessionIndex = groupProvider.sessions.indexWhere((s) => s.id == session.id);
    final currentSession = latestSessionIndex != -1 ? groupProvider.sessions[latestSessionIndex] : session;
    final members = groupProvider.groupMembers.where((m) => currentSession.selectedPlayers.contains(m.uid)).toList();

    final activeRound = currentSession.rounds.where((r) => r.isActive).firstOrNull;
    final finishedRounds = currentSession.rounds.where((r) => !r.isActive).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormatter.toReadableDate(currentSession.date)),
        actions: [
          if (currentSession.isActive)
            TextButton(
              onPressed: () async {
                if (activeRound != null) {
                  SnackbarHelper.showError(context, 'Finish the active round first!');
                  return;
                }
                bool success = await groupProvider.finishSession(currentSession.id);
                if (success) SnackbarHelper.showSuccess(context, 'Session finished!');
              },
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Finish Session'),
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (currentSession.notes.isNotEmpty)
              Text('Notes: ${currentSession.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
            
            const SizedBox(height: 16),

            // Active Round Section
            if (activeRound != null)
              Card(
                color: Colors.green.shade50,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.play_arrow, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Active Round', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Select the Winner to finish the round:'),
                      const SizedBox(height: 8),
                      ...activeRound.players.map((uid) {
                        final player = members.firstWhere((m) => m.uid == uid);
                        return ListTile(
                          title: Text(player.name),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              bool success = await groupProvider.finishRound(currentSession.id, activeRound, player.uid);
                              if (success) SnackbarHelper.showSuccess(context, '${player.name} won the round!');
                            },
                            child: const Text('Winner'),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

            if (currentSession.isActive && activeRound == null)
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Start New Round'),
                onPressed: () {
                  _showStartRoundDialog(context, groupProvider, currentSession.id, members);
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),

            const SizedBox(height: 24),
            
            // Finished Rounds History
            const Text('Round History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (finishedRounds.isEmpty)
              const Text('No rounds finished yet.')
            else
              ...finishedRounds.asMap().entries.map((entry) {
                int index = entry.key;
                RoundModel round = entry.value;
                final winner = members.firstWhere((m) => m.uid == round.winnerUid, orElse: () => members.first);
                
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text('Winner: ${winner.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${round.players.length} players participated'),
                        if (round.expansions.isNotEmpty)
                          Text('Expansions: ${round.expansions.join(', ')}', style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showStartRoundDialog(BuildContext context, GroupProvider provider, String sessionId, List<dynamic> sessionMembers) {
    List<String> selectedForRound = [];
    List<String> selectedExpansions = [];
    final expansions = ['Seafarers', 'Cities & Knights', 'Traders & Barbarians', 'Explorers & Pirates'];
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Start Round'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Players', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...sessionMembers.map((player) {
                      bool isSelected = selectedForRound.contains(player.uid);
                      return CheckboxListTile(
                        title: Text(player.name),
                        value: isSelected,
                        dense: true,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedForRound.add(player.uid);
                            } else {
                              selectedForRound.remove(player.uid);
                            }
                          });
                        },
                      );
                    }).toList(),
                    const Divider(),
                    const Text('Expansions', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...expansions.map((exp) {
                      bool isSelected = selectedExpansions.contains(exp);
                      return CheckboxListTile(
                        title: Text(exp),
                        value: isSelected,
                        dense: true,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedExpansions.add(exp);
                            } else {
                              selectedExpansions.remove(exp);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedForRound.isEmpty) {
                      SnackbarHelper.showError(context, 'Select at least 1 player');
                      return;
                    }
                    Navigator.pop(context);
                    await provider.addRound(sessionId, selectedForRound, selectedExpansions);
                  },
                  child: const Text('Start'),
                )
              ],
            );
          },
        );
      },
    );
  }
}
