import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_strings.dart';
import '../../models/session_model.dart';
import '../../utils/date_formatters.dart';
import '../screens/session_detail_screen.dart';

class SessionsSection extends StatefulWidget {
  final List<SessionModel> sessions;

  const SessionsSection({super.key, required this.sessions});

  @override
  State<SessionsSection> createState() => _SessionsSectionState();
}

class _SessionsSectionState extends State<SessionsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final sessions = widget.sessions;
    const int maxInitialItems = AppConstants.initialDisplayedSessionsCount;
    final bool hasMore = sessions.length > maxInitialItems;

    final displayedSessions = _isExpanded || !hasMore
        ? sessions
        : sessions.take(maxInitialItems).toList();

    return Container(
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
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.sessionsTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: sessions.isEmpty
                ? const Center(child: Text(AppStrings.noSessionsRecorded))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayedSessions.length +
                        (hasMore && !_isExpanded ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (hasMore &&
                          !_isExpanded &&
                          index == displayedSessions.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isExpanded = true;
                              });
                            },
                            icon: const Icon(Icons.expand_more),
                            label: const Text(AppStrings.showMoreButton),
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.chitBackground,
                              foregroundColor: AppColors.textPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.cardBorderRadius,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      final session = displayedSessions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: session.isActive
                            ? Colors.green.shade50
                            : AppColors.surfaceWhite,
                        elevation: session.isActive ? 2 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.cardBorderRadius,
                          ),
                          side: session.isActive
                              ? const BorderSide(
                                  color: AppColors.activeGreen,
                                  width: 1.2,
                                )
                              : const BorderSide(
                                  color: AppColors.cardBorder,
                                  width: 1,
                                ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: session.isActive
                                  ? AppColors.activeGreen.withValues(alpha: 0.2)
                                  : AppColors.chitBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              session.isActive ? Icons.play_arrow : Icons.check,
                              color: session.isActive
                                  ? AppColors.activeGreen
                                  : AppColors.textSecondary,
                            ),
                          ),
                          title: Text(
                            DateFormatter.toReadableDate(session.date),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            AppStrings.roundsRecordedCount(
                              session.rounds.length,
                            ),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SessionDetailScreen(session: session),
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
    );
  }
}
