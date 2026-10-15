import 'package:flutter/material.dart';
import '../dialogs/achievements_dialog.dart';
import '../dialogs/level_complete_dialog.dart';
import '../dialogs/out_of_lives_dialog.dart';
import '../dialogs/shop_dialog.dart';
import '../game/game_controller.dart';
import '../models/game_theme.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/arrow_board.dart';
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
  bool _showImpressiveToast = false;

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

      // Show "Impressive!" toast (matching video 00:28)
      setState(() {
        _showImpressiveToast = true;
      });

      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          _showImpressiveToast = false;
        });

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

  // Options Sheet (Matching video 01:30)
  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Options',
                      style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildOptionTile(
                  icon: Icons.settings_rounded,
                  iconColor: const Color(0xFF2563EB),
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showSettingsSubSheet();
                  },
                ),
                _buildOptionTile(
                  icon: Icons.help_outline_rounded,
                  iconColor: const Color(0xFF22C55E),
                  title: 'Help',
                  onTap: () => _showDialog('Help', 'Tap free arrows to guide them safely off the board! Avoid hitting blocked arrows.'),
                ),
                _buildOptionTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF64748B),
                  title: 'About Game',
                  onTap: () => _showDialog('About Game', 'ArrowFlow v1.0.0\nPure Flutter logic puzzle game.'),
                ),
                _buildOptionTile(
                  icon: Icons.description_outlined,
                  iconColor: const Color(0xFF9333EA),
                  title: 'Privacy Rights',
                  onTap: () => _showDialog('Privacy Rights', 'We respect your data and privacy rights.'),
                ),
                _buildOptionTile(
                  icon: Icons.shield_outlined,
                  iconColor: const Color(0xFF0891B2),
                  title: 'Privacy Preferences',
                  onTap: () => _showDialog('Privacy Preferences', 'Manage personalized preferences.'),
                ),
                _buildOptionTile(
                  icon: Icons.block_rounded,
                  iconColor: const Color(0xFFDC2626),
                  title: 'Remove Ads',
                  onTap: () {
                    Navigator.pop(ctx);
                    showDialog(
                      context: context,
                      builder: (_) => ShopDialog(theme: _currentTheme, onUpdated: () => setState(() {})),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
    );
  }

  void _showSettingsSubSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSubState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Settings',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Sounds', style: TextStyle(fontWeight: FontWeight.w600)),
                      value: _audio.soundEnabled,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: (val) {
                        setSubState(() => _audio.soundEnabled = val);
                        setState(() {});
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Vibration', style: TextStyle(fontWeight: FontWeight.w600)),
                      value: _audio.vibrationEnabled,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: (val) {
                        setSubState(() => _audio.vibrationEnabled = val);
                        setState(() {});
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Auto-Lock', style: TextStyle(fontWeight: FontWeight.w600)),
                      value: false,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: (val) {},
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Column(
            children: [
              // Game Header with Back, Level, Settings, Rocket Count, Hearts, Difficulty
              GameHeader(
                levelNumber: _controller.level.levelNumber,
                difficultyLabel: _controller.level.difficultyLabel,
                hearts: _controller.hearts,
                maxHearts: GameController.maxHearts,
                remainingArrows: _controller.activeArrows.length,
                theme: _currentTheme,
                onBack: () => Navigator.pop(context),
                onSettings: _showOptionsSheet,
              ),

              // Board Canvas
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ArrowBoard(
                    rows: _controller.level.rows,
                    cols: _controller.level.cols,
                    arrows: _controller.activeArrows,
                    theme: _currentTheme,
                    isTutorial: _controller.level.levelNumber == 1,
                    onArrowTapped: (arrow) {
                      _controller.tapArrow(arrow);
                    },
                  ),
                ),
              ),

              // Bottom Floating Power-Ups: Hint & Eraser (matching video 00:24 & 01:10)
              PowerupBar(
                theme: _currentTheme,
                isEraserActive: _controller.isEraserMode,
                hasHintActive: _controller.hasHintActive,
                onHint: () {
                  _controller.useHint();
                  setState(() {});
                },
                onEraser: () {
                  _controller.toggleEraserMode();
                  setState(() {});
                },
                onUndo: () {
                  _controller.undo();
                  setState(() {});
                },
                onRestart: () {
                  _controller.restartLevel();
                  setState(() {});
                },
              ),
            ],
          ),

          // "Impressive!" Praise Toast (matching video 00:28)
          if (_showImpressiveToast)
            Center(
              child: AnimatedOpacity(
                opacity: _showImpressiveToast ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('😊', style: TextStyle(fontSize: 26)),
                      SizedBox(width: 10),
                      Text(
                        'Impressive!',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
