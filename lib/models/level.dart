import 'arrow.dart';

class GameLevel {
  final int levelNumber;
  final int rows;
  final int cols;
  final List<Arrow> arrows;
  final String difficultyLabel;
  final double difficultyScore;
  final int seed;

  const GameLevel({
    required this.levelNumber,
    required this.rows,
    required this.cols,
    required this.arrows,
    required this.difficultyLabel,
    this.difficultyScore = 0.0,
    this.seed = 0,
  });

  int get totalArrows => arrows.length;

  static String getDifficultyLabel(int level) {
    if (level <= 3) return 'Tutorial';
    if (level <= 10) return 'Easy';
    if (level <= 30) return 'Normal';
    if (level <= 70) return 'Hard';
    if (level <= 150) return 'Expert';
    if (level <= 300) return 'Master';
    return 'Insane';
  }
}
