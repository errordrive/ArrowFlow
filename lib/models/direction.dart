import 'dart:math' as math;

enum Direction {
  up(0, -1),
  right(1, 0),
  down(0, 1),
  left(-1, 0);

  final int dx;
  final int dy;

  const Direction(this.dx, this.dy);

  Direction get opposite {
    switch (this) {
      case Direction.up:
        return Direction.down;
      case Direction.right:
        return Direction.left;
      case Direction.down:
        return Direction.up;
      case Direction.left:
        return Direction.right;
    }
  }

  double get angleRadians {
    switch (this) {
      case Direction.up:
        return -math.pi / 2;
      case Direction.right:
        return 0;
      case Direction.down:
        return math.pi / 2;
      case Direction.left:
        return math.pi;
    }
  }

  static Direction fromDelta(int dx, int dy) {
    if (dx > 0) return Direction.right;
    if (dx < 0) return Direction.left;
    if (dy > 0) return Direction.down;
    return Direction.up;
  }
}
