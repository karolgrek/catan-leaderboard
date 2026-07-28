import 'package:flutter/material.dart';

class LeaderboardSection extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboard;

  const LeaderboardSection({super.key, required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 8),
              Text('Leaderboard', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
                    final int sessionsCount = data['sessionsPlayed'] as int? ?? 0;
                    final int winsCount = data['wins'] as int? ?? 0;
                    final double winrateNum = sessionsCount > 0 ? (winsCount / sessionsCount * 100) : 0.0;
                    final String winrateStr = '${winrateNum.toStringAsFixed(1)}%';
                    
                    Color rankColor;
                    if (index == 0) rankColor = const Color(0xFFFFD700); // Gold
                    else if (index == 1) rankColor = const Color(0xFFC0C0C0); // Silver
                    else if (index == 2) rankColor = const Color(0xFFCD7F32); // Bronze
                    else rankColor = Colors.grey.shade200;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: index == 0 ? const Color(0xFFFFFDF0) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: index == 0 ? BorderSide(color: rankColor.withOpacity(0.5), width: 2) : BorderSide.none,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: rankColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: rankColor, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: index < 3 ? Colors.black87 : Colors.grey.shade700),
                            ),
                          ),
                        ),
                        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              Expanded(child: Text('Games: $sessionsCount', style: const TextStyle(fontSize: 13))),
                              Expanded(child: Text('Wins: $winsCount', style: const TextStyle(fontSize: 13))),
                            ],
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(winrateStr, style: const TextStyle(fontSize: 18, color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                            const Text('Winrate', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
