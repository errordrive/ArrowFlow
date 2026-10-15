import 'package:flutter/material.dart';
import '../models/game_theme.dart';

class GameHeader extends StatelessWidget {
  final int levelNumber;
  final String difficultyLabel;
  final int hearts;
  final int maxHearts;
  final int remainingArrows;
  final GameTheme theme;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  const GameHeader({
    super.key,
    required this.levelNumber,
    required this.difficultyLabel,
    required this.hearts,
    required this.maxHearts,
    required this.remainingArrows,
    required this.theme,
    required this.onBack,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          children: [
            // Row 1: Back Button, "Level X", Settings Gear (as seen in video 00:23, 01:09)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                  color: const Color(0xFF2563EB),
                ),
                Text(
                  'Level $levelNumber',
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: onSettings,
                  icon: const Icon(Icons.settings_outlined, size: 24),
                  color: const Color(0xFF2563EB),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Row 2: Status Bar (🚀 Count, ❤️❤️❤️ Hearts, "Normal" badge) (video 00:24)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Rocket Icon + Remaining count
                Row(
                  children: [
                    const Icon(Icons.rocket_launch_rounded, size: 18, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      '$remainingArrows',
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // 3 Hearts in Center
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(maxHearts, (index) {
                    final isFilled = index < hearts;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: Icon(
                        isFilled ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 26,
                        color: isFilled ? const Color(0xFFEF4444) : const Color(0xFFCBD5E1),
                      ),
                    );
                  }),
                ),

                // Difficulty Pill Badge (e.g. "Normal" in video)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    difficultyLabel,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
