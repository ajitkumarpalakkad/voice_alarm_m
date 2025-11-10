import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AudioRecorder {
  bool _isRecording = false;
  late File _outputFile;

  Future<void> start({String? path}) async {
    final dir = await getApplicationDocumentsDirectory();
    _outputFile = File(path ?? '${dir.path}/recorded.wav');
    // Simulate recording logic here
    _isRecording = true;
    print('Recording started...');
  }

  Future<String> stop() async {
    _isRecording = false;
    print('Recording stopped.');
    return _outputFile.path;
  }

  bool get isRecording => _isRecording;
}
