import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service managing background music looping and UI audio feedback.
class AudioService {
  AudioPlayer? _musicPlayer;
  final bool enableAudio;
  bool _isMusicPlaying = false;
  bool _musicEnabled = true;
  bool _soundEnabled = true;

  AudioService({this.enableAudio = true}) {
    if (enableAudio) {
      _musicPlayer = AudioPlayer();
      _initMusic();
    }
  }

  Future<void> _initMusic() async {
    try {
      await _musicPlayer?.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer?.setVolume(0.2);
    } catch (e) {
      debugPrint('[AudioService] Failed to initialize music player: $e');
    }
  }

  void updateSettings({required bool musicEnabled, required bool soundEnabled}) {
    _musicEnabled = musicEnabled;
    _soundEnabled = soundEnabled;
    if (!_musicEnabled && _isMusicPlaying) {
      pauseMusic();
    }
  }

  Future<void> startMusic() async {
    if (!_musicEnabled || _isMusicPlaying || _musicPlayer == null) return;
    try {
      await _musicPlayer?.play(AssetSource('audio/puzzle_music.mp3'));
      _isMusicPlaying = true;
    } catch (e) {
      debugPrint('[AudioService] Error playing puzzle music: $e');
    }
  }

  Future<void> pauseMusic() async {
    if (!_isMusicPlaying || _musicPlayer == null) return;
    try {
      await _musicPlayer?.pause();
      _isMusicPlaying = false;
    } catch (e) {
      debugPrint('[AudioService] Error pausing music: $e');
    }
  }

  Future<void> playFeedback() async {
    if (!_soundEnabled) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      debugPrint('[AudioService] Error playing feedback sound: $e');
    }
  }

  void dispose() {
    _musicPlayer?.dispose();
  }
}
