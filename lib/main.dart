import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(VoiceAlarmApp());
}

class VoiceAlarmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Multi Voice Alarm', home: AlarmScreen());
  }
}

class AlarmData {
  String title;
  TimeOfDay? time;
  int snoozeMinutes;
  DateTime? snoozedUntil;
  bool isOn;
  String filePath;
  bool isRecording;
  bool isPlaying;
  AudioPlayer? player;

  AlarmData({
    required this.title,
    this.time,
    this.snoozeMinutes = 5,
    this.snoozedUntil,
    this.isOn = false,
    required this.filePath,
    this.isRecording = false,
    this.isPlaying = false,
    this.player,
  });
}

class AlarmScreen extends StatefulWidget {
  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  late FlutterSoundRecorder _recorder;
  List<AlarmData> alarms = [];
  late List<TextEditingController> _titleControllers;
  int currentIndex = 0;
  Timer? _alarmChecker;
  Timer? _snoozeChecker;

  // Password lock
  String _password = "ajit123"; // change to your password
  bool isUnlocked = false;
  TextEditingController _pwController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _initAlarms();
    _startAlarmMonitor();
    _startSnoozeMonitor();
  }

  Future<void> _initRecorder() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) return;
    _recorder = FlutterSoundRecorder();
    await _recorder.openRecorder();
  }

  void _initAlarms() async {
    final dir = await getApplicationDocumentsDirectory();
    alarms = [];
    _titleControllers = [];
    for (int i = 0; i < 5; i++) {
      alarms.add(
        AlarmData(
          title: "Alarm ${i + 1}",
          filePath: '${dir.path}/alarm_${i + 1}.aac',
        ),
      );
      _titleControllers.add(TextEditingController(text: "Alarm ${i + 1}"));
    }
    setState(() {});
  }

  AlarmData get currentAlarm => alarms[currentIndex];
  TextEditingController get currentController =>
      _titleControllers[currentIndex];

  void _startAlarmMonitor() {
    _alarmChecker = Timer.periodic(Duration(seconds: 1), (_) {
      for (var alarm in alarms) {
        if (alarm.isOn && alarm.time != null) {
          final now = DateTime.now();
          if (alarm.snoozedUntil != null && now.isBefore(alarm.snoozedUntil!))
            continue;
          if (now.hour == alarm.time!.hour &&
              now.minute == alarm.time!.minute &&
              now.second == 0) {
            _playAlarmRecording(alarm);
          }
        }
      }
    });
  }

  void _startSnoozeMonitor() {
    _snoozeChecker = Timer.periodic(Duration(seconds: 1), (_) {
      for (var alarm in alarms) {
        if (alarm.isOn &&
            alarm.snoozedUntil != null &&
            DateTime.now().isAfter(alarm.snoozedUntil!)) {
          alarm.snoozedUntil = null;
          _playAlarmRecording(alarm);
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _alarmChecker?.cancel();
    _snoozeChecker?.cancel();
    _recorder.closeRecorder();
    for (var alarm in alarms) {
      alarm.player?.dispose();
    }
    super.dispose();
  }

  Future<void> _startRecording() async {
    await Future.delayed(Duration(milliseconds: 500));
    await _recorder.startRecorder(
      toFile: currentAlarm.filePath,
      codec: Codec.aacADTS,
    );
    setState(() => currentAlarm.isRecording = true);
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() => currentAlarm.isRecording = false);
  }

  Future<void> _playRecordingOnce() async {
    final file = File(currentAlarm.filePath);
    if (!file.existsSync()) return;
    final player = AudioPlayer();
    await player.setReleaseMode(ReleaseMode.stop);
    await player.play(DeviceFileSource(currentAlarm.filePath));
  }

  Future<void> _playAlarmRecording(AlarmData alarm) async {
    if (alarm.isPlaying) return;
    final file = File(alarm.filePath);
    if (!file.existsSync()) return;
    alarm.isPlaying = true;
    alarm.player = AudioPlayer();
    await alarm.player!.setReleaseMode(ReleaseMode.stop);
    await alarm.player!.play(DeviceFileSource(alarm.filePath));
    alarm.player!.onPlayerComplete.listen((event) {
      alarm.isPlaying = false;
      if (alarm.isOn && alarm.snoozedUntil == null) {
        _playAlarmRecording(alarm);
      }
    });
  }

  void _snoozeAlarm() {
    if (!currentAlarm.isOn) return;
    currentAlarm.snoozedUntil = DateTime.now().add(
      Duration(minutes: currentAlarm.snoozeMinutes),
    );
    currentAlarm.player?.stop();
    currentAlarm.isPlaying = false;
    setState(() {});
  }

  void _alarmOff() {
    currentAlarm.snoozedUntil = null;
    currentAlarm.isOn = false;
    currentAlarm.player?.stop();
    currentAlarm.isPlaying = false;
    setState(() {});
  }

  void _resetAlarm() {
    currentAlarm.snoozedUntil = null;
    currentAlarm.time = null;
    currentAlarm.isOn = false;
    currentAlarm.isRecording = false;
    currentAlarm.player?.stop();
    currentAlarm.isPlaying = false;

    // ✅ Reset title back to default and update controller
    String defaultTitle = "Alarm ${currentIndex + 1}";
    currentAlarm.title = defaultTitle;
    currentController.text = defaultTitle;

    final file = File(currentAlarm.filePath);
    if (file.existsSync()) file.deleteSync();
    setState(() {});
  }

  Future<void> _pickAlarmTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        currentAlarm.time = picked;
        currentAlarm.isOn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Password lock screen
    if (!isUnlocked) {
      return Scaffold(
        appBar: AppBar(title: Text("Enter Password")),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _pwController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_pwController.text == _password) {
                    setState(() => isUnlocked = true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Incorrect password")),
                    );
                  }
                },
                child: Text("Unlock"),
              ),
            ],
          ),
        ),
      );
    }

    // Alarm UI once unlocked
    return Scaffold(
      appBar: AppBar(title: Text('Multi Voice Alarm')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Navigation arrows with fixed labels
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_left),
                  onPressed: () {
                    setState(() {
                      currentIndex =
                          (currentIndex - 1 + alarms.length) % alarms.length;
                    });
                  },
                ),
                Text(
                  "Alarm ${currentIndex + 1}", // ✅ fixed label
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right),
                  onPressed: () {
                    setState(() {
                      currentIndex = (currentIndex + 1) % alarms.length;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),

            // Editable title field in bold
            TextField(
              controller: currentController,
              maxLength: 20,
              style: TextStyle(fontWeight: FontWeight.bold), // ✅ bold
              decoration: InputDecoration(labelText: "Alarm Title"),
              onChanged: (val) {
                setState(() {
                  currentAlarm.title = val;
                });
              },
            ),
            SizedBox(height: 20),

            // Buttons row: Record / Play
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: currentAlarm.isRecording
                        ? _stopRecording
                        : _startRecording,
                    child: Text(currentAlarm.isRecording ? 'Stop' : 'Record'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _playRecordingOnce,
                    child: Text('Play'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Second row: Snooze, Alarm Off, Reset
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _snoozeAlarm,
                    child: Text('Snooze'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _alarmOff,
                    child: Text('Alarm Off'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetAlarm,
                    child: Text('Reset'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Snooze dropdown + Set Alarm Time
            Row(
              children: [
                Text('Snooze:'),
                SizedBox(width: 10),
                DropdownButton<int>(
                  value: currentAlarm.snoozeMinutes,
                  items: List.generate(30, (i) => i + 1).map((min) {
                    return DropdownMenuItem(
                      value: min,
                      child: Text('$min min'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => currentAlarm.snoozeMinutes = value!);
                  },
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: _pickAlarmTime,
                  child: Text('Set Alarm Time'),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Info display
            if (currentAlarm.snoozedUntil != null)
              Text(
                'Snoozed until: ${currentAlarm.snoozedUntil!.toLocal().toString().split('.').first}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            if (currentAlarm.time != null)
              Text(
                'Alarm time set to: ${currentAlarm.time!.format(context)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 20),

            // Status row
            Row(
              children: [
                Text('Alarm Status: ', style: TextStyle(fontSize: 16)),
                Icon(
                  currentAlarm.isOn ? Icons.alarm_on : Icons.alarm_off,
                  color: currentAlarm.isOn ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
