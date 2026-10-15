import 'package:flutter/material.dart';
import '../models/game_theme.dart';
import '../services/storage_service.dart';

class ThemesDialog extends StatefulWidget {
  final GameTheme currentTheme;
  final Function(GameTheme) onSelectTheme;

  const ThemesDialog({
    super.key,
    required this.currentTheme,
    required this.onSelectTheme,
  });

  @override
  State<ThemesDialog> createState() => _ThemesDialogState();
}

class _ThemesDialogState extends State<ThemesDialog> {
  final StorageService _storage = StorageService();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.currentTheme.boardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: widget.currentTheme.gridLineColor, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_rounded, color: Color(0xFF00F0FF), size: 26),
                const SizedBox(width: 8),
                Text(
                  'Themes & Skins',
                  style: TextStyle(
                    color: widget.currentTheme.textColor,
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
                itemCount: GameTheme.allThemes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final t = GameTheme.allThemes[index];
                  final isSelected = t.id == widget.currentTheme.id;

                  return InkWell(
                    onTap: () {
                      widget.onSelectTheme(t);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: t.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? t.accentColor : t.gridLineColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Color dots preview
                          Row(
                            children: t.arrowColors.take(4).map((c) {
                              return Container(
                                width: 14,
                                height: 14,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.name,
                              style: TextStyle(
                                color: t.textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded, color: t.accentColor, size: 20),
                        ],
                      ),
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
                style: TextStyle(color: widget.currentTheme.textColor.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
