import 'package:flutter/material.dart';

class LeaderboardSection extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboard;

  const LeaderboardSection({super.key, required this.leaderboard});

  String _dotsForRank(int index) {
    if (index == 0) return '•••••';
    if (index == 1) return '••••';
    if (index == 2) return '•••';
    return '••';
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
                'Leaderboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2B1D16),
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: leaderboard.isEmpty
              ? const Center(child: Text('No members found.'))
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
                      rankColor = const Color(0xFFFFD700); // Gold
                    } else if (index == 1) {
                      rankColor = const Color(0xFFC0C0C0); // Silver
                    } else if (index == 2) {
                      rankColor = const Color(0xFFCD7F32); // Bronze
                    } else {
                      rankColor = Colors.grey.shade300;
                    }

                    final Color textColor = index < 3
                        ? const Color(0xFF2B1D16)
                        : Colors.grey.shade700;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: index == 0
                          ? const Color(0xF5FFFDF0)
                          : const Color(0xEBFFFDF9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: index == 0
                            ? BorderSide(
                                color: rankColor.withValues(alpha: 0.7),
                                width: 2,
                              )
                            : const BorderSide(
                                color: Color(0xFFE2CCB0),
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
                            color: Color(0xFF2B1D16),
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Games: $sessionsCount',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6D5446),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Wins: $winsCount',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6D5446),
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
                                color: Color(0xFFC63B12),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Winrate',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6D5446),
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
