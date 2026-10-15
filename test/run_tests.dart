import '../lib/game/blocker_graph.dart';
import '../lib/game/level_generator.dart';

void main() {
  print('--- Testing Tutorial Level 1 ---');
  final lvl1 = LevelGenerator.generate(1);
  print('Level 1: ${lvl1.rows}x${lvl1.cols}, ${lvl1.arrows.length} arrows');
  assert(lvl1.arrows.length == 3);

  final graph1 = BlockerGraph(
    rows: lvl1.rows,
    cols: lvl1.cols,
    arrows: lvl1.arrows,
  );
  assert(graph1.isSolvable(), 'Level 1 must be solvable');
  assert(graph1.getFreeArrows().isNotEmpty, 'Level 1 must have free arrows');
  print('Level 1 PASSED! Free arrows: ${graph1.getFreeArrows().map((a) => a.id).toList()}');

  print('--- Testing Tutorial Level 2 ---');
  final lvl2 = LevelGenerator.generate(2);
  final graph2 = BlockerGraph(rows: lvl2.rows, cols: lvl2.cols, arrows: lvl2.arrows);
  assert(graph2.isSolvable(), 'Level 2 must be solvable');
  assert(graph2.getFreeArrows().isNotEmpty, 'Level 2 must have free arrows');
  print('Level 2 PASSED! Free arrows: ${graph2.getFreeArrows().map((a) => a.id).toList()}');

  print('--- Testing Tutorial Level 3 ---');
  final lvl3 = LevelGenerator.generate(3);
  final graph3 = BlockerGraph(rows: lvl3.rows, cols: lvl3.cols, arrows: lvl3.arrows);
  assert(graph3.isSolvable(), 'Level 3 must be solvable');
  assert(graph3.getFreeArrows().isNotEmpty, 'Level 3 must have free arrows');
  print('Level 3 PASSED! Free arrows: ${graph3.getFreeArrows().map((a) => a.id).toList()}');

  print('--- Testing Procedural Levels 4, 10, 25, 50 ---');
  for (final lvlNum in [4, 10, 25, 50]) {
    final lvl = LevelGenerator.generate(lvlNum);
    final g = BlockerGraph(rows: lvl.rows, cols: lvl.cols, arrows: lvl.arrows);
    assert(g.isSolvable(), 'Level $lvlNum must be solvable');
    assert(g.getFreeArrows().isNotEmpty, 'Level $lvlNum must have free arrows');
    print('Level $lvlNum: ${lvl.rows}x${lvl.cols}, ${lvl.arrows.length} arrows, Diff: ${lvl.difficultyLabel}, Chain: ${g.computeMaxChainDepth()} PASSED!');
  }

  print('\n>>> ALL LEVEL GENERATION AND SOLVABILITY TESTS PASSED! <<<');
}
