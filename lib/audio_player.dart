// lib/audio_player.dart
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> play(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);

    if (!file.existsSync()) {
      print("❌ File not found: $filePath");
      return;
    }

    try {
      await _player.play(DeviceFileSource(filePath));
      print("🔊 Playing: $filePath");
    } catch (e) {
      print("⚠️ Playback error: $e");
    }
  }

  Future<void> stop() async {
    await _player.stop();
    print("⏹️ Playback stopped");
  }
}
