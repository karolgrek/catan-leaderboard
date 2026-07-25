import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../utils/snackbar_helper.dart';
import 'home_screen.dart';

class GroupSelectionScreen extends StatefulWidget {
  const GroupSelectionScreen({super.key});

  @override
  State<GroupSelectionScreen> createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen> {
  final TextEditingController _joinGroupIdController = TextEditingController();
  final TextEditingController _createGroupNameController = TextEditingController();

  @override
  void dispose() {
    _joinGroupIdController.dispose();
    _createGroupNameController.dispose();
    super.dispose();
  }

  void _showJoinModal(BuildContext context, GroupProvider groupProvider, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Join Group'),
          content: TextField(
            controller: _joinGroupIdController,
            decoration: const InputDecoration(
              labelText: 'Group ID',
              border: OutlineInputBorder(),
              hintText: 'Enter 20-character Group ID',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final groupId = _joinGroupIdController.text.trim();
                if (groupId.isEmpty) {
                  SnackbarHelper.showError(context, 'Please enter a Group ID.');
                  return;
                }
                
                Navigator.pop(context); // close modal first
                
                bool joined = await groupProvider.joinGroup(groupId, authProvider.user!.uid);
                if (joined && mounted) {
                  SnackbarHelper.showSuccess(context, 'Joined group! Select it from the list.');
                  _joinGroupIdController.clear();
                } else {
                  if (mounted) SnackbarHelper.showError(context, 'Failed to join group.');
                }
              },
              child: const Text('Join'),
            )
          ],
        );
      },
    );
  }

  void _showCreateModal(BuildContext context, GroupProvider groupProvider, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Group'),
          content: TextField(
            controller: _createGroupNameController,
            decoration: const InputDecoration(
              labelText: 'Group Name',
              border: OutlineInputBorder(),
              hintText: 'e.g. Weekend Boardgamers',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final groupName = _createGroupNameController.text.trim();
                if (groupName.isEmpty) {
                  SnackbarHelper.showError(context, 'Please enter a group name.');
                  return;
                }
                
                Navigator.pop(context); // close modal first
                
                bool created = await groupProvider.createGroup(groupName, authProvider.user!.uid);
                if (created && mounted) {
                  SnackbarHelper.showSuccess(context, 'Group created successfully!');
                  _createGroupNameController.clear();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                } else {
                  if (mounted) SnackbarHelper.showError(context, 'Failed to create group.');
                }
              },
              child: const Text('Create'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);

    if (authProvider.user == null) {
      return const Scaffold(body: Center(child: Text('Not authenticated.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catan Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.signOut();
            },
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // Beautiful Center Logo/Icon
          const Center(
            child: Column(
              children: [
                Icon(Icons.hexagon, size: 80, color: Colors.orange), // Catan hex vibe
                SizedBox(height: 16),
                Text(
                  'Welcome to THE Catan leaderboard',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text('Select a group to view the leaderboard'),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // List of existing groups
          Expanded(
            child: StreamBuilder(
              stream: groupProvider.getUserGroups(authProvider.user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading groups.'));
                }

                final List<dynamic> groups = snapshot.data ?? [];

                if (groups.isEmpty) {
                  return const Center(
                    child: Text('You are not in any groups yet.\nCreate or Join one below!'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text('${group.members.length} members'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          await groupProvider.setActiveGroup(group);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ]
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showJoinModal(context, groupProvider, authProvider),
                      icon: const Icon(Icons.group_add),
                      label: const Text('Join Group'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showCreateModal(context, groupProvider, authProvider),
                      icon: const Icon(Icons.add_circle),
                      label: const Text('Create Group'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
