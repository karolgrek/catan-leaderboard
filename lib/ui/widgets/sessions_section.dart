import 'package:flutter/material.dart';
import '../../models/session_model.dart';
import '../../utils/date_formatters.dart';
import '../screens/session_detail_screen.dart';

class SessionsSection extends StatefulWidget {
  final List<SessionModel> sessions;

  const SessionsSection({super.key, required this.sessions});

  @override
  State<SessionsSection> createState() => _SessionsSectionState();
}

class _SessionsSectionState extends State<SessionsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final sessions = widget.sessions;
    const int maxInitialItems = 3;
    final bool hasMore = sessions.length > maxInitialItems;

    final displayedSessions = _isExpanded || !hasMore
        ? sessions
        : sessions.take(maxInitialItems).toList();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBF6ED).withValues(alpha: 0.94),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: const Border(
          top: BorderSide(color: Color(0xFFDEC5A4), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sessions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2B1D16),
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: sessions.isEmpty
                ? const Center(child: Text('No sessions recorded yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayedSessions.length +
                        (hasMore && !_isExpanded ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (hasMore &&
                          !_isExpanded &&
                          index == displayedSessions.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isExpanded = true;
                              });
                            },
                            icon: const Icon(Icons.expand_more),
                            label: const Text('Show more'),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFF3E3C3),
                              foregroundColor: const Color(0xFF2B1D16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        );
                      }

                      final session = displayedSessions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: session.isActive
                            ? Colors.green.shade50
                            : const Color(0xFFFFFDF9),
                        elevation: session.isActive ? 2 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: session.isActive
                              ? const BorderSide(color: Colors.green, width: 1.2)
                              : const BorderSide(
                                  color: Color(0xFFE2CCB0),
                                  width: 1,
                                ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: session.isActive
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : const Color(0xFFF3E3C3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              session.isActive ? Icons.play_arrow : Icons.check,
                              color: session.isActive
                                  ? Colors.green
                                  : const Color(0xFF6D5446),
                            ),
                          ),
                          title: Text(
                            DateFormatter.toReadableDate(session.date),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2B1D16),
                            ),
                          ),
                          subtitle: Text(
                            '${session.rounds.length} rounds recorded',
                            style: const TextStyle(color: Color(0xFF6D5446)),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF6D5446),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SessionDetailScreen(session: session),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
