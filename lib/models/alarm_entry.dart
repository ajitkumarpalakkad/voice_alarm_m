import 'package:flutter/material.dart';

class AlarmEntry {
  final String label; // e.g., "Alarm 1"
  TimeOfDay time;
  String fileName;

  AlarmEntry({required this.label, required this.time, required this.fileName});

  String get timeKey =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
