import 'direction.dart';
import 'grid_pos.dart';

class Arrow {
  final String id;
  final List<GridPos> path; // from tail (index 0) to head (index last)
  final int colorIndex;

  // Transient animation & UI states
  bool isExiting = false;
  double exitProgress = 0.0; // 0.0 to 1.0
  bool isBlocked = false;
  double shakeProgress = 0.0;
  bool isHinted = false;
  bool isErased = false;

  Arrow({
    required this.id,
    required this.path,
    this.colorIndex = 0,
  }) : assert(path.length >= 2, 'Arrow must have at least 2 cells');

  GridPos get head => path.last;
  GridPos get tail => path.first;

  int get length => path.length;

  Direction get direction {
    final secondLast = path[path.length - 2];
    final last = path.last;
    return Direction.fromDelta(last.col - secondLast.col, last.row - secondLast.row);
  }

  bool occupies(GridPos pos) {
    for (final p in path) {
      if (p == pos) return true;
    }
    return false;
  }

  /// Calculates exit ray: from next cell past head in direction until outside board
  List<GridPos> getExitRay(int rows, int cols) {
    final ray = <GridPos>[];
    final dir = direction;
    var current = head.step(dir);
    while (current.row >= 0 &&
        current.row < rows &&
        current.col >= 0 &&
        current.col < cols) {
      ray.add(current);
      current = current.step(dir);
    }
    return ray;
  }

  Arrow copyWith({
    String? id,
    List<GridPos>? path,
    int? colorIndex,
  }) {
    return Arrow(
      id: id ?? this.id,
      path: path ?? List.from(this.path),
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }
}
