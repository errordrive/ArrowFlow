import 'package:flutter/material.dart';
import '../dialogs/level_complete_dialog.dart';
import '../dialogs/out_of_lives_dialog.dart';
import '../dialogs/shop_dialog.dart';
import '../game/game_controller.dart';
import '../models/game_theme.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/arrow_board.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/game_header.dart';
import '../widgets/powerup_bar.dart';

class GameScreen extends StatefulWidget {
  final int initialLevel;
  final GameTheme theme;

  const GameScreen({
    super.key,
    required this.initialLevel,
    required this.theme,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _controller;
  late GameTheme _currentTheme;
  final AudioService _audio = AudioService();
  final StorageService _storage = StorageService();

  bool _isOutOfLivesDialogOpen = false;
  bool _isWinDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.theme;
    _controller = GameController(widget.initialLevel);
    _controller.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onGameStateChanged() {
    setState(() {});

    if (_controller.isOutOfLives && !_isOutOfLivesDialogOpen) {
      _isOutOfLivesDialogOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => OutOfLivesDialog(
            theme: _currentTheme,
            onUseExtraHeart: () {
              Navigator.pop(ctx);
              _isOutOfLivesDialogOpen = false;
              _controller.reviveWithExtraHeart();
            },
            onWatchAd: () {
              Navigator.pop(ctx);
              _isOutOfLivesDialogOpen = false;
              _controller.reviveWithAd();
            },
            onSpendCoins: () {
              if (_controller.reviveWithCoins()) {
                Navigator.pop(ctx);
                _isOutOfLivesDialogOpen = false;
              }
            },
            onRestart: () {
              Navigator.pop(ctx);
              _isOutOfLivesDialogOpen = false;
              _controller.restartLevel();
            },
          ),
        ).then((_) {
          _isOutOfLivesDialogOpen = false;
        });
      });
    }

    if (_controller.isLevelWon && !_isWinDialogOpen) {
      _isWinDialogOpen = true;
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => LevelCompleteDialog(
            completedLevel: _controller.level.levelNumber,
            isFlawless: _controller.isFlawless,
            coinsEarned: 10 + (_controller.level.levelNumber ~/ 10) + (_controller.isFlawless ? 5 : 0),
            heartsLeft: _controller.hearts,
            theme: _currentTheme,
            onNextLevel: () {
              Navigator.pop(ctx);
              _isWinDialogOpen = false;
              _controller.nextLevel();
            },
            onMenu: () {
              Navigator.pop(ctx);
              _isWinDialogOpen = false;
              Navigator.pop(context);
            },
          ),
        ).then((_) {
          _isWinDialogOpen = false;
        });
      });
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _currentTheme.boardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: _currentTheme.gridLineColor),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: _currentTheme.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: Text('Sound Effects', style: TextStyle(color: _currentTheme.textColor)),
                    value: _audio.soundEnabled,
                    activeColor: _currentTheme.accentColor,
                    onChanged: (val) {
                      setModalState(() {
                        _audio.soundEnabled = val;
                      });
                      setState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: Text('Haptic Vibration', style: TextStyle(color: _currentTheme.textColor)),
                    value: _audio.hapticsEnabled,
                    activeColor: _currentTheme.accentColor,
                    onChanged: (val) {
                      setModalState(() {
                        _audio.hapticsEnabled = val;
                      });
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      showDialog(
                        context: context,
                        builder: (_) => ShopDialog(
                          theme: _currentTheme,
                          onUpdated: () => setState(() {}),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentTheme.cardColor,
                      foregroundColor: _currentTheme.textColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.storefront_rounded, color: Color(0xFFFFB800)),
                        SizedBox(width: 8),
                        Text('Open Shop'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentTheme.backgroundColor,
      body: Stack(
        children: [
          // Main Column layout
          Column(
            children: [
              GameHeader(
                levelNumber: _controller.level.levelNumber,
                difficultyLabel: _controller.level.difficultyLabel,
                hearts: _controller.hearts,
                maxHearts: GameController.maxHearts,
                remainingArrows: _controller.activeArrows.length,
                theme: _currentTheme,
                onBack: () => Navigator.pop(context),
                onSettings: _showSettings,
              ),

              // Board Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ArrowBoard(
                        rows: _controller.level.rows,
                        cols: _controller.level.cols,
                        arrows: _controller.activeArrows,
                        theme: _currentTheme,
                        onArrowTapped: (arrow) {
                          _controller.tapArrow(arrow);
                        },
                      ),

                      // Tutorial tip on Level 1
                      if (_controller.level.levelNumber == 1 && _controller.activeArrows.length == 3)
                        Positioned(
                          top: 24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _currentTheme.accentColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _currentTheme.accentColor.withOpacity(0.4),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.touch_app_rounded, color: Colors.black, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Tap the free arrow to slide it off!',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom Powerup Bar
              PowerupBar(
                theme: _currentTheme,
                isEraserActive: _controller.isEraserActive,
                hasHintActive: _controller.hintedArrowId != null,
                onHint: () => _controller.triggerHint(),
                onEraser: () => _controller.toggleEraser(),
                onUndo: () => _controller.useUndo(),
                onRestart: () => _controller.restartLevel(),
              ),
            ],
          ),

          // Confetti Celebration
          if (_controller.isLevelWon)
            const ConfettiOverlay(),
        ],
      ),
    );
  }
}
