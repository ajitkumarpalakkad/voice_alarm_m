// lib/alarm_manager.dart
import 'dart:async';
import 'package:flutter/material.dart';

class AlarmManager {
  final Map<String, VoidCallback> alarms = {};

  void addAlarm(String timeKey, VoidCallback onTrigger) {
    alarms[timeKey] = onTrigger;
  }

  void startMonitoring() {
    Timer.periodic(Duration(seconds: 30), (timer) {
      final now = TimeOfDay.now();
      final key =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      print("⏰ Checking time: $key — Alarms: ${alarms.keys.toList()}");
      if (alarms.containsKey(key)) {
        print("🔔 Triggering alarm for $key");
        alarms[key]!();
      }
    });
  }
}
