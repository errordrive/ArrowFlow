import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/arrow.dart';
import '../models/level.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'blocker_graph.dart';
import 'level_generator.dart';

class GameController extends ChangeNotifier {
  late GameLevel level;
  List<Arrow> activeArrows = [];
  final List<Arrow> removedArrowsHistory = [];
  late BlockerGraph graph;

  int hearts = 3;
  static const int maxHearts = 3;
  bool isFlawless = true;
  bool isLevelWon = false;
  bool isOutOfLives = false;
  bool isEraserActive = false;
  String? hintedArrowId;

  bool get isEraserMode => isEraserActive;
  bool get hasHintActive => hintedArrowId != null;
  void useHint() => triggerHint();
  void toggleEraserMode() => toggleEraser();
  void undo() => useUndo();

  final AudioService _audio = AudioService();
  final StorageService _storage = StorageService();

  GameController(int levelNumber) {
    loadLevel(levelNumber);
  }

  void loadLevel(int levelNumber) {
    level = LevelGenerator.generate(levelNumber);
    activeArrows = level.arrows.map((a) => a.copyWith()).toList();
    removedArrowsHistory.clear();
    hearts = maxHearts;
    isFlawless = true;
    isLevelWon = false;
    isOutOfLives = false;
    isEraserActive = false;
    hintedArrowId = null;

    _rebuildGraph();
    notifyListeners();
  }

  void _rebuildGraph() {
    graph = BlockerGraph(
      rows: level.rows,
      cols: level.cols,
      arrows: activeArrows.where((a) => !a.isExiting).toList(),
    );
  }

  void tapArrow(Arrow arrow) {
    if (arrow.isExiting || isLevelWon || isOutOfLives) return;

    // 1. Eraser mode
    if (isEraserActive) {
      if (_storage.useEraser()) {
        isEraserActive = false;
        _audio.playPowerUp();
        _startExitAnimation(arrow, isErased: true);
        notifyListeners();
      }
      return;
    }

    // 2. Normal tap - check if free
    final free = graph.isFree(arrow.id);

    if (free) {
      if (arrow.id == hintedArrowId) {
        hintedArrowId = null;
        arrow.isHinted = false;
      }
      _audio.playTapSuccess();
      _startExitAnimation(arrow);
    } else {
      // Blocked tap
      _audio.playTapBlocked();
      _triggerBlockedAnimation(arrow);
      hearts--;
      isFlawless = false;
      if (hearts <= 0) {
        isOutOfLives = true;
      }
    }

    notifyListeners();
  }

  void _triggerBlockedAnimation(Arrow arrow) {
    arrow.isBlocked = true;
    arrow.shakeProgress = 1.0;
    notifyListeners();

    // Auto-reset shake after 400ms
    Future.delayed(const Duration(milliseconds: 400), () {
      arrow.isBlocked = false;
      arrow.shakeProgress = 0.0;
      notifyListeners();
    });
  }

  void _startExitAnimation(Arrow arrow, {bool isErased = false}) {
    arrow.isExiting = true;
    arrow.isErased = isErased;
    arrow.exitProgress = 0.0;
    removedArrowsHistory.add(arrow);
    _storage.recordArrowCleared();

    // Rebuild graph immediately so dependent arrows become free right away
    _rebuildGraph();
    notifyListeners();

    // After animation duration, remove arrow completely and check win
    Future.delayed(const Duration(milliseconds: 320), () {
      activeArrows.removeWhere((a) => a.id == arrow.id);
      _rebuildGraph();

      if (activeArrows.isEmpty) {
        _onLevelCompleted();
      }
      notifyListeners();
    });
  }

  void _onLevelCompleted() {
    isLevelWon = true;
    _audio.playLevelComplete();

    // Reward coins: 10 base + flawless bonus 5
    int coinsEarned = 10 + (level.levelNumber ~/ 10);
    if (isFlawless) coinsEarned += 5;

    _storage.addCoins(coinsEarned);
    _storage.completeLevel(level.levelNumber, flawless: isFlawless);

    // Check achievements
    _storage.unlockAchievement('first_clear');
    if (level.levelNumber >= 10) _storage.unlockAchievement('ten_levels');
    if (level.levelNumber >= 50) _storage.unlockAchievement('fifty_levels');
    if (_storage.flawlessClears >= 5) _storage.unlockAchievement('flawless_five');
    if (_storage.totalArrowsCleared >= 100) _storage.unlockAchievement('hundred_arrows');

    notifyListeners();
  }

  void triggerHint() {
    if (hintedArrowId != null) return;
    if (_storage.useHint()) {
      final best = graph.getBestHintArrow();
      if (best != null) {
        hintedArrowId = best.id;
        best.isHinted = true;
        _audio.playPowerUp();
        notifyListeners();
      }
    }
  }

  void toggleEraser() {
    if (_storage.erasers > 0) {
      isEraserActive = !isEraserActive;
      _audio.playPowerUp();
      notifyListeners();
    }
  }

  void useUndo() {
    if (removedArrowsHistory.isNotEmpty) {
      final lastArrow = removedArrowsHistory.removeLast();
      lastArrow.isExiting = false;
      lastArrow.exitProgress = 0.0;
      lastArrow.isBlocked = false;
      lastArrow.isHinted = false;
      lastArrow.isErased = false;
      activeArrows.add(lastArrow);
      _rebuildGraph();
      _audio.playPowerUp();
      notifyListeners();
    }
  }

  void reviveWithExtraHeart() {
    if (_storage.useExtraHeart()) {
      hearts = 1;
      isOutOfLives = false;
      _audio.playPowerUp();
      notifyListeners();
    }
  }

  void reviveWithAd() {
    hearts = 1;
    isOutOfLives = false;
    _audio.playPowerUp();
    notifyListeners();
  }

  bool reviveWithCoins() {
    if (_storage.spendCoins(75)) {
      hearts = 1;
      isOutOfLives = false;
      _audio.playPowerUp();
      notifyListeners();
      return true;
    }
    return false;
  }

  void restartLevel() {
    loadLevel(level.levelNumber);
  }

  void nextLevel() {
    loadLevel(level.levelNumber + 1);
  }
}
