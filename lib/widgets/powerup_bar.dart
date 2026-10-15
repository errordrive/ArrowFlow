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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: theme.boardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: theme.gridLineColor,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Restart
              _PowerupItem(
                theme: theme,
                icon: Icons.refresh_rounded,
                label: 'Restart',
                badgeCount: null,
                isActive: false,
                onTap: onRestart,
              ),

              // Undo
              _PowerupItem(
                theme: theme,
                icon: Icons.undo_rounded,
                label: 'Undo',
                badgeCount: null,
                isActive: false,
                onTap: onUndo,
              ),

              // Eraser
              _PowerupItem(
                theme: theme,
                icon: Icons.auto_fix_high_rounded,
                label: 'Eraser',
                badgeCount: storage.erasers,
                isActive: isEraserActive,
                activeColor: const Color(0xFFFF007F),
                onTap: onEraser,
              ),

              // Hint
              _PowerupItem(
                theme: theme,
                icon: Icons.lightbulb_rounded,
                label: 'Hint',
                badgeCount: storage.hints,
                isActive: hasHintActive,
                activeColor: const Color(0xFF00F0FF),
                onTap: onHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PowerupItem extends StatelessWidget {
  final GameTheme theme;
  final IconData icon;
  final String label;
  final int? badgeCount;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _PowerupItem({
    required this.theme,
    required this.icon,
    required this.label,
    required this.badgeCount,
    required this.isActive,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? theme.accentColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? effectiveActiveColor.withOpacity(0.2)
                        : theme.cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? effectiveActiveColor
                          : theme.gridLineColor.withOpacity(0.6),
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: effectiveActiveColor.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: isActive
                        ? effectiveActiveColor
                        : theme.textColor.withOpacity(0.85),
                  ),
                ),

                if (badgeCount != null)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: effectiveActiveColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? effectiveActiveColor
                    : theme.textColor.withOpacity(0.7),
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
