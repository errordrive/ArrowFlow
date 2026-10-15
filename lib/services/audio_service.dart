import 'package:flutter/services.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool soundEnabled = true;
  bool hapticsEnabled = true;

  bool get vibrationEnabled => hapticsEnabled;
  set vibrationEnabled(bool val) => hapticsEnabled = val;

  void playTapSuccess() {
    if (hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    if (soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void playTapBlocked() {
    if (hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    if (soundEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  void playWhoosh() {
    if (hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
    if (soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void playPowerUp() {
    if (hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    if (soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void playLevelComplete() {
    if (hapticsEnabled) {
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 150), () {
        HapticFeedback.heavyImpact();
      });
    }
    if (soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}
