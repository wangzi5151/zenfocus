import 'package:just_audio/just_audio.dart';

class NoisePlayer {
  static final NoisePlayer instance = NoisePlayer._();
  NoisePlayer._();
  AudioPlayer? _player;
  double _volume = 0.8;

  Future<void> _ensure() async {
    if (_player != null) return;
    try {
      final p = AudioPlayer();
      await p.setAsset('assets/sounds/brown_noise.wav');
      await p.setLoopMode(LoopMode.one);
      await p.setVolume(_volume);
      _player = p;
    } catch (_) {
      _player = null;
    }
  }

  Future<void> setEnabled(bool on) async {
    if (on) {
      await _ensure();
      await _player?.play();
    } else {
      await _player?.pause();
    }
  }

  Future<void> setVolume(double v) async {
    _volume = v;
    await _player?.setVolume(v);
  }
}
