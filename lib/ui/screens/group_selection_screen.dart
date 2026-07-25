import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../services/database_service.dart';
import '../../models/group_model.dart';
import '../../utils/snackbar_helper.dart';
import 'home_screen.dart';

class GroupSelectionScreen extends StatefulWidget {
  const GroupSelectionScreen({super.key});

  @override
  State<GroupSelectionScreen> createState() => _GroupSelectionScreenState();
}

class _GroupSelectionScreenState extends State<GroupSelectionScreen> {
  final DatabaseService _dbService = DatabaseService();
  final _groupNameController = TextEditingController();
  final _joinGroupIdController = TextEditingController();

  void _createGroup() async {
    String name = _groupNameController.text.trim();
    if (name.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    if (authProvider.user == null) return;
    
    bool success = await groupProvider.createGroup(name, authProvider.user!.uid);
    if (success && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  void _joinGroup() async {
    String groupId = _joinGroupIdController.text.trim();
    if (groupId.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    if (authProvider.user == null) return;
    
    bool joined = await groupProvider.joinGroup(groupId, authProvider.user!.uid);
    if (joined && mounted) {
      SnackbarHelper.showSuccess(context, 'Joined group! Select it from the list.');
      _joinGroupIdController.clear();
    } else {
      if (mounted) SnackbarHelper.showError(context, 'Failed to join group.');
    }
  }
  
  void _selectGroup(GroupModel group) async {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    await groupProvider.setActiveGroup(group);
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
          )
        ],
      ),
      body: Column(
        children: [
          // List of existing groups
          Expanded(
            child: StreamBuilder<List<GroupModel>>(
              stream: _dbService.getUserGroups(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading groups'));
                }
                
                final groups = snapshot.data ?? [];
                
                if (groups.isEmpty) {
                  return const Center(child: Text('You are not in any groups yet.'));
                }

                return ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(groups[index].name),
                      subtitle: Text('Members: ${groups[index].members.length}'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () => _selectGroup(groups[index]),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          // Join or Create UI
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Join a Group', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _joinGroupIdController,
                        decoration: const InputDecoration(hintText: 'Enter Group ID'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.group_add),
                      onPressed: _joinGroup,
                    )
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Create a Group', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _groupNameController,
                        decoration: const InputDecoration(hintText: 'New Group Name'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: _createGroup,
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
