import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
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
      await _firestore.collection(AppConstants.notificationsCollection).add({
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
        .collection(AppConstants.notificationsCollection)
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
      await _firestore
          .collection(AppConstants.notificationsCollection)
          .doc(notificationId)
          .update({
        'seenBy': FieldValue.arrayUnion([userUid]),
      });
    } catch (e) {
      debugPrint('Error marking notification as seen: $e');
    }
  }

  Future<void> markAllAsSeen(
    List<NotificationModel> notifications,
    String userUid,
  ) async {
    try {
      final WriteBatch batch = _firestore.batch();
      int count = 0;
      for (final notif in notifications) {
        if (!notif.seenBy.contains(userUid)) {
          final ref = _firestore
              .collection(AppConstants.notificationsCollection)
              .doc(notif.id);
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

  // 1. Left Behind / FOMO
  Future<void> notifyLeftBehind({
    required String groupId,
    required String groupName,
    required List<String> leftBehindUids,
  }) async {
    if (leftBehindUids.isEmpty) return;

    await createNotification(
      groupId: groupId,
      groupName: groupName,
      title: AppStrings.leftBehindTitle(groupName),
      body: _pickRandom(AppStrings.leftBehindMessages(groupName)),
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
    await createNotification(
      groupId: groupId,
      groupName: groupName,
      title: AppStrings.roundWinnerTitle(roundNumber),
      body: _pickRandom(
        AppStrings.roundWinnerMessages(winnerName, roundNumber, groupName),
      ),
      type: 'round_winner',
      targetUids: targetUids,
    );
  }

  // 4. Dethroned / Kingslayer
  Future<void> notifyDethroned({
    required String groupId,
    required String groupName,
    required String oldLeaderName,
    required String newLeaderName,
    required List<String> targetUids,
  }) async {
    await createNotification(
      groupId: groupId,
      groupName: groupName,
      title: AppStrings.dethronedTitle(groupName),
      body: _pickRandom(
        AppStrings.dethronedMessages(oldLeaderName, newLeaderName, groupName),
      ),
      type: 'dethroned',
      targetUids: targetUids,
    );
  }

  // 5. Win Streak
  Future<void> notifyWinStreak({
    required String groupId,
    required String groupName,
    required String winnerName,
    required int streakCount,
    required List<String> targetUids,
  }) async {
    final String body = streakCount == 2
        ? _pickRandom(AppStrings.twoWinStreakMessages(winnerName))
        : _pickRandom(
            AppStrings.multiWinStreakMessages(winnerName, streakCount),
          );

    await createNotification(
      groupId: groupId,
      groupName: groupName,
      title: AppStrings.winStreakTitle,
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
    final String body = isFirstWinEver
        ? _pickRandom(AppStrings.firstWinEverMessages(winnerName, groupName))
        : _pickRandom(
            AppStrings.brokenLosingStreakMessages(
              winnerName,
              previousLosingStreak,
            ),
          );

    await createNotification(
      groupId: groupId,
      groupName: groupName,
      title: AppStrings.miracleTitle(groupName),
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
    await createNotification(
      groupId: groupId,
      groupName: groupName,
      title: AppStrings.crimeScenePhotosTitle,
      body: _pickRandom(
        AppStrings.photosUploadedMessages(roundNumber, groupName),
      ),
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
    await createNotification(
      groupId: groupId,
      groupName: groupName,
      title: AppStrings.sessionFinishedTitle(groupName),
      body: _pickRandom(
        AppStrings.sessionSummaryMessages(sessionWinnerName, groupName),
      ),
      type: 'session_summary',
      targetUids: targetUids,
    );
  }
}
