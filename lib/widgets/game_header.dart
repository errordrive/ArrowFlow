import 'package:flutter/material.dart';
import '../models/game_theme.dart';
import '../services/storage_service.dart';

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
    final storage = StorageService();

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            // Top Row: Back, Level Title, Settings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  color: theme.textColor.withOpacity(0.8),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                // Level & Difficulty Badge
                Column(
                  children: [
                    Text(
                      'Level $levelNumber',
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.accentColor.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        difficultyLabel.toUpperCase(),
                        style: TextStyle(
                          color: theme.accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),

                IconButton(
                  onPressed: onSettings,
                  icon: const Icon(Icons.settings, size: 20),
                  color: theme.textColor.withOpacity(0.8),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Secondary Row: Hearts, Arrows remaining, Coins
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Hearts
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(maxHearts, (index) {
                      final isFilled = index < hearts;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Icon(
                          isFilled ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFilled ? const Color(0xFFFF2A4B) : theme.textColor.withOpacity(0.3),
                        ),
                      );
                    }),
                  ),
                ),

                // Remaining Arrows Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.navigation, size: 14, color: theme.accentColor),
                      const SizedBox(width: 6),
                      Text(
                        '$remainingArrows left',
                        style: TextStyle(
                          color: theme.textColor.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Coins Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFB800).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on, size: 16, color: Color(0xFFFFB800)),
                      const SizedBox(width: 4),
                      Text(
                        '${storage.coins}',
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
