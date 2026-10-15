import 'package:flutter_test/flutter_test.dart';
import 'package:arrowpuzzle/game/blocker_graph.dart';
import 'package:arrowpuzzle/game/level_generator.dart';

void main() {
  group('LevelGenerator and BlockerGraph Tests', () {
    test('Tutorial Level 1 is valid, solvable, and has free arrows', () {
      final level = LevelGenerator.generate(1);
      expect(level.levelNumber, 1);
      expect(level.rows, 3);
      expect(level.cols, 3);
      expect(level.arrows.length, 3);

      final graph = BlockerGraph(
        rows: level.rows,
        cols: level.cols,
        arrows: level.arrows,
      );

      expect(graph.isSolvable(), isTrue);
      expect(graph.getFreeArrows().isNotEmpty, isTrue);
      expect(graph.getBestHintArrow(), isNotNull);
    });

    test('Tutorial Level 2 is solvable', () {
      final level = LevelGenerator.generate(2);
      expect(level.levelNumber, 2);

      final graph = BlockerGraph(
        rows: level.rows,
        cols: level.cols,
        arrows: level.arrows,
      );

      expect(graph.isSolvable(), isTrue);
      expect(graph.getFreeArrows().isNotEmpty, isTrue);
    });

    test('Procedural levels are deterministic and solvable', () {
      for (final lvlNum in [4, 10, 25]) {
        final levelA = LevelGenerator.generate(lvlNum);
        final levelB = LevelGenerator.generate(lvlNum);

        // Determinism test
        expect(levelA.arrows.length, levelB.arrows.length);
        expect(levelA.seed, levelB.seed);

        // Solvability test
        final graph = BlockerGraph(
          rows: levelA.rows,
          cols: levelA.cols,
          arrows: levelA.arrows,
        );

        expect(graph.isSolvable(), isTrue, reason: 'Level $lvlNum must be solvable');
        expect(graph.getFreeArrows().isNotEmpty, isTrue, reason: 'Level $lvlNum must have initial free arrow');
      }
    });
  });
}
