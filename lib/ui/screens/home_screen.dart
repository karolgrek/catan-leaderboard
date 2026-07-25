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
            Provider.of<GroupProvider>(context, listen: false).clearActiveGroup();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Seed Fake Users (Debug)',
            onPressed: () async {
              bool success = await groupProvider.seedTestUsers();
              if (success) {
                SnackbarHelper.showSuccess(context, 'Seeded 4 fake users to this group!');
              } else {
                SnackbarHelper.showError(context, 'Failed to seed users.');
              }
            },
          ),
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
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text('Leaderboard', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: leaderboard.isEmpty
                      ? const Center(child: Text('No members found.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: leaderboard.length,
                          itemBuilder: (context, index) {
                            final data = leaderboard[index];
                            final user = data['user'];
                            final sessionsCount = data['sessionsPlayed'];
                            final winsCount = data['wins'];
                            
                            Color rankColor;
                            if (index == 0) rankColor = const Color(0xFFFFD700); // Gold
                            else if (index == 1) rankColor = const Color(0xFFC0C0C0); // Silver
                            else if (index == 2) rankColor = const Color(0xFFCD7F32); // Bronze
                            else rankColor = Colors.grey.shade200;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: index == 0 ? const Color(0xFFFFFDF0) : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: index == 0 ? BorderSide(color: rankColor.withOpacity(0.5), width: 2) : BorderSide.none,
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: rankColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: rankColor, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: index < 3 ? Colors.black87 : Colors.grey.shade700),
                                    ),
                                  ),
                                ),
                                title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                subtitle: Text('Rounds Played: $sessionsCount'),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('$winsCount', style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold)),
                                    const Text('Wins', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          // Recent Sessions Section
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Row(
                      children: [
                        Icon(Icons.history, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Recent Sessions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: sessions.isEmpty
                        ? const Center(child: Text('No sessions recorded yet.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: sessions.length,
                            itemBuilder: (context, index) {
                              final session = sessions[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: session.isActive ? Colors.green.shade50 : Colors.grey.shade50,
                                elevation: session.isActive ? 2 : 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: session.isActive ? const BorderSide(color: Colors.green, width: 1) : BorderSide(color: Colors.grey.shade300, width: 1),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: session.isActive ? Colors.green.withOpacity(0.2) : Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      session.isActive ? Icons.play_arrow : Icons.check,
                                      color: session.isActive ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                  title: Text(DateFormatter.toReadableDate(session.date), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${session.rounds.length} rounds recorded'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SessionDetailScreen(session: session),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SessionEditorScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Session'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
