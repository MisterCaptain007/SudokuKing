import '../../core/engine/sudoku_engine.dart';

/// Represents a state snapshot for undo/redo history (up to 80 snapshots).
class GameSnapshot {
  final List<List<int>> board;
  final List<List<int>> notes;
  final int selectedR;
  final int selectedC;
  final int mistakes;
  final int score;
  final int hints;
  final bool notesMode;

  GameSnapshot({
    required List<List<int>> board,
    required List<List<int>> notes,
    required this.selectedR,
    required this.selectedC,
    required this.mistakes,
    required this.score,
    required this.hints,
    required this.notesMode,
  })  : board = SudokuEngine.copy(board),
        notes = SudokuEngine.copy(notes);
}
