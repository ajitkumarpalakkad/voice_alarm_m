import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(VoiceAlarmApp());
}

class VoiceAlarmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Voice Alarm', home: AlarmScreen());
  }
}

class AlarmScreen extends StatefulWidget {
  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  int _alarmId = 1;

  late String _filePath = '';

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    final micStatus = await Permission.microphone.request();

    print('Microphone permission: $micStatus');

    if (!micStatus.isGranted) {
      print('Microphone permission not granted. Recording will fail.');
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Microphone Permission Required'),
            content: Text(
              'Please grant microphone permission to record audio.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
                child: Text('Open Settings'),
              ),
            ],
          ),
        );
      }
      return;
    }

    await _recorder.openRecorder();

    final dir = await getApplicationDocumentsDirectory();
    _filePath = '${dir.path}/alarm_$_alarmId.aac';
    print('Initialized file path: $_filePath');
  }

  Future<void> _startRecording() async {
    if (_filePath.isEmpty) {
      print('Cannot start recording: file path not initialized.');
      return;
    }

    await Future.delayed(
      Duration(milliseconds: 500),
    ); // Ensure recorder is ready

    await _recorder.startRecorder(
      toFile: _filePath,
      codec: Codec.aacADTS, // Use AAC format for better compatibility
    );

    setState(() => _isRecording = true);
    print('Recording started: $_filePath');
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() => _isRecording = false);
    print('Recording stopped: $_filePath');

    final file = File(_filePath);
    print('File exists after recording: ${file.existsSync()}');
    if (file.existsSync()) {
      print('File size: ${file.lengthSync()} bytes');
    }
  }

  Future<void> _playRecording() async {
    final file = File(_filePath);
    print('Attempting to play: $_filePath');
    print('File exists before playback: ${file.existsSync()}');
    if (file.existsSync()) {
      print('File size: ${file.lengthSync()} bytes');
    }

    if (!file.existsSync()) {
      print('Playback failed: file does not exist');
      return;
    }

    final player = AudioPlayer();
    try {
      await player.setReleaseMode(ReleaseMode.stop);
      await player.play(DeviceFileSource(_filePath));
      print('Playback started');
    } catch (e) {
      print('Playback error: $e');
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voice Alarm $_alarmId')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _playRecording,
              child: Text('Play Recording'),
            ),
          ],
        ),
      ),
    );
  }
}
