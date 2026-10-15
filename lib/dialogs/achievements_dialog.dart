import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/game_theme.dart';
import '../services/storage_service.dart';

class AchievementsDialog extends StatelessWidget {
  final GameTheme theme;

  const AchievementsDialog({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.boardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.gridLineColor, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFB800), size: 26),
                const SizedBox(width: 8),
                Text(
                  'Achievements',
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: Achievement.defaults.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final ach = Achievement.defaults[index];
                  final isUnlocked = storage.unlockedAchievements.contains(ach.id);

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUnlocked ? theme.accentColor.withOpacity(0.1) : theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUnlocked ? theme.accentColor.withOpacity(0.5) : theme.gridLineColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isUnlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                          color: isUnlocked ? theme.accentColor : Colors.grey,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ach.title,
                                style: TextStyle(
                                  color: theme.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                ach.description,
                                style: TextStyle(
                                  color: theme.textColor.withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB800).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.monetization_on, color: Color(0xFFFFB800), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '+${ach.rewardCoins}',
                                style: const TextStyle(
                                  color: Color(0xFFFFB800),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(color: theme.textColor.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
