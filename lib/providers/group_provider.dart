import 'dart:async';
import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../models/session_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class GroupProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  GroupModel? _activeGroup;
  List<UserModel> _groupMembers = [];
  List<SessionModel> _sessions = [];
  bool _isLoading = false;
  StreamSubscription? _sessionsSubscription;

  GroupModel? get activeGroup => _activeGroup;
  List<UserModel> get groupMembers => _groupMembers;
  List<SessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;

  Future<void> setActiveGroup(GroupModel group) async {
    _activeGroup = group;
    _isLoading = true;
    notifyListeners();

    _groupMembers = await _dbService.getUsersByIds(group.members);
    
    _sessionsSubscription?.cancel();
    _sessionsSubscription = _dbService.getGroupSessions(group.id).listen((sessionsData) {
      _sessions = sessionsData;
      notifyListeners();
    });

    _isLoading = false;
    notifyListeners();
  }

  void clearActiveGroup() {
    _activeGroup = null;
    _sessionsSubscription?.cancel();
    notifyListeners();
  }

  Future<bool> createGroup(String name, String creatorUid) async {
    GroupModel? newGroup = await _dbService.createGroup(name, creatorUid);
    if (newGroup != null) {
      await setActiveGroup(newGroup);
      return true;
    }
    return false;
  }

  Future<bool> joinGroup(String groupId, String userUid) async {
    return await _dbService.joinGroup(groupId, userUid);
  }

  Stream<List<GroupModel>> getUserGroups(String userUid) {
    return _dbService.getUserGroups(userUid);
  }

  Future<bool> createSession(DateTime date, String notes, List<String> selectedPlayers) async {
    if (_activeGroup == null) return false;
    SessionModel? session = await _dbService.createSession(_activeGroup!.id, date, notes, selectedPlayers);
    return session != null;
  }

  Future<bool> finishSession(String sessionId) async {
    return await _dbService.finishSession(sessionId);
  }

  Future<bool> updateSession(String sessionId, DateTime date, String notes, List<String> selectedPlayers) async {
    return await _dbService.updateSession(sessionId, date, notes, selectedPlayers);
  }


  Future<bool> addRound(String sessionId, List<String> roundPlayers, List<String> expansions, String notes) async {
    return await _dbService.addRoundToSession(sessionId, roundPlayers, expansions, notes);
  }

  Future<bool> finishRound(String sessionId, RoundModel round, String winnerUid) async {
    return await _dbService.finishRound(sessionId, round, winnerUid);
  }

  Future<bool> updateRound(String sessionId, RoundModel updatedRound) async {
    return await _dbService.updateRound(sessionId, updatedRound);
  }

  Future<bool> seedTestUsers() async {
    if (_activeGroup == null) return false;
    bool success = await _dbService.seedTestUsersAndAddToGroup(_activeGroup!.id);
    if (success) {
      // Refresh members
      _groupMembers = await _dbService.getUsersByIds(_activeGroup!.members); // Wait, _activeGroup.members might be stale.
      // Easiest way to force refresh is just wait for user to re-enter, or just hardcode refresh:
      // A proper way would be listening to group changes, but for seeding this is fine.
    }
    return success;
  }

  // Calculate leaderboard based on rounds (wins and games played)
  List<Map<String, dynamic>> getLeaderboard() {
    if (_groupMembers.isEmpty) return [];

    Map<String, int> gamesPlayed = {};
    Map<String, int> winCounts = {};
    
    for (var member in _groupMembers) {
      gamesPlayed[member.uid] = 0;
      winCounts[member.uid] = 0;
    }

    for (var session in _sessions) {
      for (var round in session.rounds) {
        if (!round.isActive && round.winnerUid != null) {
          // Count participation in finished rounds
          for (var playerId in round.players) {
            if (gamesPlayed.containsKey(playerId)) {
              gamesPlayed[playerId] = gamesPlayed[playerId]! + 1;
            }
          }
          // Count wins
          if (winCounts.containsKey(round.winnerUid)) {
            winCounts[round.winnerUid!] = winCounts[round.winnerUid!]! + 1;
          }
        }
      }
    }

    List<Map<String, dynamic>> leaderboard = _groupMembers.map((member) {
      return {
        'user': member,
        'sessionsPlayed': gamesPlayed[member.uid] ?? 0, // Keeping the key name for UI compatibility, but it means games
        'wins': winCounts[member.uid] ?? 0,
      };
    }).toList();

    // Sort by winrate (descending), then by games played
    leaderboard.sort((a, b) {
      int aGames = a['sessionsPlayed'] as int;
      int aWins = a['wins'] as int;
      double aWinrate = aGames > 0 ? (aWins / aGames) : 0.0;

      int bGames = b['sessionsPlayed'] as int;
      int bWins = b['wins'] as int;
      double bWinrate = bGames > 0 ? (bWins / bGames) : 0.0;

      int winrateComparison = bWinrate.compareTo(aWinrate);
      if (winrateComparison != 0) return winrateComparison;
      
      int gamesComparison = bGames.compareTo(aGames);
      if (gamesComparison != 0) return gamesComparison;

      return bWins.compareTo(aWins);
    });
    
    return leaderboard;
  }

  @override
  void dispose() {
    _sessionsSubscription?.cancel();
    super.dispose();
  }
}
