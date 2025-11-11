import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'alarm_manager.dart';
import 'snooze_handler.dart';
import 'audio_player.dart';
import 'audio_recorder.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AlarmManager alarmManager = AlarmManager();
  final AudioPlayerService audioPlayer = AudioPlayerService();
  final AudioRecorder recorder = AudioRecorder();
  late final SnoozeHandler snoozeHandler;

  @override
  void initState() {
    super.initState();
    snoozeHandler = SnoozeHandler(alarmManager);

    // Schedule initial alarm at 09:00
    alarmManager.addAlarm("09:00", () => playAlarm("alarm_0900.wav"));
    alarmManager.startMonitoring();
  }

  Future<void> startRecording() async {
    await recorder.start("alarm_0900.wav");
  }

  Future<void> stopRecording() async {
    String path = await recorder.stop();
    print("✅ Saved recording at: $path");
  }

  Future<void> playAlarm(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/recordings/$fileName";
    final file = File(filePath);

    if (await file.exists()) {
      audioPlayer.play(filePath);
    } else {
      print("⚠️ File not found: $filePath");
    }
  }

  void snoozeAlarm() {
    final now = TimeOfDay.now();
    final key =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    snoozeHandler.snooze(key, () => playAlarm("alarm_0900.wav"), minutes: 1);
    print("⏸️ Snoozed for 1 minute");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Voice Alarm")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => playAlarm("alarm_0900.wav"),
                child: const Text("Test Alarm"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: snoozeAlarm,
                child: const Text("Snooze 1 Minute"),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: startRecording,
                icon: const Icon(Icons.mic),
                label: const Text("Start Recording"),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: stopRecording,
                icon: const Icon(Icons.stop),
                label: const Text("Stop Recording"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
