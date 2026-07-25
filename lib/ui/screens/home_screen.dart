import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../utils/date_formatters.dart';
import '../../utils/snackbar_helper.dart';
import 'session_editor_screen.dart';
import 'group_selection_screen.dart';
import 'session_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final group = groupProvider.activeGroup;

    if (groupProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (group == null) {
      return const GroupSelectionScreen();
    }

    final leaderboard = groupProvider.getLeaderboard();
    final sessions = groupProvider.sessions;

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Provider.of<GroupProvider>(context, listen: false).setActiveGroup(group).then((_) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GroupSelectionScreen()));
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Group ID',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: group.id));
              SnackbarHelper.showSuccess(context, 'Group ID copied to clipboard!');
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Leaderboard Section
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Leaderboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: leaderboard.isEmpty
                      ? const Center(child: Text('No members found.'))
                      : ListView.builder(
                          itemCount: leaderboard.length,
                          itemBuilder: (context, index) {
                            final data = leaderboard[index];
                            final user = data['user'];
                            final sessionsCount = data['sessionsPlayed'];
                            final winsCount = data['wins'];
                            
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: index == 0 ? Colors.amber : null, // Gold for 1st
                                child: Text('${index + 1}'),
                              ),
                              title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Games Played: $sessionsCount'),
                              trailing: Text('$winsCount Wins', style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Recent Sessions Section
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Sessions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: sessions.isEmpty
                      ? const Center(child: Text('No sessions recorded yet.'))
                      : ListView.builder(
                          itemCount: sessions.length,
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            return ListTile(
                              leading: Icon(
                                session.isActive ? Icons.play_circle_fill : Icons.check_circle,
                                color: session.isActive ? Colors.green : Colors.grey,
                                size: 32,
                              ),
                              title: Text(DateFormatter.toReadableDate(session.date)),
                              subtitle: Text('${session.gameWinners.length} games played'),
                              trailing: const Icon(Icons.chevron_right),
                              tileColor: session.isActive ? Colors.green.withOpacity(0.1) : null,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SessionDetailScreen(session: session),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SessionEditorScreen()),
          );
        },
        tooltip: 'New Session',
        child: const Icon(Icons.add),
      ),
    );
  }
}
