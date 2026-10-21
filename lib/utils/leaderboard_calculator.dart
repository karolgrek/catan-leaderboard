import '../models/session_model.dart';
import '../models/user_model.dart';

class LeaderboardCalculator {
  static List<Map<String, dynamic>> calculateLeaderboard({
    required List<UserModel> members,
    required List<SessionModel> sessions,
  }) {
    if (members.isEmpty) return [];

    final Map<String, int> gamesPlayed = {};
    final Map<String, int> winCounts = {};

    for (final member in members) {
      gamesPlayed[member.uid] = 0;
      winCounts[member.uid] = 0;
    }

    for (final session in sessions) {
      for (final round in session.rounds) {
        if (!round.isActive && round.winnerUid != null) {
          for (final playerId in round.players) {
            if (gamesPlayed.containsKey(playerId)) {
              gamesPlayed[playerId] = gamesPlayed[playerId]! + 1;
            }
          }
          if (winCounts.containsKey(round.winnerUid)) {
            winCounts[round.winnerUid!] = winCounts[round.winnerUid!]! + 1;
          }
        }
      }
    }

    final List<Map<String, dynamic>> leaderboard = members.map((member) {
      return {
        'user': member,
        'sessionsPlayed': gamesPlayed[member.uid] ?? 0,
        'wins': winCounts[member.uid] ?? 0,
      };
    }).toList();

    leaderboard.sort((a, b) {
      final int aGames = a['sessionsPlayed'] as int;
      final int aWins = a['wins'] as int;
      final double aWinrate = aGames > 0 ? (aWins / aGames) : 0.0;

      final int bGames = b['sessionsPlayed'] as int;
      final int bWins = b['wins'] as int;
      final double bWinrate = bGames > 0 ? (bWins / bGames) : 0.0;

      final int winrateComparison = bWinrate.compareTo(aWinrate);
      if (winrateComparison != 0) return winrateComparison;

      final int gamesComparison = bGames.compareTo(aGames);
      if (gamesComparison != 0) return gamesComparison;

      return bWins.compareTo(aWins);
    });

    return leaderboard;
  }

  static UserModel? getTopLeader(List<Map<String, dynamic>> leaderboard) {
    if (leaderboard.isNotEmpty && (leaderboard.first['wins'] as int) > 0) {
      return leaderboard.first['user'] as UserModel;
    }
    return null;
  }

  static List<SessionModel> buildSessionsWithRoundState({
    required List<SessionModel> sessions,
    required String sessionId,
    required String roundId,
    required RoundModel? replacementRound,
  }) {
    return sessions.map((s) {
      if (s.id != sessionId) return s;
      final List<RoundModel> modifiedRounds = [];
      for (final r in s.rounds) {
        if (r.id == roundId) {
          if (replacementRound != null) {
            modifiedRounds.add(replacementRound);
          }
        } else {
          modifiedRounds.add(r);
        }
      }
      return SessionModel(
        id: s.id,
        groupId: s.groupId,
        date: s.date,
        notes: s.notes,
        selectedPlayers: s.selectedPlayers,
        isActive: s.isActive,
        rounds: modifiedRounds,
      );
    }).toList();
  }

  static List<RoundModel> getChronologicalFinishedRounds(
    List<SessionModel> sessions,
  ) {
    final sortedSessions = List<SessionModel>.from(sessions)
      ..sort((a, b) => a.date.compareTo(b.date));
    final List<RoundModel> result = [];
    for (final s in sortedSessions) {
      for (final r in s.rounds) {
        if (!r.isActive && r.winnerUid != null) {
          result.add(r);
        }
      }
    }
    return result;
  }

  static int countConsecutiveTrailingWins(
    List<RoundModel> finishedRounds,
    String playerUid,
  ) {
    int streak = 0;
    for (int i = finishedRounds.length - 1; i >= 0; i--) {
      if (finishedRounds[i].winnerUid == playerUid) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  static int countConsecutiveTrailingLosses(
    List<RoundModel> finishedRounds,
    String playerUid,
  ) {
    int losses = 0;
    for (int i = finishedRounds.length - 1; i >= 0; i--) {
      final r = finishedRounds[i];
      if (r.players.contains(playerUid)) {
        if (r.winnerUid != playerUid) {
          losses++;
        } else {
          break;
        }
      }
    }
    return losses;
  }

  static List<String> getSessionTopWinnerUids(SessionModel session) {
    final Map<String, int> sessionWins = {};
    for (final round in session.rounds) {
      if (!round.isActive && round.winnerUid != null) {
        sessionWins[round.winnerUid!] =
            (sessionWins[round.winnerUid!] ?? 0) + 1;
      }
    }
    if (sessionWins.isEmpty) return [];

    int maxWins = 0;
    for (final w in sessionWins.values) {
      if (w > maxWins) maxWins = w;
    }

    return sessionWins.entries
        .where((e) => e.value == maxWins)
        .map((e) => e.key)
        .toList();
  }
}
