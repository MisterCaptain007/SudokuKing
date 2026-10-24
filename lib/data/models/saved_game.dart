import '../../core/engine/sudoku_engine.dart';

/// Represents a serialized active Sudoku game session.
class SavedGame {
  final int difficulty;
  final List<List<int>> board;
  final List<List<int>> solution;
  final List<List<int>> original;
  final List<List<int>> notes;
  final int selectedR;
  final int selectedC;
  final int mistakes;
  final int score;
  final int elapsedSeconds;
  final int hints;
  final bool notesMode;
  final bool dailyGame;
  final int dailyGameDay;

  SavedGame({
    required this.difficulty,
    required List<List<int>> board,
    required List<List<int>> solution,
    required List<List<int>> original,
    required List<List<int>> notes,
    required this.selectedR,
    required this.selectedC,
    required this.mistakes,
    required this.score,
    required this.elapsedSeconds,
    required this.hints,
    required this.notesMode,
    required this.dailyGame,
    required this.dailyGameDay,
  })  : board = SudokuEngine.copy(board),
        solution = SudokuEngine.copy(solution),
        original = SudokuEngine.copy(original),
        notes = SudokuEngine.copy(notes);
}
