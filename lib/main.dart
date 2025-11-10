import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Alarm Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Voice Alarm Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Record recorder = Record();
  final AudioPlayer player = AudioPlayer();
  String? lastRecordedPath;

  @override
  void initState() {
    super.initState();
    startAlarmWatcher();
  }

  Future<void> requestMicPermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print("❌ Microphone permission not granted");
    } else {
      print("✅ Microphone permission granted");
    }
  }

  Future<void> startRecording() async {
    await requestMicPermission();

    final dir = await getApplicationDocumentsDirectory();
    final filePath = p.join(dir.path, 'recorded.wav');

    final isAvailable = await recorder.hasPermission();
    if (isAvailable) {
      await recorder.start(
        path: filePath,
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        samplingRate: 44100,
      );
      print("🎙️ Recording started at: $filePath");
    } else {
      print("❌ Recorder permission denied");
    }
  }

  Future<void> stopRecording() async {
    final path = await recorder.stop();
    final file = File(path ?? '');
    final exists = await file.exists();

    print("🛑 Recording stopped. File saved at: $path");
    print("📁 File exists: $exists");

    setState(() {
      lastRecordedPath = exists ? path : null;
    });
  }

  Future<void> playRecording() async {
    if (lastRecordedPath == null) {
      print("⚠️ No recording path available");
      return;
    }

    final file = File(lastRecordedPath!);
    final exists = await file.exists();

    print("▶️ Trying to play: $lastRecordedPath");
    print("📁 File exists: $exists");

    if (exists) {
      await player.play(DeviceFileSource(lastRecordedPath!));
      print("🔊 Playing: $lastRecordedPath");
    } else {
      print("❌ File not found");
    }
  }

  void startAlarmWatcher() {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      if (now.hour == 9 && now.minute == 0) {
        playRecording();
        print("🔔 Alarm triggered at 9:00 AM");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: startRecording,
              child: const Text("Start Recording"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: stopRecording,
              child: const Text("Stop Recording"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: playRecording,
              child: const Text("Play Recording"),
            ),
          ],
        ),
      ),
    );
  }
}
