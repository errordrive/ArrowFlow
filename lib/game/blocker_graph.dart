import '../models/arrow.dart';
import '../models/grid_pos.dart';

class BlockerGraph {
  final int rows;
  final int cols;
  final List<Arrow> arrows;

  // arrowId -> set of arrowIds that sit on its exit ray (blocking this arrow)
  final Map<String, Set<String>> blockers = {};

  // arrowId -> set of arrowIds whose exit rays this arrow sits on (dependents)
  final Map<String, Set<String>> dependents = {};

  // Fast grid lookup: GridPos -> arrowId
  final Map<GridPos, String> gridOccupancy = {};

  BlockerGraph({
    required this.rows,
    required this.cols,
    required this.arrows,
  }) {
    _build();
  }

  void _build() {
    for (final arrow in arrows) {
      blockers[arrow.id] = <String>{};
      dependents[arrow.id] = <String>{};
      for (final pos in arrow.path) {
        gridOccupancy[pos] = arrow.id;
      }
    }

    for (final arrow in arrows) {
      final exitRay = arrow.getExitRay(rows, cols);
      for (final pos in exitRay) {
        final blockingId = gridOccupancy[pos];
        if (blockingId != null && blockingId != arrow.id) {
          blockers[arrow.id]!.add(blockingId);
          dependents[blockingId]?.add(arrow.id);
        }
      }
    }
  }

  bool isFree(String arrowId) {
    final b = blockers[arrowId];
    return b == null || b.isEmpty;
  }

  List<Arrow> getFreeArrows() {
    return arrows.where((a) => isFree(a.id)).toList();
  }

  /// Hint selection: pick a free arrow that unblocks the highest number of other arrows.
  Arrow? getBestHintArrow() {
    final freeArrows = getFreeArrows();
    if (freeArrows.isEmpty) return null;

    freeArrows.sort((a, b) {
      final depA = dependents[a.id]?.length ?? 0;
      final depB = dependents[b.id]?.length ?? 0;
      return depB.compareTo(depA); // Descending
    });

    return freeArrows.first;
  }

  /// Verifies if the graph is a Directed Acyclic Graph (DAG) and can be completely cleared.
  bool isSolvable() {
    // Clone blockers map
    final remainingBlockers = <String, Set<String>>{};
    for (final entry in blockers.entries) {
      remainingBlockers[entry.key] = Set.from(entry.value);
    }

    int clearedCount = 0;
    while (clearedCount < arrows.length) {
      String? nextFreeId;
      for (final entry in remainingBlockers.entries) {
        if (entry.value.isEmpty) {
          nextFreeId = entry.key;
          break;
        }
      }

      if (nextFreeId == null) {
        // Deadlock / cycle exists
        return false;
      }

      remainingBlockers.remove(nextFreeId);
      clearedCount++;

      // Remove cleared arrow from other arrows' blocker lists
      for (final blkSet in remainingBlockers.values) {
        blkSet.remove(nextFreeId);
      }
    }

    return true;
  }

  /// Computes maximum dependency chain depth
  int computeMaxChainDepth() {
    final depths = <String, int>{};

    int getDepth(String id, Set<String> visited) {
      if (depths.containsKey(id)) return depths[id]!;
      if (visited.contains(id)) return 0; // Prevent infinite cycle if any
      visited.add(id);

      final deps = dependents[id] ?? {};
      if (deps.isEmpty) {
        depths[id] = 1;
        return 1;
      }

      int maxChild = 0;
      for (final child in deps) {
        final d = getDepth(child, visited);
        if (d > maxChild) maxChild = d;
      }
      depths[id] = 1 + maxChild;
      return depths[id]!;
    }

    int maxD = 0;
    for (final arrow in arrows) {
      final d = getDepth(arrow.id, <String>{});
      if (d > maxD) maxD = d;
    }
    return maxD;
  }
}
