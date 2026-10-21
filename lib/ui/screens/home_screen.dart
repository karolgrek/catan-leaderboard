import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../utils/snackbar_helper.dart';
import '../dialogs/notifications_dialog.dart';
import '../widgets/leaderboard_section.dart';
import '../widgets/sessions_section.dart';
import 'session_editor_screen.dart';
import 'group_selection_screen.dart';

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
          const NotificationBellButton(),
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
            child: LeaderboardSection(leaderboard: leaderboard),
          ),
          // Sessions Section
          Expanded(
            flex: 4,
            child: SessionsSection(sessions: sessions),
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
