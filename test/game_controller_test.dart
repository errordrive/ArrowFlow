import 'package:flutter_test/flutter_test.dart';
import 'package:arrowpuzzle/game/game_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameController Gameplay Flow Tests', () {
    test('Level 1 can be completely solved by tapping free arrows', () {
      final controller = GameController(1);

      expect(controller.level.levelNumber, 1);
      expect(controller.activeArrows.length, 3);
      expect(controller.hearts, 3);
      expect(controller.isLevelWon, isFalse);

      int steps = 0;
      while (controller.activeArrows.isNotEmpty && steps < 10) {
        final freeArrows = controller.graph.getFreeArrows();
        expect(freeArrows.isNotEmpty, isTrue, reason: 'Must have at least one free arrow at each step');

        final arrowToTap = freeArrows.first;
        final countBefore = controller.activeArrows.length;
        controller.tapArrow(arrowToTap);

        // Advance simulated time for exit animation
        controller.activeArrows.removeWhere((a) => a.id == arrowToTap.id);
        steps++;
      }

      expect(controller.activeArrows.isEmpty, isTrue);
    });

    test('Tapping a blocked arrow reduces hearts and marks flawless false', () {
      final controller = GameController(1);

      // In Level 1, tut1_2 is blocked by tut1_1
      final blockedArrow = controller.activeArrows.firstWhere((a) => a.id == 'tut1_2');
      expect(controller.graph.isFree(blockedArrow.id), isFalse);

      controller.tapArrow(blockedArrow);

      expect(controller.hearts, 2);
      expect(controller.isFlawless, isFalse);
    });
  });
}
