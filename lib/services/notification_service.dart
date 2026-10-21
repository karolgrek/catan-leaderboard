import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _random = Random();

  String _pickRandom(List<String> options) {
    return options[_random.nextInt(options.length)];
  }

  Future<void> createNotification({
    required String groupId,
    required String groupName,
    required String title,
    required String body,
    required String type,
    required List<String> targetUids,
  }) async {
    if (targetUids.isEmpty) return;
    try {
      await _firestore.collection('notifications').add({
        'groupId': groupId,
        'groupName': groupName,
        'title': title,
        'body': body,
        'type': type,
        'targetUids': targetUids,
        'seenBy': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }

  Stream<List<NotificationModel>> getUserNotifications(String userUid) {
    return _firestore
        .collection('notifications')
        .where('targetUids', arrayContains: userUid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> markAsSeen(String notificationId, String userUid) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'seenBy': FieldValue.arrayUnion([userUid]),
      });
    } catch (e) {
      debugPrint('Error marking notification as seen: $e');
    }
  }

  Future<void> markAllAsSeen(List<NotificationModel> notifications, String userUid) async {
    try {
      final WriteBatch batch = _firestore.batch();
      int count = 0;
      for (final notif in notifications) {
        if (!notif.seenBy.contains(userUid)) {
          final ref = _firestore.collection('notifications').doc(notif.id);
          batch.update(ref, {
            'seenBy': FieldValue.arrayUnion([userUid]),
          });
          count++;
        }
      }
      if (count > 0) {
        await batch.commit();
      }
    } catch (e) {
      debugPrint('Error marking all notifications as seen: $e');
    }
  }

  // 1. Left Behind / FOMO (Session started without member)
  Future<void> notifyLeftBehind({
    required String groupId,
    required String groupName,
    required List<String> leftBehindUids,
  }) async {
    if (leftBehindUids.isEmpty) return;

    final body = _pickRandom([
      'Betrayal! Your Catan hood in $groupName just started the fight without you!',
      'No sheep for you tonight! $groupName started a session and left you in the desert.',
      'The Robber just stole your seat at the table! $groupName is playing without you.',
      'They are trading wood for sheep behind your back! A new game in $groupName started without you.',
    ]);

    await createNotification(
      groupId: groupId,
      groupName: groupName,
      title: 'Left Behind in $groupName',
      body: body,
      type: 'left_behind',
      targetUids: leftBehindUids,
    );
  }

  // 3. Round Winner
  Future<void> notifyRoundWinner({
    required String groupId,
    required String groupName,
    required String winnerName,
    required int roundNumber,
    required List<String> targetUids,
  }) async {
    final body = _pickRandom([
      'The winner of Round #$roundNumber is: $winnerName! Bow down to your new landlord.',
      'All hail $winnerName! They just conquered Round #$roundNumber in $groupName!',
      'Built on wheat, ore, and broken friendships: $winnerName takes the win in Round #$roundNumber!',
      'The winner of the round is: $winnerName! 10 Victory Points and zero mercy.',
    ]);

    await createNotification(
      groupId: groupId,
      groupName: groupName,
      title: 'Round #$roundNumber Winner',
      body: body,
      type: 'round_winner',
      targetUids: targetUids,
    );
  }

  // 4. Dethroned / Kingslayer (#1 on Leaderboard changed)
  Future<void> notifyDethroned({
    required String groupId,
    required String groupName,
    required String oldLeaderName,
    required String newLeaderName,
    required List<String> targetUids,
  }) async {
    final body = _pickRandom([
      'KINGSLAYER! $oldLeaderName was just dethroned by $newLeaderName at the top of the leaderboard!',
      'Someone check on $oldLeaderName... $newLeaderName just stole the #1 crown in $groupName!',
      'A new ruler sits on the Catan throne! $oldLeaderName was dethroned by $newLeaderName!',
    ]);

    await createNotification(
      groupId: groupId,
      groupName: groupName,
      title: 'New #1 in $groupName',
      body: body,
      type: 'dethroned',
      targetUids: targetUids,
    );
  }

  // 5. Trade Embargo / Win Streak (2+ wins in a row)
  Future<void> notifyWinStreak({
    required String groupId,
    required String groupName,
    required String winnerName,
    required int streakCount,
    required List<String> targetUids,
  }) async {
    final String body;
    if (streakCount == 2) {
      body = _pickRandom([
        'STOP TRADING WITH THEM! $winnerName just won 2 games in a row!',
        'Warning: $winnerName is on a 2-win streak! Refuse all their sheep offers immediately.',
      ]);
    } else {
      body = _pickRandom([
        'EMBARGO ALERT: $winnerName is on a $streakCount-win streak! Whoever gives them brick is a traitor.',
        'Total domination! $winnerName just won $streakCount games in a row. Send the Robber after them!',
      ]);
    }

    await createNotification(
      groupId: groupId,
      groupName: groupName,
      title: 'Win Streak Alert',
      body: body,
      type: 'win_streak',
      targetUids: targetUids,
    );
  }

  // 6. Underdog / First Win
  Future<void> notifyUnderdogOrFirstWin({
    required String groupId,
    required String groupName,
    required String winnerName,
    required bool isFirstWinEver,
    required int previousLosingStreak,
    required List<String> targetUids,
  }) async {
    final String body;
    if (isFirstWinEver) {
      body = _pickRandom([
        'Hell just froze over! $winnerName finally won a game of Catan in $groupName!',
        'From humble settlements to a mighty empire: $winnerName just scored their FIRST win!',
      ]);
    } else {
      body = _pickRandom([
        'The curse is broken! After $previousLosingStreak losses in a row, $winnerName finally won a game of Catan!',
        'Hell just froze over! $winnerName ended a $previousLosingStreak-game losing streak and took the win!',
      ]);
    }

    await createNotification(
      groupId: groupId,
      groupName: groupName,
      title: 'Miracle in $groupName',
      body: body,
      type: 'first_win',
      targetUids: targetUids,
    );
  }

  // 7. Crime Scene Photos
  Future<void> notifyPhotosUploaded({
    required String groupId,
    required String groupName,
    required int roundNumber,
    required List<String> targetUids,
  }) async {
    final body = _pickRandom([
      'Pics or it didn\'t happen! New crime scene photos from Round #$roundNumber were just uploaded.',
      'Go look at the faces of defeat! New photos added to Round #$roundNumber in $groupName.',
      'Evidence has been secured! Check out the new photos from the latest round in $groupName.',
    ]);

    await createNotification(
      groupId: groupId,
      groupName: groupName,
      title: 'Crime Scene Photos',
      body: body,
      type: 'photos_uploaded',
      targetUids: targetUids,
    );
  }

  // 8. Session Summary
  Future<void> notifySessionSummary({
    required String groupId,
    required String groupName,
    required String sessionWinnerName,
    required List<String> targetUids,
  }) async {
    final body = _pickRandom([
      'The dust has settled! The winner of the session is: $sessionWinnerName!',
      'Session over! Friendships ruined: many. The winner of the session is: $sessionWinnerName!',
      'Tonight\'s ultimate Catan champion in $groupName is: $sessionWinnerName!',
    ]);

    await createNotification(
      groupId: groupId,
      groupName: groupName,
      title: 'Session Finished in $groupName',
      body: body,
      type: 'session_summary',
      targetUids: targetUids,
    );
  }
}
