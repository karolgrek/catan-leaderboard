import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../dialogs/group_dialogs.dart';
import '../dialogs/notifications_dialog.dart';

class GroupSelectionScreen extends StatelessWidget {
  const GroupSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);

    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(child: Text(AppStrings.notAuthenticated)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        actions: [
          const NotificationBellButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppConstants.drawerTopRadius),
                bottomRight: Radius.circular(AppConstants.drawerTopRadius),
              ),
              border: const Border(
                bottom: BorderSide(color: AppColors.appBarTrim, width: 3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.hexagon,
                  size: 72,
                  color: AppColors.chitBackground,
                ),
                const SizedBox(height: 12),
                const Text(
                  AppStrings.appTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.selectGroupSubtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: StreamBuilder(
              stream: groupProvider.getUserGroups(authProvider.user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(AppStrings.errorLoadingGroups),
                  );
                }

                final List<dynamic> groups = snapshot.data ?? [];

                if (groups.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_off_outlined,
                          size: 64,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          AppStrings.noGroupsMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
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
                          borderRadius: BorderRadius.circular(
                            AppConstants.cardBorderRadius,
                          ),
                          onTap: () async {
                            await groupProvider.setActiveGroup(group);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.chitBackground,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primaryBrick,
                                      width: 1.8,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.people,
                                    color: AppColors.primaryBrick,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        group.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppStrings.membersCount(
                                          group.members.length,
                                        ),
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.textSecondary,
                                  size: 16,
                                ),
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

          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AppColors.drawerSurface.withValues(alpha: 0.94),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.drawerTopRadius),
                topRight: Radius.circular(AppConstants.drawerTopRadius),
              ),
              border: const Border(
                top: BorderSide(color: AppColors.drawerBorder, width: 1.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          showJoinModal(context, groupProvider, authProvider),
                      icon: const Icon(Icons.group_add),
                      label: const Text(AppStrings.joinButton),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          showCreateModal(context, groupProvider, authProvider),
                      icon: const Icon(Icons.add_circle),
                      label: const Text(AppStrings.createButton),
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
