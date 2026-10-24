import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/settings_controller.dart';

/// Pixel-perfect 9x9 Sudoku Board rendered via CustomPainter.
/// Draws continuous, razor-sharp grid lines and handles touch detection accurately.
class SudokuBoard extends StatelessWidget {
  final GameController gameController;
  final SettingsController settingsController;
  final double size;

  const SudokuBoard({
    super.key,
    required this.gameController,
    required this.settingsController,
    this.size = 340,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = settingsController.darkTheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x551D2538) : const Color(0x181D2538),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTapUp: (details) {
          final cellSize = size / 9.0;
          final col = (details.localPosition.dx / cellSize).floor().clamp(0, 8);
          final row = (details.localPosition.dy / cellSize).floor().clamp(0, 8);
          gameController.selectCell(row, col);
        },
        child: CustomPaint(
          size: Size(size, size),
          painter: _SudokuBoardPainter(
            board: gameController.board,
            original: gameController.original,
            notes: gameController.notes,
            selectedR: gameController.selectedR,
            selectedC: gameController.selectedC,
            highlightMatches: settingsController.highlightMatches,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

class _SudokuBoardPainter extends CustomPainter {
  final List<List<int>> board;
  final List<List<int>> original;
  final List<List<int>> notes;
  final int selectedR;
  final int selectedC;
  final bool highlightMatches;
  final bool isDark;

  _SudokuBoardPainter({
    required this.board,
    required this.original,
    required this.notes,
    required this.selectedR,
    required this.selectedC,
    required this.highlightMatches,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 9.0;
    final selectedVal = (selectedR >= 0 && selectedC >= 0) ? board[selectedR][selectedC] : 0;

    final bgPaint = Paint()..style = PaintingStyle.fill;

    // 1. Draw cell highlight backgrounds
    if (selectedR >= 0 && selectedC >= 0) {
      if (highlightMatches) {
        // Row & Column highlights
        bgPaint.color = AppColors.cellHighlighted(isDark);
        canvas.drawRect(
          Rect.fromLTWH(0, selectedR * cellSize, size.width, cellSize),
          bgPaint,
        );
        canvas.drawRect(
          Rect.fromLTWH(selectedC * cellSize, 0, cellSize, size.height),
          bgPaint,
        );

        // Matching number highlights
        if (selectedVal != 0) {
          bgPaint.color = AppColors.cellMatchValue(isDark);
          for (var r = 0; r < 9; r++) {
            for (var c = 0; c < 9; c++) {
              if (board[r][c] == selectedVal && (r != selectedR || c != selectedC)) {
                canvas.drawRect(
                  Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize),
                  bgPaint,
                );
              }
            }
          }
        }
      }

      // Selected cell highlight
      bgPaint.color = AppColors.cellSelected(isDark);
      canvas.drawRect(
        Rect.fromLTWH(selectedC * cellSize, selectedR * cellSize, cellSize, cellSize),
        bgPaint,
      );
    }

    // 2. Draw cell numbers and notes
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        final val = board[r][c];
        final x = c * cellSize;
        final y = r * cellSize;

        if (val != 0) {
          final isOriginal = original[r][c] != 0;
          final textColor = isDark
              ? AppColors.primaryText(isDark)
              : (isOriginal ? AppColors.deepBlue : AppColors.blue);

          final textPainter = TextPainter(
            text: TextSpan(
              text: '$val',
              style: TextStyle(
                color: textColor,
                fontSize: cellSize * 0.58,
                fontWeight: isOriginal ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();

          textPainter.paint(
            canvas,
            Offset(
              x + (cellSize - textPainter.width) / 2,
              y + (cellSize - textPainter.height) / 2,
            ),
          );
        } else if (notes[r][c] != 0) {
          final noteMask = notes[r][c];
          final subCell = cellSize / 3.0;
          final noteFontSize = (subCell * 0.72).clamp(7.0, 10.0);

          for (var n = 1; n <= 9; n++) {
            if ((noteMask & (1 << n)) != 0) {
              final subRow = (n - 1) ~/ 3;
              final subCol = (n - 1) % 3;
              final nx = x + subCol * subCell;
              final ny = y + subRow * subCell;

              final notePainter = TextPainter(
                text: TextSpan(
                  text: '$n',
                  style: TextStyle(
                    color: AppColors.mutedText(isDark),
                    fontSize: noteFontSize,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                textDirection: TextDirection.ltr,
              )..layout();

              notePainter.paint(
                canvas,
                Offset(
                  nx + (subCell - notePainter.width) / 2,
                  ny + (subCell - notePainter.height) / 2,
                ),
              );
            }
          }
        }
      }
    }

    // 3. Draw continuous thin cell grid lines
    final linePaint = Paint()
      ..color = AppColors.gridLine(isDark)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (var i = 1; i < 9; i++) {
      if (i % 3 == 0) continue; // thick lines drawn next
      final pos = i * cellSize;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), linePaint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), linePaint);
    }

    // 4. Draw continuous heavy 3x3 block lines
    final blockPaint = Paint()
      ..color = AppColors.gridBlockLine(isDark)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i <= 9; i += 3) {
      final pos = (i == 9) ? size.width : (i * cellSize);
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), blockPaint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), blockPaint);
    }

    // 5. Gold selection border around active cell
    if (selectedR >= 0 && selectedC >= 0) {
      final selBorderPaint = Paint()
        ..color = AppColors.goldDark
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke;

      canvas.drawRect(
        Rect.fromLTWH(
          selectedC * cellSize + 1.2,
          selectedR * cellSize + 1.2,
          cellSize - 2.4,
          cellSize - 2.4,
        ),
        selBorderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SudokuBoardPainter oldDelegate) {
    return oldDelegate.selectedR != selectedR ||
        oldDelegate.selectedC != selectedC ||
        oldDelegate.isDark != isDark ||
        oldDelegate.highlightMatches != highlightMatches ||
        oldDelegate.board != board ||
        oldDelegate.notes != notes;
  }
}
