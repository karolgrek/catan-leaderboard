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

    // Fetch member details
    _groupMembers = await _dbService.getUsersByIds(group.members);
    
    // Listen to sessions for this group
    _sessionsSubscription?.cancel();
    _sessionsSubscription = _dbService.getGroupSessions(group.id).listen((sessionsData) {
      _sessions = sessionsData;
      notifyListeners();
    });

    _isLoading = false;
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

  Future<bool> createSession(DateTime date, String notes, List<String> selectedPlayers) async {
    if (_activeGroup == null) return false;
    
    SessionModel? session = await _dbService.createSession(
      _activeGroup!.id, 
      date, 
      notes, 
      selectedPlayers
    );
    
    return session != null;
  }

  Future<bool> addWinnerToSession(String sessionId, String winnerUid) async {
    return await _dbService.addWinnerToSession(sessionId, winnerUid);
  }

  Future<bool> finishSession(String sessionId) async {
    return await _dbService.finishSession(sessionId);
  }

  // Calculate leaderboard based on wins and games played
  List<Map<String, dynamic>> getLeaderboard() {
    if (_groupMembers.isEmpty) return [];

    Map<String, int> sessionCounts = {};
    Map<String, int> winCounts = {};
    
    for (var member in _groupMembers) {
      sessionCounts[member.uid] = 0;
      winCounts[member.uid] = 0;
    }

    for (var session in _sessions) {
      // Count participation
      for (var playerId in session.selectedPlayers) {
        if (sessionCounts.containsKey(playerId)) {
          sessionCounts[playerId] = sessionCounts[playerId]! + 1;
        }
      }
      
      // Count wins
      for (var winnerId in session.gameWinners) {
        if (winCounts.containsKey(winnerId)) {
          winCounts[winnerId] = winCounts[winnerId]! + 1;
        }
      }
    }

    List<Map<String, dynamic>> leaderboard = _groupMembers.map((member) {
      return {
        'user': member,
        'sessionsPlayed': sessionCounts[member.uid] ?? 0,
        'wins': winCounts[member.uid] ?? 0,
      };
    }).toList();

    // Sort by wins (descending), then by sessions played
    leaderboard.sort((a, b) {
      int winComparison = (b['wins'] as int).compareTo(a['wins'] as int);
      if (winComparison != 0) return winComparison;
      return (b['sessionsPlayed'] as int).compareTo(a['sessionsPlayed'] as int);
    });
    
    return leaderboard;
  }

  @override
  void dispose() {
    _sessionsSubscription?.cancel();
    super.dispose();
  }
}
