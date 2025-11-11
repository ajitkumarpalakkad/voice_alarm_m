// lib/audio_player.dart
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> play(String filePath) async {
    try {
      await _player.setFilePath(filePath);
      await _player.play();
      print("🔊 Playing: $filePath");
    } catch (e) {
      print("⚠️ Playback error: $e");
    }
  }

  void stop() {
    _player.stop();
  }
}
