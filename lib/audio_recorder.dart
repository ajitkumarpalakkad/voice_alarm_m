// lib/audio_recorder.dart
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AudioRecorder {
  final Record _record = Record();
  late String _outputPath;

  Future<void> start(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory('${dir.path}/recordings');
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }

    _outputPath = '${recordingsDir.path}/$fileName';
    await _record.start(path: _outputPath);
    print("🎙️ Recording started: $_outputPath");
  }

  Future<String> stop() async {
    await _record.stop();
    print("🛑 Recording stopped.");
    return _outputPath;
  }

  Future<bool> isRecording() async {
    return await _record.isRecording();
  }
}
