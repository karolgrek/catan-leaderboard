import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/session_model.dart';
import '../../providers/group_provider.dart';
import '../screens/round_editor_screen.dart';

class ActiveRoundCard extends StatelessWidget {
  final String sessionId;
  final RoundModel activeRound;
  final List<dynamic> members;
  final GroupProvider groupProvider;

  const ActiveRoundCard({
    super.key,
    required this.sessionId,
    required this.activeRound,
    required this.members,
    required this.groupProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      elevation: 4,
      shadowColor: AppColors.activeGreen.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.activeGreen, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.play_circle_fill,
                      color: AppColors.activeGreen,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      AppStrings.activeRoundTitle,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.activeGreen,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.activeGreen),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoundEditorScreen(
                          sessionId: sessionId,
                          round: activeRound,
                          members: members,
                          isFinishing: false,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.activeRoundPrompt,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...activeRound.players.map((uid) {
              final player = members.firstWhere((m) => m.uid == uid);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoundEditorScreen(
                          sessionId: sessionId,
                          round: activeRound,
                          members: members,
                          isFinishing: true,
                          preselectedWinnerUid: player.uid,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          player.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Icon(Icons.emoji_events, color: Colors.amber),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
