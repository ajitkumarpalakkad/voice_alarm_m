import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorderService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    await _recorder.openRecorder();
    _isInitialized = true;
    print("🎙️ Recorder initialized");
  }

  Future<String> _getFilePath(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$fileName';
  }

  Future<void> start(String fileName) async {
    await init();
    final path = await _getFilePath(fileName);
    await _recorder.startRecorder(toFile: path);
    print("🔴 Recording started → $path");
  }

  Future<void> stop() async {
    await _recorder.stopRecorder();
    print("✅ Recording stopped");
  }

  Future<void> dispose() async {
    await _recorder.closeRecorder();
    _isInitialized = false;
    print("🧹 Recorder disposed");
  }
}
