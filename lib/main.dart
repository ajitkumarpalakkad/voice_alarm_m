// lib/main.dart
import 'package:flutter/material.dart';
import 'alarm_manager.dart';
import 'snooze_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final AlarmManager alarmManager = AlarmManager();
  late final SnoozeHandler snoozeHandler;

  MyApp({super.key}) {
    snoozeHandler = SnoozeHandler(alarmManager);
    alarmManager.addAlarm("09:00", () => playAlarm("alarm_0900.wav"));
    alarmManager.startMonitoring();
  }

  void playAlarm(String fileName) {
    print("🔔 Playing alarm: $fileName");
    // TODO: Add audio playback logic here
  }

  void snoozeAlarm() {
    snoozeHandler.snooze("09:00", () => playAlarm("alarm_0900.wav"));
    print("⏸️ Snoozed for 1 minute");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Voice Alarm")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => playAlarm("alarm_0900.wav"),
                child: Text("Test Alarm"),
              ),
              ElevatedButton(
                onPressed: snoozeAlarm,
                child: Text("Snooze 1 Minute"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
