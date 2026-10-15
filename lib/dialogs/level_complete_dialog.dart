import 'package:flutter/material.dart';
import '../models/game_theme.dart';

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
    int stars = isFlawless ? 3 : (heartsLeft >= 2 ? 2 : 1);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.boardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.accentColor.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: theme.accentColor.withOpacity(0.2),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stars Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final earned = index < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(
                    Icons.star_rounded,
                    size: index == 1 ? 48 : 38,
                    color: earned ? const Color(0xFFFFB800) : theme.textColor.withOpacity(0.2),
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),

            Text(
              isFlawless ? 'Flawless Clear!' : 'Level Completed!',
              style: TextStyle(
                color: theme.textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Level $completedLevel Solved',
              style: TextStyle(
                color: theme.textColor.withOpacity(0.6),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            // Coins earned pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFFB800).withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: Color(0xFFFFB800), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    '+$coinsEarned Coins',
                    style: const TextStyle(
                      color: Color(0xFFFFB800),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Next Level Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onNextLevel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.accentColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next Level ${completedLevel + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Main Menu Button
            TextButton(
              onPressed: onMenu,
              child: Text(
                'Main Menu',
                style: TextStyle(
                  color: theme.textColor.withOpacity(0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
