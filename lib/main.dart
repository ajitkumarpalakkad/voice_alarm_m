import 'package:flutter/material.dart';
import 'models/alarm_entry.dart';
import 'widgets/alarm_tile.dart'; // Update if your folder is named 'widgets'
import 'audio_player.dart';
import 'audio_recorder.dart';

void main() {
  runApp(const VoiceAlarmApp());
}

class VoiceAlarmApp extends StatelessWidget {
  const VoiceAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Alarm',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const AlarmHomePage(),
    );
  }
}

class AlarmHomePage extends StatefulWidget {
  const AlarmHomePage({super.key});

  @override
  State<AlarmHomePage> createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<AlarmHomePage> {
  final List<AlarmEntry> alarms = [
    AlarmEntry(
      label: "Alarm 1",
      time: TimeOfDay(hour: 7, minute: 0),
      fileName: "alarm_0700.wav",
    ),
    AlarmEntry(
      label: "Alarm 2",
      time: TimeOfDay(hour: 8, minute: 30),
      fileName: "alarm_0830.wav",
    ),
    AlarmEntry(
      label: "Alarm 3",
      time: TimeOfDay(hour: 9, minute: 45),
      fileName: "alarm_0945.wav",
    ),
    AlarmEntry(
      label: "Alarm 4",
      time: TimeOfDay(hour: 11, minute: 0),
      fileName: "alarm_1100.wav",
    ),
    AlarmEntry(
      label: "Alarm 5",
      time: TimeOfDay(hour: 13, minute: 15),
      fileName: "alarm_1315.wav",
    ),
  ];

  final player = AudioPlayerService();
  final recorder = AudioRecorderService();

  void setTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: alarms[index].time,
    );
    if (picked != null) {
      setState(() {
        alarms[index].time = picked;
        alarms[index].fileName =
            "alarm_${picked.hour.toString().padLeft(2, '0')}${picked.minute.toString().padLeft(2, '0')}.wav";
      });
      print("⏰ ${alarms[index].label} time set to ${picked.format(context)}");
    }
  }

  void recordVoice(int index) async {
    final fileName = alarms[index].fileName;
    await recorder.start(fileName);
  }

  void stopRecording() async {
    await recorder.stop();
  }

  void playVoice(int index) async {
    final fileName = alarms[index].fileName;
    await player.play(fileName);
  }

  void snoozeAlarm(int index) {
    print("⏸️ Snoozing ${alarms[index].label} for 1 minute");
    // TODO: Add snooze logic
  }

  void resetAlarm(int index) {
    setState(() {
      alarms[index].time = TimeOfDay(hour: 0, minute: 0);
      alarms[index].fileName = "";
    });
    print("❌ Reset ${alarms[index].label}");
  }

  @override
  void dispose() {
    recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice Alarm")),
      body: ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          final alarm = alarms[index];
          return AlarmTile(
            alarm: alarm,
            onSetTime: () => setTime(index),
            onRecord: () => recordVoice(index),
            onPlay: () => playVoice(index),
            onSnooze: () => snoozeAlarm(index),
            onReset: () => resetAlarm(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: stopRecording,
        child: const Icon(Icons.stop),
        tooltip: 'Stop Recording',
      ),
    );
  }
}
