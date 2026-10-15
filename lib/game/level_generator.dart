import 'dart:math' as math;
import '../models/arrow.dart';
import '../models/direction.dart';
import '../models/grid_pos.dart';
import '../models/level.dart';
import 'blocker_graph.dart';

class LevelGenerator {
  static const int globalSalt = 982341;

  static GameLevel generate(int levelNumber) {
    if (levelNumber == 1) {
      return _buildTutorialLevel1();
    } else if (levelNumber == 2) {
      return _buildTutorialLevel2();
    } else if (levelNumber == 3) {
      return _buildTutorialLevel3();
    }

    final seed = _hash(levelNumber, globalSalt);
    return _generateProceduralLevel(levelNumber, seed);
  }

  static int _hash(int a, int b) {
    var h = a ^ (b * 31);
    h = (h ^ (h >> 16)) * 0x45d9f3b;
    h = (h ^ (h >> 16)) * 0x45d9f3b;
    h = h ^ (h >> 16);
    return h.abs() & 0x7FFFFFFF;
  }

  static GameLevel _buildTutorialLevel1() {
    // 3x3 grid, 3 simple straight arrows
    // Arrow 1: at top pointing RIGHT (free!)
    // Arrow 2: at col 2 pointing DOWN (blocked by nothing after Arrow 1 or pointing down)
    // Arrow 3: pointing UP into Arrow 1
    final arrows = <Arrow>[
      Arrow(
        id: 'tut1_1',
        path: [const GridPos(0, 0), const GridPos(0, 1)], // points Right towards col 2.. exit!
        colorIndex: 0,
      ),
      Arrow(
        id: 'tut1_2',
        path: [const GridPos(2, 1), const GridPos(1, 1)], // points UP, blocked by (0,1) of arrow 1!
        colorIndex: 1,
      ),
      Arrow(
        id: 'tut1_3',
        path: [const GridPos(2, 2), const GridPos(1, 2)], // points UP towards col 2 exit
        colorIndex: 2,
      ),
    ];

    return const GameLevel(
      levelNumber: 1,
      rows: 3,
      cols: 3,
      arrows: [],
      difficultyLabel: 'Tutorial',
      difficultyScore: 1.0,
      seed: 101,
    ).copyWithArrows(arrows);
  }

  static GameLevel _buildTutorialLevel2() {
    // 4x4 grid, 5 arrows with a 3-step chain
    final arrows = <Arrow>[
      Arrow(
        id: 'tut2_1',
        path: [const GridPos(0, 1), const GridPos(0, 2), const GridPos(0, 3)], // points RIGHT -> free!
        colorIndex: 0,
      ),
      Arrow(
        id: 'tut2_2',
        path: [const GridPos(2, 2), const GridPos(1, 2)], // points UP into (0,2), blocked by tut2_1
        colorIndex: 1,
      ),
      Arrow(
        id: 'tut2_3',
        path: [const GridPos(2, 0), const GridPos(2, 1)], // points RIGHT into (2,2), blocked by tut2_2
        colorIndex: 2,
      ),
      Arrow(
        id: 'tut2_4',
        path: [const GridPos(3, 3), const GridPos(2, 3)], // points UP, free!
        colorIndex: 3,
      ),
      Arrow(
        id: 'tut2_5',
        path: [const GridPos(3, 1), const GridPos(3, 2)], // points RIGHT into tut2_4
        colorIndex: 4,
      ),
    ];

    return const GameLevel(
      levelNumber: 2,
      rows: 4,
      cols: 4,
      arrows: [],
      difficultyLabel: 'Tutorial',
      difficultyScore: 2.0,
      seed: 102,
    ).copyWithArrows(arrows);
  }

  static GameLevel _buildTutorialLevel3() {
    // 4x4 grid, 6 arrows with an L-shape bend
    final arrows = <Arrow>[
      // L-bend arrow: tail at (1,0) -> (1,1) -> (0,1), points UP!
      Arrow(
        id: 'tut3_1',
        path: [const GridPos(1, 0), const GridPos(1, 1), const GridPos(0, 1)], // points UP -> free!
        colorIndex: 0,
      ),
      Arrow(
        id: 'tut3_2',
        path: [const GridPos(0, 2), const GridPos(0, 3)], // points RIGHT -> free!
        colorIndex: 1,
      ),
      Arrow(
        id: 'tut3_3',
        path: [const GridPos(2, 1), const GridPos(2, 0)], // points LEFT -> free!
        colorIndex: 2,
      ),
      Arrow(
        id: 'tut3_4',
        path: [const GridPos(3, 2), const GridPos(2, 2), const GridPos(1, 2)], // points UP into tut3_2
        colorIndex: 3,
      ),
      Arrow(
        id: 'tut3_5',
        path: [const GridPos(3, 0), const GridPos(3, 1)], // points RIGHT into tut3_4
        colorIndex: 4,
      ),
      Arrow(
        id: 'tut3_6',
        path: [const GridPos(2, 3), const GridPos(1, 3)], // points UP into tut3_2
        colorIndex: 5,
      ),
    ];

    return const GameLevel(
      levelNumber: 3,
      rows: 4,
      cols: 4,
      arrows: [],
      difficultyLabel: 'Tutorial',
      difficultyScore: 3.0,
      seed: 103,
    ).copyWithArrows(arrows);
  }

  static GameLevel _generateProceduralLevel(int levelNumber, int seed) {
    final rng = math.Random(seed);

    // Determine grid size and target arrow count based on PRD curve
    int rows, cols, targetArrows;
    double pBend;
    double blockerBias;

    if (levelNumber <= 10) {
      rows = 5;
      cols = 5;
      targetArrows = 7 + (levelNumber - 4);
      pBend = 0.35;
      blockerBias = 0.5;
    } else if (levelNumber <= 30) {
      rows = 6;
      cols = 6;
      targetArrows = 12 + ((levelNumber - 11) * 0.5).toInt();
      pBend = 0.45;
      blockerBias = 0.65;
    } else if (levelNumber <= 70) {
      rows = 7;
      cols = 7;
      targetArrows = 18 + ((levelNumber - 31) * 0.4).toInt();
      pBend = 0.55;
      blockerBias = 0.75;
    } else if (levelNumber <= 150) {
      rows = 8;
      cols = 8;
      targetArrows = 26 + ((levelNumber - 71) * 0.3).toInt();
      pBend = 0.6;
      blockerBias = 0.8;
    } else {
      rows = 9;
      cols = 8;
      targetArrows = 36 + math.min(30, ((levelNumber - 151) * 0.25).toInt());
      pBend = 0.65;
      blockerBias = 0.85;
    }

    // Reverse construction algorithm
    List<Arrow> placedArrows = [];
    final occupied = <GridPos>{};

    for (int attempt = 0; attempt < 150 && placedArrows.length < targetArrows; attempt++) {
      // Find valid candidates
      final candidate = _tryCreateArrow(
        rows: rows,
        cols: cols,
        occupied: occupied,
        placedArrows: placedArrows,
        rng: rng,
        pBend: pBend,
        blockerBias: blockerBias,
        arrowIndex: placedArrows.length,
      );

      if (candidate != null) {
        placedArrows.add(candidate);
        occupied.addAll(candidate.path);
      }
    }

    // Analyze blocker graph and ensure solvability
    var graph = BlockerGraph(rows: rows, cols: cols, arrows: placedArrows);
    if (!graph.isSolvable() || graph.getFreeArrows().isEmpty) {
      // Fallback nudge: remove arrows that cause cycles or keep only solvable subset
      placedArrows = _extractSolvableSubset(rows, cols, placedArrows);
      graph = BlockerGraph(rows: rows, cols: cols, arrows: placedArrows);
    }

    // Ensure at least 1 free arrow exists initially
    if (graph.getFreeArrows().isEmpty && placedArrows.isNotEmpty) {
      // Clear path for the first arrow by removing any blockers
      final firstRay = placedArrows.first.getExitRay(rows, cols);
      placedArrows.removeWhere((a) => a.id != placedArrows.first.id && a.path.any((p) => firstRay.contains(p)));
      graph = BlockerGraph(rows: rows, cols: cols, arrows: placedArrows);
    }

    final diffLabel = GameLevel.getDifficultyLabel(levelNumber);
    final score = placedArrows.length * 1.5 + graph.computeMaxChainDepth() * 2.0;

    return GameLevel(
      levelNumber: levelNumber,
      rows: rows,
      cols: cols,
      arrows: placedArrows,
      difficultyLabel: diffLabel,
      difficultyScore: score,
      seed: seed,
    );
  }

  static Arrow? _tryCreateArrow({
    required int rows,
    required int cols,
    required Set<GridPos> occupied,
    required List<Arrow> placedArrows,
    required math.Random rng,
    required double pBend,
    required double blockerBias,
    required int arrowIndex,
  }) {
    // 1. Choose start cell (tail)
    GridPos? start;

    if (placedArrows.isNotEmpty && rng.nextDouble() < blockerBias) {
      // Prefer starting on the exit ray of an already-placed arrow to create blocking relationship
      final candidateStarts = <GridPos>[];
      for (final arrow in placedArrows) {
        final ray = arrow.getExitRay(rows, cols);
        for (final r in ray) {
          if (!occupied.contains(r)) {
            candidateStarts.add(r);
          }
        }
      }
      if (candidateStarts.isNotEmpty) {
        start = candidateStarts[rng.nextInt(candidateStarts.length)];
      }
    }

    if (start == null) {
      // Random empty cell
      final emptyCells = <GridPos>[];
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          final pos = GridPos(r, c);
          if (!occupied.contains(pos)) {
            emptyCells.add(pos);
          }
        }
      }
      if (emptyCells.isEmpty) return null;
      start = emptyCells[rng.nextInt(emptyCells.length)];
    }

    // 2. Walk path of length L (2 or 3)
    final path = <GridPos>[start];
    final desiredLength = rng.nextDouble() < 0.7 ? 2 : 3;

    // Pick initial direction
    final dirs = List<Direction>.from(Direction.values)..shuffle(rng);
    Direction currentDir = dirs.first;

    for (int step = 1; step < desiredLength; step++) {
      if (rng.nextDouble() < pBend) {
        // Bend orthogonally
        final possibleBends = Direction.values.where((d) => d != currentDir && d != currentDir.opposite).toList();
        possibleBends.shuffle(rng);
        for (final b in possibleBends) {
          final next = path.last.step(b);
          if (_isValidCell(next, rows, cols) && !occupied.contains(next) && !path.contains(next)) {
            currentDir = b;
            break;
          }
        }
      }

      final nextPos = path.last.step(currentDir);
      if (!_isValidCell(nextPos, rows, cols) || occupied.contains(nextPos) || path.contains(nextPos)) {
        // Try other orthogonal directions if blocked
        bool found = false;
        final altDirs = List<Direction>.from(Direction.values)..shuffle(rng);
        for (final alt in altDirs) {
          if (alt == currentDir.opposite) continue;
          final altPos = path.last.step(alt);
          if (_isValidCell(altPos, rows, cols) && !occupied.contains(altPos) && !path.contains(altPos)) {
            currentDir = alt;
            path.add(altPos);
            found = true;
            break;
          }
        }
        if (!found) break;
      } else {
        path.add(nextPos);
      }
    }

    if (path.length < 2) return null;

    final candidateArrow = Arrow(
      id: 'arrow_${arrowIndex}_${path.last.row}_${path.last.col}',
      path: path,
      colorIndex: arrowIndex % 8,
    );

    // 3. Rule of reverse construction:
    // Candidate arrow is accepted ONLY if its exit ray does NOT touch any arrow already placed!
    // (Because already-placed arrows are removed later, so they are still on board when this leaves).
    final exitRay = candidateArrow.getExitRay(rows, cols);
    for (final rayPos in exitRay) {
      if (occupied.contains(rayPos)) {
        return null; // Hits already placed arrow! Reject to preserve reverse-solvability
      }
    }

    return candidateArrow;
  }

  static bool _isValidCell(GridPos pos, int rows, int cols) {
    return pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < cols;
  }

  static List<Arrow> _extractSolvableSubset(int rows, int cols, List<Arrow> arrows) {
    final result = <Arrow>[];
    for (final arrow in arrows) {
      final testSet = [...result, arrow];
      final graph = BlockerGraph(rows: rows, cols: cols, arrows: testSet);
      if (graph.isSolvable()) {
        result.add(arrow);
      }
    }
    return result;
  }
}

extension GameLevelExt on GameLevel {
  GameLevel copyWithArrows(List<Arrow> newArrows) {
    return GameLevel(
      levelNumber: levelNumber,
      rows: rows,
      cols: cols,
      arrows: newArrows,
      difficultyLabel: difficultyLabel,
      difficultyScore: difficultyScore,
      seed: seed,
    );
  }
}
