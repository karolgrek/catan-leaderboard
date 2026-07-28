import 'package:flutter/material.dart';

import '../../providers/group_provider.dart';
import '../../utils/snackbar_helper.dart';

void showStartRoundDialog(BuildContext context, GroupProvider provider, String sessionId, List<dynamic> sessionMembers) {
  List<String> selectedForRound = [];
  List<String> selectedExpansions = [];
  final expansions = ['Seafarers', 'Cities & Knights', 'Traders & Barbarians', 'Explorers & Pirates'];
  final TextEditingController notesController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.play_circle_fill, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text('Start Round'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Players', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...sessionMembers.map((player) {
                    bool isSelected = selectedForRound.contains(player.uid);
                    return CheckboxListTile(
                      title: Text(player.name),
                      value: isSelected,
                      dense: true,
                      activeColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selectedForRound.add(player.uid);
                          } else {
                            selectedForRound.remove(player.uid);
                          }
                        });
                      },
                    );
                  }).toList(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(),
                  ),
                  const Text('Expansions (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...expansions.map((exp) {
                    bool isSelected = selectedExpansions.contains(exp);
                    return CheckboxListTile(
                      title: Text(exp),
                      value: isSelected,
                      dense: true,
                      activeColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selectedExpansions.add(exp);
                          } else {
                            selectedExpansions.remove(exp);
                          }
                        });
                      },
                    );
                  }).toList(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(),
                  ),
                  const Text('Notes (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      hintText: 'Any special notes for this round?',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (selectedForRound.isEmpty) {
                    SnackbarHelper.showError(context, 'Select at least 1 player');
                    return;
                  }
                  Navigator.pop(context);
                  await provider.addRound(sessionId, selectedForRound, selectedExpansions, notesController.text.trim());
                },
                child: const Text('Start'),
              )
            ],
          );
        },
      );
    },
  );
}


