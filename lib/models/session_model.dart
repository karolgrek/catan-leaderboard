import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id;
  final String groupId;
  final DateTime date;
  final String notes;
  final List<String> selectedPlayers;
  
  // New fields for win tracking
  final bool isActive;
  final List<String> gameWinners; // List of UIDs representing the winner of each game

  SessionModel({
    required this.id,
    required this.groupId,
    required this.date,
    required this.notes,
    required this.selectedPlayers,
    this.isActive = true,
    this.gameWinners = const [],
  });

  factory SessionModel.fromMap(Map<String, dynamic> data, String id) {
    return SessionModel(
      id: id,
      groupId: data['groupId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'] ?? '',
      selectedPlayers: List<String>.from(data['selectedPlayers'] ?? []),
      isActive: data['isActive'] ?? true,
      gameWinners: List<String>.from(data['gameWinners'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'selectedPlayers': selectedPlayers,
      'isActive': isActive,
      'gameWinners': gameWinners,
    };
  }

  // Copy with for local state immutability (useful for mocks)
  SessionModel copyWith({
    String? id,
    String? groupId,
    DateTime? date,
    String? notes,
    List<String>? selectedPlayers,
    bool? isActive,
    List<String>? gameWinners,
  }) {
    return SessionModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      selectedPlayers: selectedPlayers ?? this.selectedPlayers,
      isActive: isActive ?? this.isActive,
      gameWinners: gameWinners ?? this.gameWinners,
    );
  }
}
