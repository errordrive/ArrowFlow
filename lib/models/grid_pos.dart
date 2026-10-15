import 'direction.dart';

class GridPos {
  final int row;
  final int col;

  const GridPos(this.row, this.col);

  GridPos step(Direction dir) {
    return GridPos(row + dir.dy, col + dir.dx);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPos &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ (col.hashCode << 16);

  @override
  String toString() => '($row, $col)';
}
