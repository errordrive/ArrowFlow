import 'package:flutter/material.dart';
import '../models/game_theme.dart';
import '../widgets/confetti_overlay.dart';

class LevelCompleteDialog extends StatelessWidget {
  final int completedLevel;
  final bool isFlawless;
  final int coinsEarned;
  final int heartsLeft;
  final GameTheme theme;
  final VoidCallback onNextLevel;
  final VoidCallback onMenu;

  const LevelCompleteDialog({
    super.key,
    required this.completedLevel,
    required this.isFlawless,
    required this.coinsEarned,
    required this.heartsLeft,
    required this.theme,
    required this.onNextLevel,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Stack(
        children: [
          // 1. Radiant Blue Gradient Background (as seen in video 00:19, 00:29)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.9,
                  colors: [
                    Color(0xFF38BDF8), // Radiant Sky Blue
                    Color(0xFF1D4ED8), // Deep Royal Blue
                  ],
                ),
              ),
            ),
          ),

          // 2. Confetti Particles Overlay
          const Positioned.fill(
            child: ConfettiOverlay(),
          ),

          // 3. Center Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // "Level Completed!" Header
                  const Text(
                    'Level Completed!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // White Preview Card (matching video 00:19 & 00:29)
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 68,
                            color: const Color(0xFF2563EB),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Level $completedLevel',
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFB800), size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '+$coinsEarned Coins',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // "Next Game" Pill Button (matching video 00:21 & 00:31)
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton(
                      onPressed: onNextLevel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2563EB),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Next Game',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Level ${completedLevel + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF2563EB).withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // "Main" Text Button below it
                  TextButton(
                    onPressed: onMenu,
                    child: const Text(
                      'Main',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
