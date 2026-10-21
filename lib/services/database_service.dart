import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../models/group_model.dart';
import '../models/session_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // -- GROUPS --
  Future<GroupModel?> createGroup(String name, String creatorUid) async {
    try {
      DocumentReference docRef =
          await _firestore.collection(AppConstants.groupsCollection).add({
        'name': name,
        'createdBy': creatorUid,
        'members': [creatorUid],
        'createdAt': FieldValue.serverTimestamp(),
      });

      DocumentSnapshot doc = await docRef.get();
      return GroupModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> joinGroup(String groupId, String userUid) async {
    try {
      DocumentReference docRef =
          _firestore.collection(AppConstants.groupsCollection).doc(groupId);
      DocumentSnapshot doc = await docRef.get();
      if (doc.exists) {
        await docRef.update({
          'members': FieldValue.arrayUnion([userUid]),
        });
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Stream<List<GroupModel>> getUserGroups(String userUid) {
    return _firestore
        .collection(AppConstants.groupsCollection)
        .where('members', arrayContains: userUid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GroupModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<List<UserModel>> getUsersByIds(List<String> uids) async {
    if (uids.isEmpty) return [];
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where(FieldPath.documentId, whereIn: uids)
          .get();

      return snapshot.docs
          .map(
            (doc) => UserModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  // -- SESSIONS --
  Future<SessionModel?> createSession(
    String groupId,
    DateTime date,
    String notes,
    List<String> selectedPlayers,
  ) async {
    try {
      DocumentReference docRef =
          await _firestore.collection(AppConstants.sessionsCollection).add({
        'groupId': groupId,
        'date': Timestamp.fromDate(date),
        'notes': notes,
        'selectedPlayers': selectedPlayers,
        'isActive': true,
        'rounds': [],
      });

      DocumentSnapshot doc = await docRef.get();
      return SessionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> finishSession(String sessionId) async {
    try {
      await _firestore
          .collection(AppConstants.sessionsCollection)
          .doc(sessionId)
          .update({'isActive': false});
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> updateSession(
    String sessionId,
    DateTime date,
    String notes,
    List<String> selectedPlayers,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.sessionsCollection)
          .doc(sessionId)
          .update({
        'date': Timestamp.fromDate(date),
        'notes': notes,
        'selectedPlayers': selectedPlayers,
      });
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> deleteSession(String sessionId) async {
    try {
      await _firestore
          .collection(AppConstants.sessionsCollection)
          .doc(sessionId)
          .delete();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Stream<List<SessionModel>> getGroupSessions(String groupId) {
    return _firestore
        .collection(AppConstants.sessionsCollection)
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map((snapshot) {
      var sessions = snapshot.docs
          .map((doc) => SessionModel.fromMap(doc.data(), doc.id))
          .toList();
      sessions.sort((a, b) => b.date.compareTo(a.date));
      return sessions;
    });
  }

  // -- ROUNDS --
  Future<bool> addRoundToSession(
    String sessionId,
    List<String> roundPlayers,
    List<String> expansions,
    String notes,
  ) async {
    try {
      final newRound = RoundModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        players: roundPlayers,
        winnerUid: null,
        isActive: true,
        expansions: expansions,
        notes: notes,
      );

      await _firestore
          .collection(AppConstants.sessionsCollection)
          .doc(sessionId)
          .update({
        'rounds': FieldValue.arrayUnion([newRound.toMap()]),
      });
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> finishRound(
    String sessionId,
    RoundModel round,
    String winnerUid,
  ) async {
    try {
      DocumentReference docRef =
          _firestore.collection(AppConstants.sessionsCollection).doc(sessionId);

      return await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return false;

        List<dynamic> currentRoundsMap = snapshot.get('rounds') ?? [];
        List<Map<String, dynamic>> updatedRounds = [];

        for (var r in currentRoundsMap) {
          Map<String, dynamic> roundData = Map<String, dynamic>.from(r as Map);
          if (roundData['id'] == round.id) {
            roundData['winnerUid'] = winnerUid;
            roundData['isActive'] = false;
          }
          updatedRounds.add(roundData);
        }

        transaction.update(docRef, {'rounds': updatedRounds});
        return true;
      });
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> updateSessionRounds(
    String sessionId,
    List<RoundModel> rounds,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.sessionsCollection)
          .doc(sessionId)
          .update({'rounds': rounds.map((r) => r.toMap()).toList()});
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> updateRound(String sessionId, RoundModel updatedRound) async {
    try {
      DocumentReference docRef =
          _firestore.collection(AppConstants.sessionsCollection).doc(sessionId);

      return await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return false;

        List<dynamic> currentRoundsMap = snapshot.get('rounds') ?? [];
        List<Map<String, dynamic>> updatedRounds = [];

        for (var r in currentRoundsMap) {
          Map<String, dynamic> roundData = Map<String, dynamic>.from(r as Map);
          if (roundData['id'] == updatedRound.id) {
            updatedRounds.add(updatedRound.toMap());
          } else {
            updatedRounds.add(roundData);
          }
        }

        transaction.update(docRef, {'rounds': updatedRounds});
        return true;
      });
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // -- SEEDING --
  Future<bool> seedTestUsersAndAddToGroup(String groupId) async {
    try {
      final List<Map<String, dynamic>> testUsers = [
        {'uid': 'seed_john', 'name': 'John (Seed)', 'email': 'john@seed.com'},
        {'uid': 'seed_emma', 'name': 'Emma (Seed)', 'email': 'emma@seed.com'},
        {'uid': 'seed_mike', 'name': 'Mike (Seed)', 'email': 'mike@seed.com'},
        {
          'uid': 'seed_sarah',
          'name': 'Sarah (Seed)',
          'email': 'sarah@seed.com',
        },
      ];

      WriteBatch batch = _firestore.batch();
      List<String> newMemberUids = [];

      for (var user in testUsers) {
        DocumentReference userRef = _firestore
            .collection(AppConstants.usersCollection)
            .doc(user['uid']);
        batch.set(userRef, {
          'name': user['name'],
          'email': user['email'],
        });
        newMemberUids.add(user['uid']);
      }

      await batch.commit();

      await _firestore
          .collection(AppConstants.groupsCollection)
          .doc(groupId)
          .update({
        'members': FieldValue.arrayUnion(newMemberUids),
      });

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
