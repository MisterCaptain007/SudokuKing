import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Single interactive Sudoku grid cell.
class CellWidget extends StatelessWidget {
  final int row;
  final int col;
  final int value;
  final int originalValue;
  final int notesMask;
  final bool isSelected;
  final bool isHighlighted;
  final bool isMatchValue;
  final bool isDark;
  final VoidCallback onTap;

  const CellWidget({
    super.key,
    required this.row,
    required this.col,
    required this.value,
    required this.originalValue,
    required this.notesMask,
    required this.isSelected,
    required this.isHighlighted,
    required this.isMatchValue,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.surface(isDark);
    if (isSelected) {
      bg = AppColors.cellSelected(isDark);
    } else if (isMatchValue) {
      bg = AppColors.cellMatchValue(isDark);
    } else if (isHighlighted) {
      bg = AppColors.cellHighlighted(isDark);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            top: BorderSide(
              color: row % 3 == 0 ? AppColors.gridBlockLine(isDark) : AppColors.gridLine(isDark),
              width: row % 3 == 0 ? 2.0 : 0.6,
            ),
            left: BorderSide(
              color: col % 3 == 0 ? AppColors.gridBlockLine(isDark) : AppColors.gridLine(isDark),
              width: col % 3 == 0 ? 2.0 : 0.6,
            ),
            bottom: BorderSide(
              color: row == 8 ? AppColors.gridBlockLine(isDark) : (row % 3 == 2 ? AppColors.gridBlockLine(isDark) : AppColors.gridLine(isDark)),
              width: (row == 8 || row % 3 == 2) ? 2.0 : 0.6,
            ),
            right: BorderSide(
              color: col == 8 ? AppColors.gridBlockLine(isDark) : (col % 3 == 2 ? AppColors.gridBlockLine(isDark) : AppColors.gridLine(isDark)),
              width: (col == 8 || col % 3 == 2) ? 2.0 : 0.6,
            ),
          ),
        ),
        child: isSelected
            ? Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.goldDark, width: 2.2),
                ),
                child: _buildCellContent(),
              )
            : _buildCellContent(),
      ),
    );
  }

  Widget _buildCellContent() {
    if (value != 0) {
      final isOriginal = originalValue != 0;
      return Center(
        child: Text(
          '$value',
          style: TextStyle(
            color: isDark ? AppColors.primaryText(isDark) : (isOriginal ? AppColors.deepBlue : AppColors.blue),
            fontSize: 22,
            fontWeight: isOriginal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      );
    }

    if (notesMask != 0) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final noteFontSize = (constraints.maxHeight / 3.8).clamp(8.0, 11.0);
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var r = 0; r < 3; r++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var c = 0; c < 3; c++)
                      _buildNoteDigit(r * 3 + c + 1, noteFontSize),
                  ],
                ),
            ],
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildNoteDigit(int digit, double fontSize) {
    final hasNote = (notesMask & (1 << digit)) != 0;
    return SizedBox(
      width: fontSize * 1.2,
      child: Center(
        child: Text(
          hasNote ? '$digit' : '',
          style: TextStyle(
            color: AppColors.mutedText(isDark),
            fontSize: fontSize,
            fontWeight: FontWeight.normal,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
