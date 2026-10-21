import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/notification_model.dart';
import '../../providers/group_provider.dart';
import '../../utils/date_formatters.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/web_notification_bridge.dart';

class NotificationBellButton extends StatefulWidget {
  const NotificationBellButton({super.key});

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final permission = WebNotificationBridge.getPermissionStatus();
    final bool needsPermission = permission == 'default';
    final int count = groupProvider.notifications.length;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(
            needsPermission
                ? Icons.notifications_paused
                : Icons.notifications_outlined,
          ),
          tooltip: AppStrings.notificationsTooltip,
          onPressed: () async {
            await showNotificationsDialog(context);
            if (mounted) {
              setState(() {});
            }
          },
        ),
        if (needsPermission || count > 0)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: needsPermission ? Colors.amber : Colors.greenAccent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

Future<void> showNotificationsDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (ctx) => const _NotificationsDialogContent(),
  );
}

class _NotificationsDialogContent extends StatefulWidget {
  const _NotificationsDialogContent();

  @override
  State<_NotificationsDialogContent> createState() =>
      _NotificationsDialogContentState();
}

class _NotificationsDialogContentState
    extends State<_NotificationsDialogContent> {
  late String _permissionStatus;

  @override
  void initState() {
    super.initState();
    _permissionStatus = WebNotificationBridge.getPermissionStatus();
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'left_behind':
        return Icons.person_off_outlined;
      case 'round_winner':
        return Icons.emoji_events_outlined;
      case 'dethroned':
        return Icons.military_tech_outlined;
      case 'win_streak':
        return Icons.local_fire_department_outlined;
      case 'first_win':
        return Icons.auto_awesome_outlined;
      case 'photos_uploaded':
        return Icons.photo_camera_outlined;
      case 'session_summary':
        return Icons.flag_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'left_behind':
        return Colors.deepOrange;
      case 'round_winner':
        return Colors.amber.shade800;
      case 'dethroned':
        return Colors.purple;
      case 'win_streak':
        return AppColors.errorRed;
      case 'first_win':
        return Colors.teal;
      case 'photos_uploaded':
        return Colors.blue;
      case 'session_summary':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final activeGroup = groupProvider.activeGroup;
    final List<NotificationModel> notifications = activeGroup != null
        ? groupProvider.notifications
            .where((n) => n.groupId == activeGroup.id)
            .toList()
        : groupProvider.notifications;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.notifications_active, color: AppColors.primaryBrick),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              AppStrings.notificationsDialogTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        height: 440,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPermissionBanner(context, groupProvider),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Text(
                        AppStrings.noNotificationsYet,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.separated(
                      itemCount: notifications.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        final color = _colorForType(notif.type);
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: color.withValues(alpha: 0.15),
                                child: Icon(
                                  _iconForType(notif.type),
                                  color: color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notif.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notif.body,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      DateFormatter.toReadableDate(
                                        notif.createdAt,
                                      ),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.close),
        ),
      ],
    );
  }

  Widget _buildPermissionBanner(
    BuildContext context,
    GroupProvider groupProvider,
  ) {
    if (_permissionStatus == 'granted') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                AppStrings.phoneNotificationBarActive,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () async {
                await groupProvider.sendTestNotification();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                AppStrings.testNotificationButton,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_permissionStatus == 'denied') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: const Text(
          AppStrings.notificationsBlockedMessage,
          style: TextStyle(fontSize: 12, color: AppColors.errorRed),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            AppStrings.enableNotificationsPrompt,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await WebNotificationBridge.requestPermission();
              if (!mounted) return;
              setState(() {
                _permissionStatus = result;
              });
              if (result == 'granted') {
                await groupProvider.sendTestNotification();
                if (!context.mounted) return;
                SnackbarHelper.showSuccess(
                  context,
                  AppStrings.notificationsEnabledSuccess,
                );
              }
            },
            icon: const Icon(Icons.notifications_active, size: 18),
            label: const Text(AppStrings.enablePhoneNotificationsButton),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }
}
