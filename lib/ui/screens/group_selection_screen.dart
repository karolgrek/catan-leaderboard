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
                  // main.dart Provider will automatically switch to HomeScreen
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
          // Beautiful Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.hexagon, size: 80, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Catan Leaderboard',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a group to view rankings',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_off_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'You are not in any groups yet.\nCreate or Join one below!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            await groupProvider.setActiveGroup(group);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                  child: Icon(Icons.people, color: Theme.of(context).colorScheme.secondary),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        group.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('${group.members.length} members', style: TextStyle(color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
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
                      label: const Text('Join'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showCreateModal(context, groupProvider, authProvider),
                      icon: const Icon(Icons.add_circle),
                      label: const Text('Create'),
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
