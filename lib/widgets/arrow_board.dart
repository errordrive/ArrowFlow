import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/arrow.dart';
import '../models/direction.dart';
import '../models/game_theme.dart';
import '../models/grid_pos.dart';

class ArrowBoard extends StatefulWidget {
  final int rows;
  final int cols;
  final List<Arrow> arrows;
  final GameTheme theme;
  final Function(Arrow) onArrowTapped;
  final bool isTutorial;

  const ArrowBoard({
    super.key,
    required this.rows,
    required this.cols,
    required this.arrows,
    required this.theme,
    required this.onArrowTapped,
    this.isTutorial = false,
  });

  @override
  State<ArrowBoard> createState() => _ArrowBoardState();
}

class _ArrowBoardState extends State<ArrowBoard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(ArrowBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If any arrow started exiting, drive animation
    final hasExiting = widget.arrows.any((a) => a.isExiting);
    if (hasExiting && !_animController.isAnimating) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = 16.0;
        final maxW = constraints.maxWidth - padding * 2;
        final maxH = constraints.maxHeight - padding * 2;

        final cellSize = math.min(maxW / widget.cols, maxH / widget.rows);
        final boardW = cellSize * widget.cols;
        final boardH = cellSize * widget.rows;

        return Center(
          child: GestureDetector(
            onTapDown: (details) => _handleTap(details.localPosition, cellSize, boardW, boardH),
            child: Container(
              width: boardW,
              height: boardH,
              decoration: BoxDecoration(
                color: widget.theme.boardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.theme.gridLineColor.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _BoardPainter(
                  rows: widget.rows,
                  cols: widget.cols,
                  arrows: widget.arrows,
                  theme: widget.theme,
                  cellSize: cellSize,
                  animValue: _animController.value,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTap(Offset localPos, double cellSize, double boardW, double boardH) {
    // Check nearest arrow with expanded 24dp hit radius (PRD 5.7)
    Arrow? bestArrow;
    double minDistance = 28.0; // Comfort threshold

    for (final arrow in widget.arrows) {
      if (arrow.isExiting) continue;

      // Distance to any segment or cell center in arrow path
      for (int i = 0; i < arrow.path.length; i++) {
        final pos = arrow.path[i];
        final center = Offset(
          (pos.col + 0.5) * cellSize,
          (pos.row + 0.5) * cellSize,
        );

        final dist = (localPos - center).distance;
        if (dist < minDistance) {
          minDistance = dist;
          bestArrow = arrow;
        }
      }
    }

    if (bestArrow != null) {
      widget.onArrowTapped(bestArrow);
    }
  }
}

class _BoardPainter extends CustomPainter {
  final int rows;
  final int cols;
  final List<Arrow> arrows;
  final GameTheme theme;
  final double cellSize;
  final double animValue;

  _BoardPainter({
    required this.rows,
    required this.cols,
    required this.arrows,
    required this.theme,
    required this.cellSize,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGridBackground(canvas, size);

    // Draw normal arrows first, then animating/exiting arrows on top
    for (final arrow in arrows.where((a) => !a.isExiting)) {
      _drawArrow(canvas, arrow, size);
    }
    for (final arrow in arrows.where((a) => a.isExiting)) {
      _drawArrow(canvas, arrow, size);
    }
  }

  void _drawGridBackground(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = theme.gridLineColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Draw soft subtle cell background tiles
    final tilePaint = Paint()
      ..color = theme.backgroundColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final inset = cellSize * 0.08;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            c * cellSize + inset,
            r * cellSize + inset,
            cellSize - inset * 2,
            cellSize - inset * 2,
          ),
          Radius.circular(cellSize * 0.18),
        );
        canvas.drawRRect(rect, tilePaint);

        // Center dot
        canvas.drawCircle(
          Offset((c + 0.5) * cellSize, (r + 0.5) * cellSize),
          1.5,
          dotPaint,
        );
      }
    }
  }

  void _drawArrow(Canvas canvas, Arrow arrow, Size size) {
    canvas.save();

    final baseColor = theme.arrowColors[arrow.colorIndex % theme.arrowColors.length];
    Color renderColor = baseColor;

    // Handle Blocked shake & red flash
    if (arrow.isBlocked) {
      final shakeOffset = math.sin(animValue * math.pi * 8) * 6.0;
      canvas.translate(shakeOffset, 0);
      renderColor = const Color(0xFFFF2A4B); // Glowing Red
    }

    // Handle Exiting slide-off animation
    if (arrow.isExiting) {
      // Ease-in acceleration
      final t = Curves.easeInQuad.transform(animValue);
      final exitDist = cellSize * (math.max(rows, cols) + 3) * t;
      final dir = arrow.direction;
      canvas.translate(dir.dx * exitDist, dir.dy * exitDist);

      // Fade out near end of animation
      final alpha = (1.0 - t).clamp(0.0, 1.0);
      renderColor = renderColor.withOpacity(alpha);
    }

    // Handle Hint Pulsing Glow
    if (arrow.isHinted) {
      final glowPaint = Paint()
        ..color = const Color(0xFF00F0FF).withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.42
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      _drawArrowPath(canvas, arrow, glowPaint);
    }

    // Stroke width tailored to cell size
    final strokeWidth = cellSize * 0.22;

    // 1. Arrow Body
    final bodyPaint = Paint()
      ..color = renderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _drawArrowPath(canvas, arrow, bodyPaint);

    // 2. Arrowhead
    _drawArrowHead(canvas, arrow, renderColor, strokeWidth);

    canvas.restore();
  }

  void _drawArrowPath(Canvas canvas, Arrow arrow, Paint paint) {
    if (arrow.path.length < 2) return;

    final path = Path();
    final first = _cellCenter(arrow.path.first);
    path.moveTo(first.dx, first.dy);

    for (int i = 1; i < arrow.path.length; i++) {
      final p = _cellCenter(arrow.path[i]);
      path.lineTo(p.dx, p.dy);
    }

    canvas.drawPath(path, paint);
  }

  void _drawArrowHead(Canvas canvas, Arrow arrow, Color color, double strokeWidth) {
    final headPos = _cellCenter(arrow.head);
    final dir = arrow.direction;

    // Arrowhead size
    final headSize = cellSize * 0.38;

    canvas.save();
    canvas.translate(headPos.dx, headPos.dy);
    canvas.rotate(dir.angleRadians);

    final headPath = Path();
    // Modern stylized arrowhead pointing right (angle 0)
    final tipX = headSize * 0.55;
    final backX = -headSize * 0.45;
    final wingY = headSize * 0.5;

    headPath.moveTo(tipX, 0);
    headPath.lineTo(backX, -wingY);
    headPath.lineTo(backX * 0.4, 0);
    headPath.lineTo(backX, wingY);
    headPath.close();

    final headPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(headPath, headPaint);

    // Subtle arrowhead outline for crispness
    final headOutlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(headPath, headOutlinePaint);

    canvas.restore();
  }

  Offset _cellCenter(GridPos pos) {
    return Offset(
      (pos.col + 0.5) * cellSize,
      (pos.row + 0.5) * cellSize,
    );
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) {
    return true;
  }
}
