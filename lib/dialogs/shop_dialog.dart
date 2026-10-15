import 'package:flutter/material.dart';
import '../models/game_theme.dart';
import '../services/storage_service.dart';

class ShopDialog extends StatefulWidget {
  final GameTheme theme;
  final VoidCallback onUpdated;

  const ShopDialog({
    super.key,
    required this.theme,
    required this.onUpdated,
  });

  @override
  State<ShopDialog> createState() => _ShopDialogState();
}

class _ShopDialogState extends State<ShopDialog> {
  final StorageService _storage = StorageService();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.theme.boardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: widget.theme.gridLineColor, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront_rounded, color: Color(0xFFFFB800), size: 26),
                    const SizedBox(width: 8),
                    Text(
                      'Shop',
                      style: TextStyle(
                        color: widget.theme.textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Current Coins
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFB800).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on, color: Color(0xFFFFB800), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${_storage.coins}',
                        style: TextStyle(
                          color: widget.theme.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Item 1: Hint Pack (50 coins)
            _ShopItemTile(
              theme: widget.theme,
              icon: Icons.lightbulb_rounded,
              iconColor: const Color(0xFF00F0FF),
              name: '1x Hint',
              description: 'Reveals the best safe arrow',
              price: 50,
              canAfford: _storage.coins >= 50,
              onBuy: () {
                if (_storage.spendCoins(50)) {
                  _storage.addHint();
                  setState(() {});
                  widget.onUpdated();
                }
              },
            ),

            const SizedBox(height: 10),

            // Item 2: Extra Heart (75 coins)
            _ShopItemTile(
              theme: widget.theme,
              icon: Icons.favorite,
              iconColor: const Color(0xFFFF2A4B),
              name: '1x Extra Heart',
              description: 'Continue when lives reach zero',
              price: 75,
              canAfford: _storage.coins >= 75,
              onBuy: () {
                if (_storage.spendCoins(75)) {
                  _storage.addExtraHeart();
                  setState(() {});
                  widget.onUpdated();
                }
              },
            ),

            const SizedBox(height: 10),

            // Item 3: Eraser (100 coins)
            _ShopItemTile(
              theme: widget.theme,
              icon: Icons.auto_fix_high_rounded,
              iconColor: const Color(0xFFFF007F),
              name: '1x Eraser',
              description: 'Remove any arrow with zero penalty',
              price: 100,
              canAfford: _storage.coins >= 100,
              onBuy: () {
                if (_storage.spendCoins(100)) {
                  _storage.addEraser();
                  setState(() {});
                  widget.onUpdated();
                }
              },
            ),

            const SizedBox(height: 16),

            // Free Ad Reward for Coins
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.theme.accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.theme.accentColor.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.video_collection_rounded, color: widget.theme.accentColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Free Reward (+50 Coins)',
                          style: TextStyle(
                            color: widget.theme.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Watch a sponsored message',
                          style: TextStyle(
                            color: widget.theme.textColor.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _storage.addCoins(50);
                      setState(() {});
                      widget.onUpdated();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('+50 Coins earned!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.theme.accentColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Claim', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(color: widget.theme.textColor.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopItemTile extends StatelessWidget {
  final GameTheme theme;
  final IconData icon;
  final Color iconColor;
  final String name;
  final String description;
  final int price;
  final bool canAfford;
  final VoidCallback onBuy;

  const _ShopItemTile({
    required this.theme,
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.description,
    required this.price,
    required this.canAfford,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.gridLineColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: theme.textColor.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canAfford ? onBuy : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB800),
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.grey.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, size: 14, color: Colors.black),
                const SizedBox(width: 4),
                Text('$price', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
