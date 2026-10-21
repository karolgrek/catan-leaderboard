import 'dart:async';
import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../models/notification_model.dart';
import '../models/session_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../utils/web_notification_bridge.dart';

class GroupProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  GroupModel? _activeGroup;
  List<UserModel> _groupMembers = [];
  List<SessionModel> _sessions = [];
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  StreamSubscription? _sessionsSubscription;
  StreamSubscription? _notificationsSubscription;
  String? _listeningUserUid;
  final Set<String> _deliveredNotificationIds = {};

  GroupModel? get activeGroup => _activeGroup;
  List<UserModel> get groupMembers => _groupMembers;
  List<SessionModel> get sessions => _sessions;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  void startListeningToNotifications(String? userUid) {
    if (userUid == null || userUid.isEmpty) {
      _notificationsSubscription?.cancel();
      _notificationsSubscription = null;
      _listeningUserUid = null;
      _notifications = [];
      return;
    }
    if (_listeningUserUid == userUid && _notificationsSubscription != null) {
      return;
    }

    _listeningUserUid = userUid;
    _notificationsSubscription?.cancel();
    _notificationsSubscription =
        _notificationService.getUserNotifications(userUid).listen((notifs) {
      _notifications = notifs;

      for (final notif in notifs) {
        if (!notif.seenBy.contains(userUid) &&
            !_deliveredNotificationIds.contains(notif.id)) {
          _deliveredNotificationIds.add(notif.id);
          WebNotificationBridge.showNotification(
            title: notif.title,
            body: notif.body,
            tag: notif.id,
          );
          _notificationService.markAsSeen(notif.id, userUid);
        }
      }
      notifyListeners();
    });
  }

  Future<void> sendTestNotification() async {
    const title = 'Catan Leaderboard';
    const body =
        'Your scouts report that notifications are working! Prepare your settlements.';
    await WebNotificationBridge.showNotification(
      title: title,
      body: body,
      tag: 'test-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  Future<void> setActiveGroup(GroupModel group) async {
    _activeGroup = group;
    _isLoading = true;
    notifyListeners();

    _groupMembers = await _dbService.getUsersByIds(group.members);

    _sessionsSubscription?.cancel();
    _sessionsSubscription =
        _dbService.getGroupSessions(group.id).listen((sessionsData) {
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

  Future<bool> createSession(
    DateTime date,
    String notes,
    List<String> selectedPlayers,
  ) async {
    if (_activeGroup == null) return false;
    SessionModel? session = await _dbService.createSession(
      _activeGroup!.id,
      date,
      notes,
      selectedPlayers,
    );
    if (session != null) {
      // 1. Left Behind / FOMO notification for group members not in selectedPlayers
      final leftBehindUids = _activeGroup!.members
          .where((uid) => !selectedPlayers.contains(uid))
          .toList();
      if (leftBehindUids.isNotEmpty) {
        await _notificationService.notifyLeftBehind(
          groupId: _activeGroup!.id,
          groupName: _activeGroup!.name,
          leftBehindUids: leftBehindUids,
        );
      }
      return true;
    }
    return false;
  }

  Future<bool> finishSession(String sessionId) async {
    bool success = await _dbService.finishSession(sessionId);
    if (success && _activeGroup != null) {
      // 8. Session Summary notification
      final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex != -1) {
        final session = _sessions[sessionIndex];
        final Map<String, int> sessionWins = {};
        for (final round in session.rounds) {
          if (!round.isActive && round.winnerUid != null) {
            sessionWins[round.winnerUid!] =
                (sessionWins[round.winnerUid!] ?? 0) + 1;
          }
        }
        if (sessionWins.isNotEmpty) {
          int maxWins = 0;
          for (final w in sessionWins.values) {
            if (w > maxWins) maxWins = w;
          }
          final topWinnerUids = sessionWins.entries
              .where((e) => e.value == maxWins)
              .map((e) => e.key)
              .toList();
          final topWinnerNames =
              topWinnerUids.map(_getMemberName).join(' & ');

          await _notificationService.notifySessionSummary(
            groupId: _activeGroup!.id,
            groupName: _activeGroup!.name,
            sessionWinnerName: topWinnerNames,
            targetUids: _activeGroup!.members,
          );
        }
      }
    }
    return success;
  }

  Future<bool> updateSession(
    String sessionId,
    DateTime date,
    String notes,
    List<String> selectedPlayers,
  ) async {
    return await _dbService.updateSession(
      sessionId,
      date,
      notes,
      selectedPlayers,
    );
  }

  Future<bool> addRound(
    String sessionId,
    List<String> roundPlayers,
    List<String> expansions,
    String notes,
  ) async {
    return await _dbService.addRoundToSession(
      sessionId,
      roundPlayers,
      expansions,
      notes,
    );
  }

  Future<bool> finishRound(
    String sessionId,
    RoundModel round,
    String winnerUid,
  ) async {
    final updatedRound = RoundModel(
      id: round.id,
      players: round.players,
      winnerUid: winnerUid,
      isActive: false,
      expansions: round.expansions,
      notes: round.notes,
      winnerPhotoUrl: round.winnerPhotoUrl,
      boardPhotoUrl: round.boardPhotoUrl,
      partyPhotoUrl: round.partyPhotoUrl,
    );
    return await updateRound(sessionId, updatedRound);
  }

  Future<bool> updateRound(String sessionId, RoundModel updatedRound) async {
    if (_activeGroup == null) {
      return await _dbService.updateRound(sessionId, updatedRound);
    }

    // Inspect state before update
    SessionModel? oldSession;
    RoundModel? oldRound;
    int roundNumber = 1;

    final sessionIdx = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIdx != -1) {
      oldSession = _sessions[sessionIdx];
      final rIdx =
          oldSession.rounds.indexWhere((r) => r.id == updatedRound.id);
      if (rIdx != -1) {
        oldRound = oldSession.rounds[rIdx];
        roundNumber = rIdx + 1;
      } else {
        roundNumber = oldSession.rounds.length + 1;
      }
    }

    final bool newlyFinishedWithWinner = !updatedRound.isActive &&
        updatedRound.winnerUid != null &&
        (oldRound == null ||
            oldRound.isActive ||
            oldRound.winnerUid != updatedRound.winnerUid);

    final bool hasNewPhotos = (updatedRound.winnerPhotoUrl != null &&
            updatedRound.winnerPhotoUrl != oldRound?.winnerPhotoUrl) ||
        (updatedRound.boardPhotoUrl != null &&
            updatedRound.boardPhotoUrl != oldRound?.boardPhotoUrl) ||
        (updatedRound.partyPhotoUrl != null &&
            updatedRound.partyPhotoUrl != oldRound?.partyPhotoUrl);

    // Build session lists before and after this round update for accurate comparisons
    final List<SessionModel> sessionsBefore =
        _buildSessionsWithRoundState(sessionId, updatedRound.id, null);
    final List<SessionModel> sessionsAfter =
        _buildSessionsWithRoundState(sessionId, updatedRound.id, updatedRound);

    final bool success = await _dbService.updateRound(sessionId, updatedRound);
    if (!success) return false;

    final String groupId = _activeGroup!.id;
    final String groupName = _activeGroup!.name;
    final List<String> allMemberUids = _activeGroup!.members;

    if (newlyFinishedWithWinner) {
      final String winnerUid = updatedRound.winnerUid!;
      final String winnerName = _getMemberName(winnerUid);

      // 3. Round Winner notification
      await _notificationService.notifyRoundWinner(
        groupId: groupId,
        groupName: groupName,
        winnerName: winnerName,
        roundNumber: roundNumber,
        targetUids: allMemberUids,
      );

      // 4. Dethroned / Kingslayer check
      final leaderboardBefore = _calculateLeaderboardForSessions(sessionsBefore);
      final leaderboardAfter = _calculateLeaderboardForSessions(sessionsAfter);

      UserModel? oldLeader;
      if (leaderboardBefore.isNotEmpty &&
          (leaderboardBefore.first['wins'] as int) > 0) {
        oldLeader = leaderboardBefore.first['user'] as UserModel;
      }

      UserModel? newLeader;
      if (leaderboardAfter.isNotEmpty &&
          (leaderboardAfter.first['wins'] as int) > 0) {
        newLeader = leaderboardAfter.first['user'] as UserModel;
      }

      if (oldLeader != null &&
          newLeader != null &&
          oldLeader.uid != newLeader.uid) {
        await _notificationService.notifyDethroned(
          groupId: groupId,
          groupName: groupName,
          oldLeaderName: oldLeader.name,
          newLeaderName: newLeader.name,
          targetUids: allMemberUids,
        );
      }

      // Chronological list of finished rounds before this round
      final List<RoundModel> priorFinishedRounds =
          _getChronologicalFinishedRounds(sessionsBefore);

      // 5. Win Streak check (consecutive wins across finished rounds)
      int consecutivePriorWins = 0;
      for (int i = priorFinishedRounds.length - 1; i >= 0; i--) {
        if (priorFinishedRounds[i].winnerUid == winnerUid) {
          consecutivePriorWins++;
        } else {
          break;
        }
      }
      final int currentWinStreak = consecutivePriorWins + 1;
      if (currentWinStreak >= 2) {
        await _notificationService.notifyWinStreak(
          groupId: groupId,
          groupName: groupName,
          winnerName: winnerName,
          streakCount: currentWinStreak,
          targetUids: allMemberUids,
        );
      }

      // 6. Underdog / First Win check
      final int priorTotalWins = priorFinishedRounds
          .where((r) => r.winnerUid == winnerUid)
          .length;

      int priorLosingStreak = 0;
      for (int i = priorFinishedRounds.length - 1; i >= 0; i--) {
        final r = priorFinishedRounds[i];
        if (r.players.contains(winnerUid)) {
          if (r.winnerUid != winnerUid) {
            priorLosingStreak++;
          } else {
            break;
          }
        }
      }

      if (priorTotalWins == 0) {
        await _notificationService.notifyUnderdogOrFirstWin(
          groupId: groupId,
          groupName: groupName,
          winnerName: winnerName,
          isFirstWinEver: true,
          previousLosingStreak: priorLosingStreak,
          targetUids: allMemberUids,
        );
      } else if (priorLosingStreak >= 5) {
        await _notificationService.notifyUnderdogOrFirstWin(
          groupId: groupId,
          groupName: groupName,
          winnerName: winnerName,
          isFirstWinEver: false,
          previousLosingStreak: priorLosingStreak,
          targetUids: allMemberUids,
        );
      }
    }

    // 7. Crime Scene Photos uploaded check
    if (hasNewPhotos) {
      await _notificationService.notifyPhotosUploaded(
        groupId: groupId,
        groupName: groupName,
        roundNumber: roundNumber,
        targetUids: allMemberUids,
      );
    }

    return true;
  }

  String _getMemberName(String uid) {
    for (final member in _groupMembers) {
      if (member.uid == uid) return member.name;
    }
    return 'Unknown Settler';
  }

  List<SessionModel> _buildSessionsWithRoundState(
    String sessionId,
    String roundId,
    RoundModel? replacementRound,
  ) {
    return _sessions.map((s) {
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

  List<RoundModel> _getChronologicalFinishedRounds(
    List<SessionModel> sessionsList,
  ) {
    final sortedSessions = List<SessionModel>.from(sessionsList)
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

  Future<bool> seedTestUsers() async {
    if (_activeGroup == null) return false;
    bool success =
        await _dbService.seedTestUsersAndAddToGroup(_activeGroup!.id);
    if (success) {
      _groupMembers = await _dbService.getUsersByIds(_activeGroup!.members);
    }
    return success;
  }

  List<Map<String, dynamic>> getLeaderboard() {
    return _calculateLeaderboardForSessions(_sessions);
  }

  List<Map<String, dynamic>> _calculateLeaderboardForSessions(
    List<SessionModel> sessionsList,
  ) {
    if (_groupMembers.isEmpty) return [];

    Map<String, int> gamesPlayed = {};
    Map<String, int> winCounts = {};

    for (var member in _groupMembers) {
      gamesPlayed[member.uid] = 0;
      winCounts[member.uid] = 0;
    }

    for (var session in sessionsList) {
      for (var round in session.rounds) {
        if (!round.isActive && round.winnerUid != null) {
          for (var playerId in round.players) {
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

    List<Map<String, dynamic>> leaderboard = _groupMembers.map((member) {
      return {
        'user': member,
        'sessionsPlayed': gamesPlayed[member.uid] ?? 0,
        'wins': winCounts[member.uid] ?? 0,
      };
    }).toList();

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
    _notificationsSubscription?.cancel();
    super.dispose();
  }
}
