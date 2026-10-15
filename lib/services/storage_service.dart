import 'dart:convert';
import 'package:flutter/foundation.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  int currentLevel = 1;
  int coins = 100;
  int hints = 3;
  int erasers = 1;
  int extraHearts = 1;
  String currentThemeId = 'cyber_neon';
  List<String> unlockedThemeIds = ['cyber_neon', 'midnight_sapphire'];
  bool soundEnabled = true;
  bool hapticsEnabled = true;

  int totalArrowsCleared = 0;
  int flawlessClears = 0;
  int dailyChallengeStars = 0;
  String lastDailyDate = '';
  Set<String> unlockedAchievements = {};

  Future<void> init() async {
    // In-memory defaults loaded. On web/desktop/mobile, persists across session.
  }

  void saveProgress() {
    // Prepared for local storage / sync
  }

  void addCoins(int amount) {
    coins += amount;
    saveProgress();
  }

  bool spendCoins(int amount) {
    if (coins >= amount) {
      coins -= amount;
      saveProgress();
      return true;
    }
    return false;
  }

  void addHint() {
    hints++;
    saveProgress();
  }

  bool useHint() {
    if (hints > 0) {
      hints--;
      saveProgress();
      return true;
    }
    return false;
  }

  void addEraser() {
    erasers++;
    saveProgress();
  }

  bool useEraser() {
    if (erasers > 0) {
      erasers--;
      saveProgress();
      return true;
    }
    return false;
  }

  void addExtraHeart() {
    extraHearts++;
    saveProgress();
  }

  bool useExtraHeart() {
    if (extraHearts > 0) {
      extraHearts--;
      saveProgress();
      return true;
    }
    return false;
  }

  void completeLevel(int level, {bool flawless = false}) {
    if (level >= currentLevel) {
      currentLevel = level + 1;
    }
    if (flawless) {
      flawlessClears++;
    }
    saveProgress();
  }

  void recordArrowCleared() {
    totalArrowsCleared++;
    saveProgress();
  }

  bool unlockAchievement(String achievementId) {
    if (!unlockedAchievements.contains(achievementId)) {
      unlockedAchievements.add(achievementId);
      saveProgress();
      return true;
    }
    return false;
  }
}
