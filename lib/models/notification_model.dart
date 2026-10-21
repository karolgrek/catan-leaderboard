import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String groupId;
  final String groupName;
  final String title;
  final String body;
  final String type;
  final List<String> targetUids;
  final List<String> seenBy;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.title,
    required this.body,
    required this.type,
    required this.targetUids,
    required this.seenBy,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      groupId: data['groupId'] ?? '',
      groupName: data['groupName'] ?? '',
      title: data['title'] ?? 'Catan Leaderboard',
      body: data['body'] ?? '',
      type: data['type'] ?? 'general',
      targetUids: List<String>.from(data['targetUids'] ?? []),
      seenBy: List<String>.from(data['seenBy'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'title': title,
      'body': body,
      'type': type,
      'targetUids': targetUids,
      'seenBy': seenBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
