import 'package:cloud_firestore/cloud_firestore.dart';

class RoundModel {
  final String id;
  final List<String> players;
  final String? winnerUid;
  final bool isActive;

  RoundModel({
    required this.id,
    required this.players,
    this.winnerUid,
    this.isActive = true,
  });

  factory RoundModel.fromMap(Map<String, dynamic> data) {
    return RoundModel(
      id: data['id'] ?? '',
      players: List<String>.from(data['players'] ?? []),
      winnerUid: data['winnerUid'],
      isActive: data['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'players': players,
      'winnerUid': winnerUid,
      'isActive': isActive,
    };
  }
}

class SessionModel {
  final String id;
  final String groupId;
  final DateTime date;
  final String notes;
  final List<String> selectedPlayers; // The players available for this session
  final bool isActive;
  final List<RoundModel> rounds;

  SessionModel({
    required this.id,
    required this.groupId,
    required this.date,
    required this.notes,
    required this.selectedPlayers,
    this.isActive = true,
    this.rounds = const [],
  });

  factory SessionModel.fromMap(Map<String, dynamic> data, String id) {
    List<RoundModel> parsedRounds = [];
    if (data['rounds'] != null) {
      parsedRounds = (data['rounds'] as List).map((r) => RoundModel.fromMap(r as Map<String, dynamic>)).toList();
    }

    return SessionModel(
      id: id,
      groupId: data['groupId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'] ?? '',
      selectedPlayers: List<String>.from(data['selectedPlayers'] ?? []),
      isActive: data['isActive'] ?? true,
      rounds: parsedRounds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'selectedPlayers': selectedPlayers,
      'isActive': isActive,
      'rounds': rounds.map((r) => r.toMap()).toList(),
    };
  }

  SessionModel copyWith({
    String? id,
    String? groupId,
    DateTime? date,
    String? notes,
    List<String>? selectedPlayers,
    bool? isActive,
    List<RoundModel>? rounds,
  }) {
    return SessionModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      selectedPlayers: selectedPlayers ?? this.selectedPlayers,
      isActive: isActive ?? this.isActive,
      rounds: rounds ?? this.rounds,
    );
  }
}
