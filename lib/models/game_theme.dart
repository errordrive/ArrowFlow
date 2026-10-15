import 'package:flutter/material.dart';

class GameTheme {
  final String id;
  final String name;
  final Color backgroundColor;
  final Color boardColor;
  final Color gridLineColor;
  final List<Color> arrowColors;
  final Color accentColor;
  final Color textColor;
  final Color cardColor;

  const GameTheme({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.boardColor,
    required this.gridLineColor,
    required this.arrowColors,
    required this.accentColor,
    required this.textColor,
    required this.cardColor,
  });

  static const GameTheme cyberNeon = GameTheme(
    id: 'cyber_neon',
    name: 'Cyber Neon',
    backgroundColor: Color(0xFF0D1117),
    boardColor: Color(0xFF161B22),
    gridLineColor: Color(0xFF21262D),
    arrowColors: [
      Color(0xFF00F0FF), // Bright Cyan
      Color(0xFFFF007F), // Vivid Magenta
      Color(0xFF39FF14), // Electric Lime
      Color(0xFFFFB800), // Bright Amber
      Color(0xFF9D00FF), // Neon Purple
      Color(0xFFFF3366), // Coral Pink
      Color(0xFF00E5FF), // Aqua Blue
      Color(0xFF76FF03), // Chartreuse
    ],
    accentColor: Color(0xFF00F0FF),
    textColor: Colors.white,
    cardColor: Color(0xFF1F242C),
  );

  static const GameTheme midnightSapphire = GameTheme(
    id: 'midnight_sapphire',
    name: 'Midnight Sapphire',
    backgroundColor: Color(0xFF080D1A),
    boardColor: Color(0xFF0F172A),
    gridLineColor: Color(0xFF1E293B),
    arrowColors: [
      Color(0xFF38BDF8), // Sky Blue
      Color(0xFF818CF8), // Indigo
      Color(0xFF34D399), // Emerald
      Color(0xFFF472B6), // Pink
      Color(0xFFFBBF24), // Amber
      Color(0xFFA78BFA), // Violet
      Color(0xFF2DD4BF), // Teal
      Color(0xFFFB7185), // Rose
    ],
    accentColor: Color(0xFF38BDF8),
    textColor: Colors.white,
    cardColor: Color(0xFF1E293B),
  );

  static const GameTheme sunsetAmber = GameTheme(
    id: 'sunset_amber',
    name: 'Sunset Amber',
    backgroundColor: Color(0xFF1A0E0E),
    boardColor: Color(0xFF261515),
    gridLineColor: Color(0xFF3A2020),
    arrowColors: [
      Color(0xFFFF6B6B), // Soft Red
      Color(0xFFFFA07A), // Light Salmon
      Color(0xFFFFD166), // Warm Yellow
      Color(0xFFFF8E72), // Peach
      Color(0xFFFF5E7E), // Rose
      Color(0xFFE056FD), // Lilac
      Color(0xFFFF9F43), // Tangerine
      Color(0xFFFECA57), // Sunbeam
    ],
    accentColor: Color(0xFFFF9F43),
    textColor: Colors.white,
    cardColor: Color(0xFF2E1A1A),
  );

  static const GameTheme emeraldForest = GameTheme(
    id: 'emerald_forest',
    name: 'Emerald Forest',
    backgroundColor: Color(0xFF0A140F),
    boardColor: Color(0xFF12241B),
    gridLineColor: Color(0xFF1A382A),
    arrowColors: [
      Color(0xFF10B981), // Emerald
      Color(0xFF34D399), // Mint
      Color(0xFF6EE7B7), // Seafoam
      Color(0xFF2DD4BF), // Teal
      Color(0xFFA7F3D0), // Pastel Green
      Color(0xFF059669), // Deep Emerald
      Color(0xFF38BDF8), // Cyan
      Color(0xFFFBBF24), // Gold
    ],
    accentColor: Color(0xFF10B981),
    textColor: Colors.white,
    cardColor: Color(0xFF183226),
  );

  static const GameTheme minimalMonochrome = GameTheme(
    id: 'minimal_monochrome',
    name: 'Minimal Dark',
    backgroundColor: Color(0xFF121212),
    boardColor: Color(0xFF1E1E1E),
    gridLineColor: Color(0xFF2C2C2C),
    arrowColors: [
      Color(0xFFFFFFFF),
      Color(0xFFE0E0E0),
      Color(0xFFCCCCCC),
      Color(0xFFB0B0B0),
      Color(0xFF64B5F6),
      Color(0xFF81C784),
      Color(0xFFFFB74D),
      Color(0xFFBA68C8),
    ],
    accentColor: Color(0xFFFFFFFF),
    textColor: Colors.white,
    cardColor: Color(0xFF252525),
  );

  static List<GameTheme> get allThemes => [
        cyberNeon,
        midnightSapphire,
        sunsetAmber,
        emeraldForest,
        minimalMonochrome,
      ];
}
