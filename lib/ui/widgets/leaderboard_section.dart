import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_strings.dart';

class LeaderboardSection extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboard;

  const LeaderboardSection({super.key, required this.leaderboard});

  String _dotsForRank(int index) {
    if (index == 0) return AppConstants.rankDotsFirst;
    if (index == 1) return AppConstants.rankDotsSecond;
    if (index == 2) return AppConstants.rankDotsThird;
    return AppConstants.rankDotsDefault;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                AppStrings.leaderboardTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: leaderboard.isEmpty
              ? const Center(child: Text(AppStrings.noMembersFound))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final data = leaderboard[index];
                    final user = data['user'];
                    final int sessionsCount =
                        data['sessionsPlayed'] as int? ?? 0;
                    final int winsCount = data['wins'] as int? ?? 0;
                    final double winrateNum = sessionsCount > 0
                        ? (winsCount / sessionsCount * 100)
                        : 0.0;
                    final String winrateStr =
                        '${winrateNum.toStringAsFixed(1)}%';

                    final Color rankColor;
                    if (index == 0) {
                      rankColor = AppColors.rankGold;
                    } else if (index == 1) {
                      rankColor = AppColors.rankSilver;
                    } else if (index == 2) {
                      rankColor = AppColors.rankBronze;
                    } else {
                      rankColor = Colors.grey.shade300;
                    }

                    final Color textColor =
                        index < AppConstants.topMedalsCount
                            ? AppColors.textPrimary
                            : Colors.grey.shade700;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: index == 0
                          ? AppColors.leaderCardSurface
                          : AppColors.cardSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.cardBorderRadius,
                        ),
                        side: index == 0
                            ? BorderSide(
                                color: rankColor.withValues(alpha: 0.7),
                                width: 2,
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
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: rankColor.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: rankColor,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  height: 1.0,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                _dotsForRank(index),
                                style: TextStyle(
                                  fontSize: 9,
                                  height: 1.0,
                                  letterSpacing: -0.5,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  AppStrings.gamesCount(sessionsCount),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  AppStrings.winsCount(winsCount),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              winrateStr,
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.primaryBrick,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              AppStrings.winrateLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
