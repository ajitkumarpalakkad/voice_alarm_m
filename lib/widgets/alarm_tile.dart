import 'package:flutter/material.dart';
import '../models/alarm_entry.dart';

class AlarmTile extends StatelessWidget {
  final AlarmEntry alarm;
  final VoidCallback onSetTime;
  final VoidCallback onRecord;
  final VoidCallback onPlay;
  final VoidCallback onSnooze;
  final VoidCallback onReset;

  const AlarmTile({
    super.key,
    required this.alarm,
    required this.onSetTime,
    required this.onRecord,
    required this.onPlay,
    required this.onSnooze,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alarm.label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Time: ${alarm.time.format(context)}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: onSetTime,
                  child: const Text("Set Time"),
                ),
                ElevatedButton(
                  onPressed: onRecord,
                  child: const Text("Record"),
                ),
                ElevatedButton(onPressed: onPlay, child: const Text("Play")),
                ElevatedButton(
                  onPressed: onSnooze,
                  child: const Text("Snooze"),
                ),
                ElevatedButton(onPressed: onReset, child: const Text("Reset")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
