import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/group_provider.dart';
import '../../models/session_model.dart';
import '../../utils/snackbar_helper.dart';
import '../../utils/date_formatters.dart';
import 'session_editor_screen.dart';
import '../widgets/active_round_card.dart';
import '../widgets/finished_round_card.dart';
import '../dialogs/round_dialogs.dart';

class SessionDetailScreen extends StatelessWidget {
  final SessionModel session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        final currentSession = groupProvider.sessions.firstWhere(
          (s) => s.id == session.id,
          orElse: () => session,
        );
        final members = groupProvider.groupMembers;

        RoundModel? activeRound;
        List<RoundModel> finishedRounds = [];

        for (var r in currentSession.rounds) {
          if (r.isActive) {
            activeRound = r;
          } else {
            finishedRounds.add(r);
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppStrings.sessionTitleWithDate(
                DateFormatter.toReadableDate(currentSession.date),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: AppStrings.editSessionDataTooltip,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SessionEditorScreen(session: currentSession),
                    ),
                  );
                },
              ),
              if (currentSession.isActive)
                TextButton(
                  onPressed: () async {
                    if (activeRound != null) {
                      SnackbarHelper.showError(
                        context,
                        AppStrings.finishActiveRoundFirstError,
                      );
                      return;
                    }
                    bool success = await groupProvider.finishSession(
                      currentSession.id,
                    );
                    if (!context.mounted) return;
                    if (success) {
                      SnackbarHelper.showSuccess(
                        context,
                        AppStrings.sessionFinishedSuccess,
                      );
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text(AppStrings.finishSessionButton),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentSession.notes.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.notes,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            currentSession.notes,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                if (activeRound != null)
                  ActiveRoundCard(
                    sessionId: currentSession.id,
                    activeRound: activeRound,
                    members: members,
                    groupProvider: groupProvider,
                  ),

                if (currentSession.isActive && activeRound == null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text(
                        AppStrings.startNewRoundButton,
                        style: TextStyle(fontSize: 18),
                      ),
                      onPressed: () {
                        showStartRoundDialog(
                          context,
                          groupProvider,
                          currentSession.id,
                          members,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                const Row(
                  children: [
                    Icon(Icons.history, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text(
                      AppStrings.roundHistoryTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (finishedRounds.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        AppStrings.noRoundsFinishedYet,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                else
                  ...finishedRounds.asMap().entries.map((entry) {
                    int index = entry.key;
                    RoundModel round = entry.value;
                    final winner = members.firstWhere(
                      (m) => m.uid == round.winnerUid,
                      orElse: () => members.first,
                    );

                    return FinishedRoundCard(
                      index: index,
                      round: round,
                      winner: winner,
                      members: members,
                      sessionId: currentSession.id,
                      groupProvider: groupProvider,
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}
