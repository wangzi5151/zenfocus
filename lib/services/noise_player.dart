import 'package:just_audio/just_audio.dart';
import 'settings_provider.dart';

class NoisePlayer {
  static final NoisePlayer instance = NoisePlayer._();
  NoisePlayer._();

  AudioPlayer? _player;
  double _volume = 0.8;
  AmbientSound? _currentSound;

  static const _soundPaths = {
    AmbientSound.brownNoise: 'assets/sounds/brown_noise.wav',
    AmbientSound.whiteNoise: 'assets/sounds/white_noise.wav',
    AmbientSound.rain: 'assets/sounds/rain.wav',
    AmbientSound.forest: 'assets/sounds/forest.wav',
    AmbientSound.deepFocus: 'assets/sounds/deep_focus.wav',
  };

  Future<void> _load(AmbientSound sound) async {
    final path = _soundPaths[sound];
    if (path == null) return;
    try {
      _player?.dispose();
      final p = AudioPlayer();
      await p.setAsset(path);
      await p.setLoopMode(LoopMode.one);
      await p.setVolume(_volume);
      _player = p;
      _currentSound = sound;
    } catch (_) {
      _player = null;
    }
  }

  Future<void> setEnabled(bool on, {AmbientSound? sound}) async {
    final target = sound ?? AmbientSound.brownNoise;
    if (on) {
      if (_currentSound != target || _player == null) {
        await _load(target);
      }
      await _player?.play();
    } else {
      await _player?.pause();
    }
  }

  Future<void> setSound(AmbientSound sound) async {
    final wasPlaying = _player?.playing ?? false;
    await _load(sound);
    if (wasPlaying) {
      await _player?.play();
    }
  }

  Future<void> setVolume(double v) async {
    _volume = v;
    await _player?.setVolume(v);
  }
}
