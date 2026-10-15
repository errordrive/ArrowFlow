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

class _ArrowBoardState extends State<ArrowBoard> with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _tutorialController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() {
        setState(() {});
      });

    _tutorialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(ArrowBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasExiting = widget.arrows.any((a) => a.isExiting);
    if (hasExiting && !_animController.isAnimating) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _tutorialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = 20.0;
        final maxW = constraints.maxWidth - padding * 2;
        final maxH = constraints.maxHeight - padding * 2;

        final cellSize = math.min(maxW / widget.cols, maxH / widget.rows);
        final boardW = cellSize * widget.cols;
        final boardH = cellSize * widget.rows;

        // Find tutorial target arrow if tutorial is active
        Arrow? tutorialArrow;
        if (widget.isTutorial && widget.arrows.isNotEmpty) {
          tutorialArrow = widget.arrows.firstWhere(
            (a) => !a.isExiting,
            orElse: () => widget.arrows.first,
          );
        }

        return Center(
          child: SizedBox(
            width: boardW,
            height: boardH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Interactive canvas
                GestureDetector(
                  onTapDown: (details) => _handleTap(details.localPosition, cellSize, boardW, boardH),
                  child: Container(
                    width: boardW,
                    height: boardH,
                    decoration: BoxDecoration(
                      color: widget.theme.boardColor,
                      borderRadius: BorderRadius.circular(20),
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

                // Tutorial Hand + "Tap to remove" Tooltip (matching reference video 00:14)
                if (widget.isTutorial && tutorialArrow != null && !tutorialArrow.isExiting)
                  Positioned(
                    left: (tutorialArrow.path.first.col + 0.5) * cellSize - 40,
                    top: (tutorialArrow.path.first.row + 0.5) * cellSize,
                    child: AnimatedBuilder(
                      animation: _tutorialController,
                      builder: (context, child) {
                        final bounce = math.sin(_tutorialController.value * math.pi) * 6;
                        return Transform.translate(
                          offset: Offset(0, bounce),
                          child: child,
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Pointing finger icon
                          const Icon(
                            Icons.touch_app_rounded,
                            size: 42,
                            color: Color(0xFF1E293B),
                          ),
                          const SizedBox(height: 4),
                          // Blue tooltip pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Tap to remove',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleTap(Offset localPos, double cellSize, double boardW, double boardH) {
    Arrow? bestArrow;
    double minDistance = 32.0; // Comfort 32dp tap radius

    for (final arrow in widget.arrows) {
      if (arrow.isExiting) continue;

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

    // Draw normal arrows first, then exiting arrows on top
    for (final arrow in arrows.where((a) => !a.isExiting)) {
      _drawArrow(canvas, arrow, size);
    }
    for (final arrow in arrows.where((a) => a.isExiting)) {
      _drawArrow(canvas, arrow, size);
    }
  }

  void _drawGridBackground(Canvas canvas, Size size) {
    // Subtle architectural dot grid (as seen in video 00:18, 00:24, 01:14)
    final dotPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset((c + 0.5) * cellSize, (r + 0.5) * cellSize),
          2.0,
          dotPaint,
        );
      }
    }
  }

  void _drawArrow(Canvas canvas, Arrow arrow, Size size) {
    canvas.save();

    Color renderColor = theme.arrowColors.first;

    // 1. Tapped and FREE: Arrow turns bright electric blue as it exits! (00:17 & 00:26 in video)
    if (arrow.isExiting) {
      renderColor = const Color(0xFF2563EB); // Royal Blue

      final t = Curves.easeInQuad.transform(animValue);
      final exitDist = cellSize * (math.max(rows, cols) + 4) * t;
      final dir = arrow.direction;
      canvas.translate(dir.dx * exitDist, dir.dy * exitDist);

      final alpha = (1.0 - t).clamp(0.0, 1.0);
      renderColor = renderColor.withOpacity(alpha);
    }

    // 2. Tapped and BLOCKED: Arrow turns RED, shakes, and projects guide ray (01:15 & 01:18 in video)
    if (arrow.isBlocked) {
      final shakeOffset = math.sin(animValue * math.pi * 8) * 5.0;
      canvas.translate(shakeOffset, 0);
      renderColor = const Color(0xFFEF4444); // Bright Red

      // Draw subtle ray projection along blocked exit path
      _drawExitGuideRay(canvas, arrow);
    }

    // 3. Hint Pulsing Glow (Lightbulb powerup)
    if (arrow.isHinted) {
      final glowPaint = Paint()
        ..color = const Color(0xFF00F0FF).withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      _drawArrowPath(canvas, arrow, glowPaint);
    }

    final strokeWidth = cellSize * 0.18;

    // Arrow Body
    final bodyPaint = Paint()
      ..color = renderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _drawArrowPath(canvas, arrow, bodyPaint);

    // Arrow Head
    _drawArrowHead(canvas, arrow, renderColor, strokeWidth);

    canvas.restore();
  }

  void _drawExitGuideRay(Canvas canvas, Arrow arrow) {
    final head = _cellCenter(arrow.head);
    final dir = arrow.direction;

    final rayPaint = Paint()
      ..color = const Color(0xFF93C5FD).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final end = Offset(
      head.dx + dir.dx * cellSize * (math.max(rows, cols)),
      head.dy + dir.dy * cellSize * (math.max(rows, cols)),
    );

    canvas.drawLine(head, end, rayPaint);
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

    final headSize = cellSize * 0.36;

    canvas.save();
    canvas.translate(headPos.dx, headPos.dy);
    canvas.rotate(dir.angleRadians);

    final headPath = Path();
    final tipX = headSize * 0.55;
    final backX = -headSize * 0.45;
    final wingY = headSize * 0.48;

    headPath.moveTo(tipX, 0);
    headPath.lineTo(backX, -wingY);
    headPath.lineTo(backX * 0.4, 0);
    headPath.lineTo(backX, wingY);
    headPath.close();

    final headPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(headPath, headPaint);

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
