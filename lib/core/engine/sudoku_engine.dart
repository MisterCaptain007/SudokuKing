import 'dart:math';

/// Pure Dart Sudoku generator and solver.
/// All generated puzzles are guaranteed to have exactly one unique solution.
class SudokuEngine {
  static final Random _random = Random();

  SudokuEngine._();

  static Puzzle generate(int difficulty, [int? seed]) {
    final rand = seed != null ? Random(seed) : _random;
    var normalizedDifficulty = difficulty;
    if (normalizedDifficulty < 0) normalizedDifficulty = 0;
    if (normalizedDifficulty > 3) normalizedDifficulty = 3;

    final solution = List.generate(9, (_) => List.filled(9, 0));
    _fill(solution, rand);
    final puzzle = copy(solution);

    final cells = List<int>.generate(81, (i) => i)..shuffle(rand);
    int target;
    switch (normalizedDifficulty) {
      case 0:
        target = 32;
        break;
      case 1:
        target = 42;
        break;
      case 2:
        target = 50;
        break;
      default:
        target = 56;
        break;
    }

    var removed = 0;
    for (final cell in cells) {
      if (removed >= target) break;
      final r = cell ~/ 9;
      final c = cell % 9;
      final old = puzzle[r][c];
      puzzle[r][c] = 0;
      if (countSolutions(puzzle, 2) == 1) {
        removed++;
      } else {
        puzzle[r][c] = old;
      }
    }

    // Continue safely until enough blanks are removed if constrained in first pass
    if (removed < target) {
      for (final cell in cells) {
        final r = cell ~/ 9;
        final c = cell % 9;
        if (puzzle[r][c] == 0) continue;
        final old = puzzle[r][c];
        puzzle[r][c] = 0;
        if (countSolutions(puzzle, 2) == 1) {
          removed++;
        } else {
          puzzle[r][c] = old;
        }
        if (removed >= target) break;
      }
    }

    return Puzzle(puzzle: puzzle, solution: solution);
  }

  static bool _fill(List<List<int>> grid, Random random) {
    final cell = _findEmpty(grid);
    if (cell == null) return true;
    final r = cell[0];
    final c = cell[1];

    final nums = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    for (var i = nums.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final t = nums[i];
      nums[i] = nums[j];
      nums[j] = t;
    }

    for (final n in nums) {
      if (_valid(grid, r, c, n)) {
        grid[r][c] = n;
        if (_fill(grid, random)) return true;
        grid[r][c] = 0;
      }
    }
    return false;
  }

  static int countSolutions(List<List<int>> grid, int limit) {
    if (grid.length != 9 || limit <= 0) return 0;
    for (var r = 0; r < 9; r++) {
      if (grid[r].length != 9) return 0;
    }
    final cell = _findBestEmpty(grid);
    if (cell == null) return 1;
    final r = cell[0];
    final c = cell[1];
    var count = 0;

    for (var n = 1; n <= 9; n++) {
      if (_valid(grid, r, c, n)) {
        grid[r][c] = n;
        count += countSolutions(grid, limit - count);
        grid[r][c] = 0;
        if (count >= limit) return count;
      }
    }
    return count;
  }

  static List<int>? _findEmpty(List<List<int>> g) {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (g[r][c] == 0) return [r, c];
      }
    }
    return null;
  }

  static List<int>? _findBestEmpty(List<List<int>> g) {
    var bestR = -1;
    var bestC = -1;
    var bestCount = 10;
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (g[r][c] == 0) {
          var n = 0;
          for (var v = 1; v <= 9; v++) {
            if (_valid(g, r, c, v)) n++;
          }
          if (n < bestCount) {
            bestCount = n;
            bestR = r;
            bestC = c;
            if (n <= 1) return [r, c];
          }
        }
      }
    }
    return bestR < 0 ? null : [bestR, bestC];
  }

  static bool _valid(List<List<int>> g, int r, int c, int n) {
    for (var i = 0; i < 9; i++) {
      if (g[r][i] == n || g[i][c] == n) return false;
    }
    final br = (r ~/ 3) * 3;
    final bc = (c ~/ 3) * 3;
    for (var y = br; y < br + 3; y++) {
      for (var x = bc; x < bc + 3; x++) {
        if (g[y][x] == n) return false;
      }
    }
    return true;
  }

  static List<List<int>> copy(List<List<int>> source) {
    return List.generate(source.length, (r) => List<int>.from(source[r]));
  }
}

class Puzzle {
  final List<List<int>> puzzle;
  final List<List<int>> solution;

  Puzzle({required List<List<int>> puzzle, required List<List<int>> solution})
      : puzzle = SudokuEngine.copy(puzzle),
        solution = SudokuEngine.copy(solution);
}
