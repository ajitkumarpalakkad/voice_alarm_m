import 'package:flutter/material.dart';
import 'alarm_manager.dart';

class SnoozeHandler {
  final AlarmManager alarmManager;

  SnoozeHandler(this.alarmManager);

  void snooze(
    String originalTimeKey,
    VoidCallback onTrigger, {
    int minutes = 1,
  }) {
    final parts = originalTimeKey.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]) + minutes;

    if (minute >= 60) {
      hour = (hour + 1) % 24;
      minute = minute % 60;
    }

    final snoozeKey =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    alarmManager.addAlarm(snoozeKey, onTrigger);
    print("🕒 Snooze scheduled for: $snoozeKey");
  }
}
