import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../utils/snackbar_helper.dart';

void showJoinModal(
  BuildContext context,
  GroupProvider groupProvider,
  AuthProvider authProvider,
) {
  final TextEditingController joinGroupIdController = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(AppStrings.joinGroupTitle),
        content: TextField(
          controller: joinGroupIdController,
          decoration: const InputDecoration(
            labelText: AppStrings.groupIdLabel,
            border: OutlineInputBorder(),
            hintText: AppStrings.groupIdHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final groupId = joinGroupIdController.text.trim();
              if (groupId.isEmpty) {
                SnackbarHelper.showError(
                  dialogContext,
                  AppStrings.emptyGroupIdError,
                );
                return;
              }

              Navigator.pop(dialogContext);

              bool joined = await groupProvider.joinGroup(
                groupId,
                authProvider.user!.uid,
              );
              if (!context.mounted) return;
              if (joined) {
                SnackbarHelper.showSuccess(
                  context,
                  AppStrings.joinedGroupSuccess,
                );
              } else {
                SnackbarHelper.showError(
                  context,
                  AppStrings.joinGroupFailedError,
                );
              }
            },
            child: const Text(AppStrings.joinButton),
          ),
        ],
      );
    },
  );
}

void showCreateModal(
  BuildContext context,
  GroupProvider groupProvider,
  AuthProvider authProvider,
) {
  final TextEditingController createGroupNameController =
      TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(AppStrings.createGroupTitle),
        content: TextField(
          controller: createGroupNameController,
          decoration: const InputDecoration(
            labelText: AppStrings.groupNameLabel,
            border: OutlineInputBorder(),
            hintText: AppStrings.groupNameHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final groupName = createGroupNameController.text.trim();
              if (groupName.isEmpty) {
                SnackbarHelper.showError(
                  dialogContext,
                  AppStrings.emptyGroupNameError,
                );
                return;
              }

              Navigator.pop(dialogContext);

              bool created = await groupProvider.createGroup(
                groupName,
                authProvider.user!.uid,
              );
              if (!context.mounted) return;
              if (created) {
                SnackbarHelper.showSuccess(
                  context,
                  AppStrings.createdGroupSuccess,
                );
              } else {
                SnackbarHelper.showError(
                  context,
                  AppStrings.createGroupFailedError,
                );
              }
            },
            child: const Text(AppStrings.createButton),
          ),
        ],
      );
    },
  );
}
