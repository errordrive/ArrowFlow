import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../dialogs/achievements_dialog.dart';
import '../dialogs/daily_challenge_dialog.dart';
import '../dialogs/shop_dialog.dart';
import '../dialogs/themes_dialog.dart';
import '../models/game_theme.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final StorageService _storage = StorageService();
  final AudioService _audio = AudioService();
  late GameTheme _currentTheme;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _currentTheme = GameTheme.cyberNeon;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openGame(int level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          initialLevel: level,
          theme: _currentTheme,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _showLevelSelect() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _currentTheme.boardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: _currentTheme.gridLineColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Level',
                    style: TextStyle(
                      color: _currentTheme.textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.close, color: _currentTheme.textColor.withOpacity(0.7)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: math.max(30, _storage.currentLevel + 5),
                  itemBuilder: (context, index) {
                    final levelNum = index + 1;
                    final isUnlocked = levelNum <= _storage.currentLevel;
                    final isCurrent = levelNum == _storage.currentLevel;

                    return InkWell(
                      onTap: isUnlocked
                          ? () {
                              Navigator.pop(ctx);
                              _openGame(levelNum);
                            }
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? _currentTheme.accentColor
                              : (isUnlocked ? _currentTheme.cardColor : _currentTheme.backgroundColor.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCurrent
                                ? Colors.white
                                : (isUnlocked ? _currentTheme.gridLineColor : Colors.transparent),
                            width: isCurrent ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: isUnlocked
                              ? Text(
                                  '$levelNum',
                                  style: TextStyle(
                                    color: isCurrent ? Colors.black : _currentTheme.textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                )
                              : Icon(Icons.lock_rounded, size: 18, color: _currentTheme.textColor.withOpacity(0.25)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Top Bar: Coins Pill & Settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Coins
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => ShopDialog(
                          theme: _currentTheme,
                          onUpdated: () => setState(() {}),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _currentTheme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFFFB800).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Color(0xFFFFB800), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${_storage.coins}',
                            style: TextStyle(
                              color: _currentTheme.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.add_circle, color: _currentTheme.accentColor, size: 14),
                        ],
                      ),
                    ),
                  ),

                  // Themes quick button
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ThemesDialog(
                          currentTheme: _currentTheme,
                          onSelectTheme: (t) {
                            setState(() {
                              _currentTheme = t;
                            });
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.palette_rounded),
                    color: _currentTheme.textColor.withOpacity(0.9),
                    style: IconButton.styleFrom(
                      backgroundColor: _currentTheme.cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 1),

              // Animated Hero Logo
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + _pulseController.value * 0.04,
                    child: child,
                  );
                },
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _currentTheme.accentColor,
                        _currentTheme.arrowColors.first,
                        const Color(0xFFFF007F),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _currentTheme.accentColor.withOpacity(0.4),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.navigation_rounded,
                      size: 56,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'ArrowFlow',
                style: TextStyle(
                  color: _currentTheme.textColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'One-Tap Minimal Puzzle',
                style: TextStyle(
                  color: _currentTheme.textColor.withOpacity(0.6),
                  fontSize: 14,
                  letterSpacing: 0.8,
                ),
              ),

              const Spacer(flex: 2),

              // Big Play Button
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () => _openGame(_storage.currentLevel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentTheme.accentColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    elevation: 10,
                    shadowColor: _currentTheme.accentColor.withOpacity(0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 36),
                      const SizedBox(width: 8),
                      Text(
                        'Play Level ${_storage.currentLevel}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Level Select Button
              OutlinedButton(
                onPressed: _showLevelSelect,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _currentTheme.textColor,
                  side: BorderSide(color: _currentTheme.gridLineColor, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.grid_view_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Select Level',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons Row: Daily Challenge, Shop, Achievements
              Row(
                children: [
                  Expanded(
                    child: _MenuActionCard(
                      theme: _currentTheme,
                      icon: Icons.calendar_month_rounded,
                      iconColor: const Color(0xFFFFB800),
                      title: 'Daily',
                      subtitle: 'Challenge',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => DailyChallengeDialog(
                            theme: _currentTheme,
                            onPlayDaily: () => _openGame(15), // Curated daily puzzle level
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MenuActionCard(
                      theme: _currentTheme,
                      icon: Icons.storefront_rounded,
                      iconColor: const Color(0xFF00F0FF),
                      title: 'Shop',
                      subtitle: 'Items',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => ShopDialog(
                            theme: _currentTheme,
                            onUpdated: () => setState(() {}),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MenuActionCard(
                      theme: _currentTheme,
                      icon: Icons.emoji_events_rounded,
                      iconColor: const Color(0xFFFF007F),
                      title: 'Awards',
                      subtitle: 'Goals',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AchievementsDialog(theme: _currentTheme),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuActionCard extends StatelessWidget {
  final GameTheme theme;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuActionCard({
    required this.theme,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.gridLineColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: theme.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: theme.textColor.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
