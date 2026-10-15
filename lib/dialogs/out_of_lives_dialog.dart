import 'package:flutter/material.dart';
import '../models/game_theme.dart';
import '../services/storage_service.dart';

class OutOfLivesDialog extends StatelessWidget {
  final GameTheme theme;
  final VoidCallback onUseExtraHeart;
  final VoidCallback onWatchAd;
  final VoidCallback onSpendCoins;
  final VoidCallback onRestart;

  const OutOfLivesDialog({
    super.key,
    required this.theme,
    required this.onUseExtraHeart,
    required this.onWatchAd,
    required this.onSpendCoins,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final storage = StorageService();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title: "Out of Lives!"
            const Text(
              'Out of Lives!',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 28),

            // Big Circular Heart Badge with "+1" (matching video 01:21)
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 54,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Text(
                      '+1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Extra Heart button if available
            if (storage.extraHearts > 0) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onUseExtraHeart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  ),
                  child: Text('Use Extra Heart (${storage.extraHearts} left)', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Primary Blue Button: "Get More Lives 🎬" (as in video 01:21)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onWatchAd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Get More Lives',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.smart_display_rounded, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Secondary: "Restart Game" text button (as in video 01:21)
            TextButton(
              onPressed: onRestart,
              child: const Text(
                'Restart Game',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
