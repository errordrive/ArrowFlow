import 'package:flutter/material.dart';
import '../models/game_theme.dart';
import '../services/storage_service.dart';

class PowerupBar extends StatelessWidget {
  final GameTheme theme;
  final bool isEraserActive;
  final bool hasHintActive;
  final VoidCallback onHint;
  final VoidCallback onEraser;
  final VoidCallback onUndo;
  final VoidCallback onRestart;

  const PowerupBar({
    super.key,
    required this.theme,
    required this.isEraserActive,
    required this.hasHintActive,
    required this.onHint,
    required this.onEraser,
    required this.onUndo,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final storage = StorageService();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hint Button (matching video 00:24 & 01:10)
            _FloatingToolButton(
              icon: Icons.lightbulb_rounded,
              iconColor: const Color(0xFFFFB800),
              badgeCount: storage.hints,
              isActive: hasHintActive,
              onTap: onHint,
            ),

            const SizedBox(width: 32),

            // Eraser Tool Button (matching video 00:24 & 01:10)
            _FloatingToolButton(
              icon: Icons.auto_fix_normal_rounded,
              iconColor: const Color(0xFF6366F1),
              badgeCount: storage.erasers,
              isActive: isEraserActive,
              onTap: onEraser,
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingToolButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int badgeCount;
  final bool isActive;
  final VoidCallback onTap;

  const _FloatingToolButton({
    required this.icon,
    required this.iconColor,
    required this.badgeCount,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                width: isActive ? 2.5 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
          ),

          // Blue Circular Badge for Count (matching video 00:24 & 01:10)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
