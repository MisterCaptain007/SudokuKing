import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_king/core/engine/sudoku_engine.dart';

void main() {
  test('zero and negative limits return 0', () {
    final emptyGrid = List.generate(9, (_) => List.filled(9, 0));
    expect(SudokuEngine.countSolutions(emptyGrid, 0), equals(0));
    expect(SudokuEngine.countSolutions(emptyGrid, -1), equals(0));
  });

  test('generate puzzles for all difficulties have unique solutions', () {
    const diffNames = ['Easy', 'Medium', 'Hard', 'Expert'];
    for (var d = 0; d < 4; d++) {
      final p = SudokuEngine.generate(d);
      var clues = 0;
      for (var r = 0; r < 9; r++) {
        for (var c = 0; c < 9; c++) {
          if (p.puzzle[r][c] != 0) clues++;
          expect(p.solution[r][c] >= 1 && p.solution[r][c] <= 9, isTrue);
          if (p.puzzle[r][c] != 0) {
            expect(p.puzzle[r][c], equals(p.solution[r][c]));
          }
        }
      }
      expect(SudokuEngine.countSolutions(SudokuEngine.copy(p.puzzle), 2), equals(1));
      // ignore: avoid_print
      print('${diffNames[d]} puzzle valid; clues=$clues, unique solution');
    }
  });

  test('invalid difficulty defaults safely', () {
    final p = SudokuEngine.generate(99);
    expect(SudokuEngine.countSolutions(SudokuEngine.copy(p.puzzle), 2), equals(1));
  });

  test('daily puzzle is stable for identical seed and differs for different seeds', () {
    final first = SudokuEngine.generate(2, 20261020);
    final repeated = SudokuEngine.generate(2, 20261020);
    expect(first.puzzle, equals(repeated.puzzle));
    expect(first.solution, equals(repeated.solution));
    expect(SudokuEngine.countSolutions(SudokuEngine.copy(first.puzzle), 2), equals(1));

    final nextDay = SudokuEngine.generate(2, 20261021);
    expect(first.puzzle, isNot(equals(nextDay.puzzle)));
  });
}
