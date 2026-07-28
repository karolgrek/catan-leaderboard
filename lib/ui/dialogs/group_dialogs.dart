import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../utils/snackbar_helper.dart';

void showJoinModal(BuildContext context, GroupProvider groupProvider, AuthProvider authProvider) {
  final TextEditingController joinGroupIdController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Join Group'),
        content: TextField(
          controller: joinGroupIdController,
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
              final groupId = joinGroupIdController.text.trim();
              if (groupId.isEmpty) {
                SnackbarHelper.showError(context, 'Please enter a Group ID.');
                return;
              }
              
              Navigator.pop(context); // close modal first
              
              bool joined = await groupProvider.joinGroup(groupId, authProvider.user!.uid);
              if (joined) {
                SnackbarHelper.showSuccess(context, 'Joined group! Select it from the list.');
              } else {
                SnackbarHelper.showError(context, 'Failed to join group.');
              }
            },
            child: const Text('Join'),
          )
        ],
      );
    },
  );
}

void showCreateModal(BuildContext context, GroupProvider groupProvider, AuthProvider authProvider) {
  final TextEditingController createGroupNameController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Create New Group'),
        content: TextField(
          controller: createGroupNameController,
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
              final groupName = createGroupNameController.text.trim();
              if (groupName.isEmpty) {
                SnackbarHelper.showError(context, 'Please enter a group name.');
                return;
              }
              
              Navigator.pop(context); // close modal first
              
              bool created = await groupProvider.createGroup(groupName, authProvider.user!.uid);
              if (created) {
                SnackbarHelper.showSuccess(context, 'Group created successfully!');
              } else {
                SnackbarHelper.showError(context, 'Failed to create group.');
              }
            },
            child: const Text('Create'),
          )
        ],
      );
    },
  );
}
