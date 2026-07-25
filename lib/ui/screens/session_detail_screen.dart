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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (currentSession.notes.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes, color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(currentSession.notes, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16))),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),

            // Active Round Section
            if (activeRound != null)
              Card(
                color: Colors.green.shade50,
                elevation: 4,
                shadowColor: Colors.green.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.green, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.play_circle_fill, color: Colors.green, size: 28),
                          SizedBox(width: 12),
                          Text('Active Round', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Who collected 10 victory points first?', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ...activeRound.players.map((uid) {
                        final player = members.firstWhere((m) => m.uid == uid);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              bool success = await groupProvider.finishRound(currentSession.id, activeRound, player.uid);
                              if (success) SnackbarHelper.showSuccess(context, '${player.name} won the round!');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Icon(Icons.emoji_events, color: Colors.amber),
                                ],
                              ),
                            ),
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
                label: const Text('Start New Round', style: TextStyle(fontSize: 18)),
                onPressed: () {
                  _showStartRoundDialog(context, groupProvider, currentSession.id, members);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Theme.of(context).colorScheme.tertiary, // Green button for new round
                ),
              ),

            const SizedBox(height: 32),
            
            // Finished Rounds History
            Row(
              children: [
                Icon(Icons.history, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text('Round History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            if (finishedRounds.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text('No rounds finished yet.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                ),
              )
            else
              ...finishedRounds.asMap().entries.map((entry) {
                int index = entry.key;
                RoundModel round = entry.value;
                final winner = members.firstWhere((m) => m.uid == round.winnerUid, orElse: () => members.first);
                
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
                            ],
                          ),
                        ),
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.play_circle_fill, color: Colors.deepOrange),
                  SizedBox(width: 8),
                  Text('Start Round'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Players', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ...sessionMembers.map((player) {
                      bool isSelected = selectedForRound.contains(player.uid);
                      return CheckboxListTile(
                        title: Text(player.name),
                        value: isSelected,
                        dense: true,
                        activeColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(),
                    ),
                    const Text('Expansions (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ...expansions.map((exp) {
                      bool isSelected = selectedExpansions.contains(exp);
                      return CheckboxListTile(
                        title: Text(exp),
                        value: isSelected,
                        dense: true,
                        activeColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
