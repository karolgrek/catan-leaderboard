import 'dart:async';
import '../models/group_model.dart';
import '../models/session_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  // MOCK DATA - Firebase is bypassed
  final List<GroupModel> _mockGroups = [];
  final List<SessionModel> _mockSessions = [];
  final StreamController<List<SessionModel>> _sessionsController = StreamController.broadcast();
  final StreamController<List<GroupModel>> _groupsController = StreamController.broadcast();
  
  Future<GroupModel?> createGroup(String name, String creatorUid) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var newGroup = GroupModel(
      id: 'group_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      createdBy: creatorUid,
      members: [creatorUid, 'player_2_uid', 'player_3_uid', 'player_4_uid'],
      createdAt: DateTime.now(),
    );
    _mockGroups.add(newGroup);
    _groupsController.add(_mockGroups);
    return newGroup;
  }

  Future<bool> joinGroup(String groupId, String userUid) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _groupsController.add(_mockGroups);
    return true; // Pretend it was successful
  }

  Stream<List<GroupModel>> getUserGroups(String userUid) {
    Future.microtask(() => _groupsController.add(_mockGroups));
    return _groupsController.stream;
  }

  Future<List<UserModel>> getUsersByIds(List<String> uids) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return uids.map((id) => UserModel(
      uid: id, 
      email: '$id@mock.com', 
      name: id == 'mock_uid_123' ? 'Test User (You)' : 'Player $id'
    )).toList();
  }

  Future<SessionModel?> createSession(String groupId, DateTime date, String notes, List<String> selectedPlayers) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var session = SessionModel(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      groupId: groupId,
      date: date,
      notes: notes,
      selectedPlayers: selectedPlayers,
      isActive: true,
      gameWinners: [],
    );
    _mockSessions.add(session);
    _notifySessions(groupId);
    return session;
  }

  Future<bool> addWinnerToSession(String sessionId, String winnerUid) async {
    await Future.delayed(const Duration(milliseconds: 300));
    int index = _mockSessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      SessionModel current = _mockSessions[index];
      List<String> updatedWinners = List.from(current.gameWinners)..add(winnerUid);
      _mockSessions[index] = current.copyWith(gameWinners: updatedWinners);
      _notifySessions(current.groupId);
      return true;
    }
    return false;
  }

  Future<bool> finishSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    int index = _mockSessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      SessionModel current = _mockSessions[index];
      _mockSessions[index] = current.copyWith(isActive: false);
      _notifySessions(current.groupId);
      return true;
    }
    return false;
  }

  void _notifySessions(String groupId) {
    _sessionsController.add(_mockSessions.where((s) => s.groupId == groupId).toList());
  }

  Stream<List<SessionModel>> getGroupSessions(String groupId) {
    // Send immediate initial data
    Future.microtask(() => _notifySessions(groupId));
    return _sessionsController.stream;
  }
}
