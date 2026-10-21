import 'dart:async';
import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../models/notification_model.dart';
import '../models/session_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../utils/leaderboard_calculator.dart';
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
      final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex != -1) {
        final topWinnerUids = LeaderboardCalculator.getSessionTopWinnerUids(
          _sessions[sessionIndex],
        );
        if (topWinnerUids.isNotEmpty) {
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

    RoundModel? oldRound;
    int roundNumber = 1;

    final sessionIdx = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIdx != -1) {
      final oldSession = _sessions[sessionIdx];
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

    final sessionsBefore = LeaderboardCalculator.buildSessionsWithRoundState(
      sessions: _sessions,
      sessionId: sessionId,
      roundId: updatedRound.id,
      replacementRound: null,
    );
    final sessionsAfter = LeaderboardCalculator.buildSessionsWithRoundState(
      sessions: _sessions,
      sessionId: sessionId,
      roundId: updatedRound.id,
      replacementRound: updatedRound,
    );

    final bool success = await _dbService.updateRound(sessionId, updatedRound);
    if (!success) return false;

    final String groupId = _activeGroup!.id;
    final String groupName = _activeGroup!.name;
    final List<String> allMemberUids = _activeGroup!.members;

    if (newlyFinishedWithWinner) {
      await _triggerRoundWinnerNotifications(
        groupId: groupId,
        groupName: groupName,
        winnerUid: updatedRound.winnerUid!,
        roundNumber: roundNumber,
        allMemberUids: allMemberUids,
        sessionsBefore: sessionsBefore,
        sessionsAfter: sessionsAfter,
      );
    }

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

  Future<void> _triggerRoundWinnerNotifications({
    required String groupId,
    required String groupName,
    required String winnerUid,
    required int roundNumber,
    required List<String> allMemberUids,
    required List<SessionModel> sessionsBefore,
    required List<SessionModel> sessionsAfter,
  }) async {
    final String winnerName = _getMemberName(winnerUid);

    // Round Winner
    await _notificationService.notifyRoundWinner(
      groupId: groupId,
      groupName: groupName,
      winnerName: winnerName,
      roundNumber: roundNumber,
      targetUids: allMemberUids,
    );

    // Dethroned / Kingslayer
    final oldLeader = LeaderboardCalculator.getTopLeader(
      LeaderboardCalculator.calculateLeaderboard(
        members: _groupMembers,
        sessions: sessionsBefore,
      ),
    );
    final newLeader = LeaderboardCalculator.getTopLeader(
      LeaderboardCalculator.calculateLeaderboard(
        members: _groupMembers,
        sessions: sessionsAfter,
      ),
    );

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

    final priorFinishedRounds =
        LeaderboardCalculator.getChronologicalFinishedRounds(sessionsBefore);

    // Win Streak
    final int currentWinStreak =
        LeaderboardCalculator.countConsecutiveTrailingWins(
              priorFinishedRounds,
              winnerUid,
            ) +
            1;
    if (currentWinStreak >= 2) {
      await _notificationService.notifyWinStreak(
        groupId: groupId,
        groupName: groupName,
        winnerName: winnerName,
        streakCount: currentWinStreak,
        targetUids: allMemberUids,
      );
    }

    // Underdog / First Win
    final int priorTotalWins = priorFinishedRounds
        .where((r) => r.winnerUid == winnerUid)
        .length;
    final int priorLosingStreak =
        LeaderboardCalculator.countConsecutiveTrailingLosses(
      priorFinishedRounds,
      winnerUid,
    );

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

  String _getMemberName(String uid) {
    for (final member in _groupMembers) {
      if (member.uid == uid) return member.name;
    }
    return 'Unknown Settler';
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
    return LeaderboardCalculator.calculateLeaderboard(
      members: _groupMembers,
      sessions: _sessions,
    );
  }

  @override
  void dispose() {
    _sessionsSubscription?.cancel();
    _notificationsSubscription?.cancel();
    super.dispose();
  }
}
