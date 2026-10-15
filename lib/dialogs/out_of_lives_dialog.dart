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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.boardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.redAccent.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.2),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Broken Heart Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.heart_broken_rounded,
                size: 48,
                color: Color(0xFFFF2A4B),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Out of Lives!',
              style: TextStyle(
                color: theme.textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Choose how to continue this level:',
              style: TextStyle(
                color: theme.textColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            // 1. Extra Heart (if owned)
            if (storage.extraHearts > 0) ...[
              _ActionTile(
                theme: theme,
                icon: Icons.favorite,
                iconColor: const Color(0xFFFF2A4B),
                title: 'Use Extra Heart',
                subtitle: 'Owned: ${storage.extraHearts}',
                onTap: onUseExtraHeart,
              ),
              const SizedBox(height: 10),
            ],

            // 2. Watch Ad for +1 Heart
            _ActionTile(
              theme: theme,
              icon: Icons.play_circle_filled_rounded,
              iconColor: const Color(0xFF00F0FF),
              title: 'Watch Ad (+1 Heart)',
              subtitle: 'Free revive',
              onTap: onWatchAd,
            ),

            const SizedBox(height: 10),

            // 3. Spend 75 Coins
            _ActionTile(
              theme: theme,
              icon: Icons.monetization_on,
              iconColor: const Color(0xFFFFB800),
              title: 'Spend 75 Coins',
              subtitle: 'Your balance: ${storage.coins}',
              enabled: storage.coins >= 75,
              onTap: onSpendCoins,
            ),

            const SizedBox(height: 10),

            // 4. Restart Level
            _ActionTile(
              theme: theme,
              icon: Icons.refresh_rounded,
              iconColor: theme.textColor.withOpacity(0.7),
              title: 'Restart Level',
              subtitle: 'Reset board with 3 hearts',
              onTap: onRestart,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final GameTheme theme;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionTile({
    required this.theme,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.cardColor.withOpacity(enabled ? 1.0 : 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.gridLineColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: enabled ? iconColor : Colors.grey, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: enabled ? theme.textColor : Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.textColor.withOpacity(enabled ? 0.6 : 0.3),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.textColor.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
