import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/engine/sudoku_engine.dart';
import '../../data/models/game_snapshot.dart';
import '../../data/models/saved_game.dart';
import '../../services/audio_service.dart';
import '../../services/platform_service.dart';
import '../../services/storage_service.dart';
import 'settings_controller.dart';
import 'stats_controller.dart';

/// Central game controller managing puzzle state, timer, player actions, undo stack, and scoring.
class GameController extends ChangeNotifier {
  final StorageService storageService;
  final SettingsController settingsController;
  final StatsController statsController;
  final AudioService audioService;

  Timer? _ticker;

  bool isPlaying = false;
  bool isPaused = false;
  bool isFinished = false;
  bool isOutOfLives = false;
  bool notesMode = false;

  int difficulty = 0;
  int selectedR = -1;
  int selectedC = -1;
  int mistakes = 0;
  int score = 0;
  int elapsedSeconds = 0;
  int hints = 3;

  bool isDailyGame = false;
  int dailyGameDay = -1;

  List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
  List<List<int>> original = List.generate(9, (_) => List.filled(9, 0));
  List<List<int>> solution = List.generate(9, (_) => List.filled(9, 0));
  List<List<int>> notes = List.generate(9, (_) => List.filled(9, 0));

  final List<GameSnapshot> _undoStack = [];

  String message = '';
  bool isErrorMessage = false;
  DateTime? _messageUntil;

  bool hasSavedProgress = false;

  GameController({
    required this.storageService,
    required this.settingsController,
    required this.statsController,
    required this.audioService,
  }) {
    _initSavedGame();
    _startTicker();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isPlaying && !isPaused && !isFinished) {
        elapsedSeconds++;
        if (elapsedSeconds % 10 == 0) {
          saveProgress();
        }
        notifyListeners();
      }
    });
  }

  void _initSavedGame() {
    final saved = storageService.loadProgress();
    if (saved != null) {
      hasSavedProgress = true;
      difficulty = saved.difficulty;
    }
  }

  void startNewGame(int diff, {bool isDaily = false, int dailyDay = -1}) {
    statsController.recordGameStarted(diff);
    difficulty = diff;
    isDailyGame = isDaily;
    dailyGameDay = dailyDay;

    final puzzle = isDaily
        ? SudokuEngine.generate(diff, dailyDay)
        : SudokuEngine.generate(diff);

    board = SudokuEngine.copy(puzzle.puzzle);
    original = SudokuEngine.copy(puzzle.puzzle);
    solution = SudokuEngine.copy(puzzle.solution);
    notes = List.generate(9, (_) => List.filled(9, 0));

    _undoStack.clear();
    selectedR = -1;
    selectedC = -1;
    mistakes = 0;
    score = 0;
    elapsedSeconds = 0;
    hints = 3;

    isPaused = false;
    isFinished = false;
    isOutOfLives = false;
    notesMode = false;
    isPlaying = true;
    message = '';
    isErrorMessage = false;

    saveProgress();
    audioService.startMusic();
    notifyListeners();
  }

  bool restoreSavedGame() {
    final saved = storageService.loadProgress();
    if (saved == null) return false;

    difficulty = saved.difficulty;
    board = saved.board;
    solution = saved.solution;
    original = saved.original;
    notes = saved.notes;
    selectedR = saved.selectedR;
    selectedC = saved.selectedC;
    mistakes = saved.mistakes;
    score = saved.score;
    elapsedSeconds = saved.elapsedSeconds;
    hints = saved.hints;
    notesMode = saved.notesMode;
    isDailyGame = saved.dailyGame;
    dailyGameDay = saved.dailyGameDay;

    isOutOfLives = mistakes >= 3;
    isPaused = isOutOfLives;
    isFinished = false;
    isPlaying = true;
    hasSavedProgress = false;

    audioService.startMusic();
    notifyListeners();
    return true;
  }

  void selectCell(int r, int c) {
    if (r < 0 || r > 8 || c < 0 || c > 8) return;
    selectedR = r;
    selectedC = c;
    audioService.playFeedback();
    if (settingsController.vibrationEnabled) {
      PlatformService.triggerHaptic();
    }
    notifyListeners();
  }

  void toggleNotesMode() {
    notesMode = !notesMode;
    showMessage(notesMode ? 'Notes mode on' : 'Notes mode off');
    audioService.playFeedback();
    saveProgress();
    notifyListeners();
  }

  void enterNumber(int n) {
    if (selectedR < 0 || selectedC < 0) {
      showMessage('Choose a cell first');
      return;
    }
    if (original[selectedR][selectedC] != 0) {
      showMessage('That number is fixed');
      return;
    }
    if (board[selectedR][selectedC] != 0 && !notesMode) {
      showMessage('Erase the cell first');
      return;
    }

    audioService.playFeedback();
    if (settingsController.vibrationEnabled) {
      PlatformService.triggerHaptic();
    }

    if (notesMode) {
      _saveUndo();
      notes[selectedR][selectedC] ^= (1 << n);
      saveProgress();
      notifyListeners();
      return;
    }

    if (solution[selectedR][selectedC] != n) {
      mistakes++;
      showMessage('Not quite. Try again!', isError: true);
      if (settingsController.vibrationEnabled) {
        PlatformService.triggerHaptic(heavy: true);
      }
      if (mistakes >= 3) {
        isPaused = true;
        isOutOfLives = true;
        message = 'Three mistakes used';
      }
      saveProgress();
      notifyListeners();
      return;
    }

    // Correct entry
    _saveUndo();
    board[selectedR][selectedC] = n;
    notes[selectedR][selectedC] = 0;
    score += 10;
    _clearNote(n, selectedR, selectedC);

    if (_isSolved()) {
      isFinished = true;
      score += (300 - elapsedSeconds).clamp(0, 300);
      statsController.recordGameCompleted(
        difficulty: difficulty,
        elapsedSeconds: elapsedSeconds,
        isDaily: isDailyGame,
        dailyGameDay: dailyGameDay,
      );
      clearSavedProgress();
      showMessage('Puzzle solved!');
    } else {
      saveProgress();
    }
    notifyListeners();
  }

  void eraseCurrentCell() {
    if (selectedR < 0 || selectedC < 0) {
      showMessage('Select an editable cell');
      return;
    }
    if (original[selectedR][selectedC] != 0) {
      showMessage('That number is fixed');
      return;
    }

    _saveUndo();
    board[selectedR][selectedC] = 0;
    notes[selectedR][selectedC] = 0;
    audioService.playFeedback();
    saveProgress();
    notifyListeners();
  }

  void requestHint() {
    if (selectedR < 0 ||
        selectedC < 0 ||
        original[selectedR][selectedC] != 0 ||
        board[selectedR][selectedC] == solution[selectedR][selectedC]) {
      showMessage('Select an empty cell');
      return;
    }

    if (hints <= 0) {
      showMessage('No hints remaining');
      return;
    }

    _saveUndo();
    board[selectedR][selectedC] = solution[selectedR][selectedC];
    notes[selectedR][selectedC] = 0;
    hints--;
    score = (score - 5).clamp(0, 999999);
    audioService.playFeedback();

    if (_isSolved()) {
      isFinished = true;
      statsController.recordGameCompleted(
        difficulty: difficulty,
        elapsedSeconds: elapsedSeconds,
        isDaily: isDailyGame,
        dailyGameDay: dailyGameDay,
      );
      clearSavedProgress();
      showMessage('Puzzle solved!');
    } else {
      saveProgress();
    }
    notifyListeners();
  }

  void undo() {
    if (_undoStack.isEmpty) {
      showMessage('Nothing to undo');
      return;
    }
    final snap = _undoStack.removeLast();
    board = SudokuEngine.copy(snap.board);
    notes = SudokuEngine.copy(snap.notes);
    selectedR = snap.selectedR;
    selectedC = snap.selectedC;
    mistakes = snap.mistakes;
    score = snap.score;
    hints = snap.hints;
    notesMode = snap.notesMode;
    audioService.playFeedback();
    saveProgress();
    notifyListeners();
  }

  void _saveUndo() {
    _undoStack.add(GameSnapshot(
      board: board,
      notes: notes,
      selectedR: selectedR,
      selectedC: selectedC,
      mistakes: mistakes,
      score: score,
      hints: hints,
      notesMode: notesMode,
    ));
    if (_undoStack.length > 80) {
      _undoStack.removeAt(0);
    }
  }

  void _clearNote(int n, int r, int c) {
    for (var i = 0; i < 9; i++) {
      notes[r][i] &= ~(1 << n);
      notes[i][c] &= ~(1 << n);
    }
    final br = (r ~/ 3) * 3;
    final bc = (c ~/ 3) * 3;
    for (var y = br; y < br + 3; y++) {
      for (var x = bc; x < bc + 3; x++) {
        notes[y][x] &= ~(1 << n);
      }
    }
  }

  bool _isSolved() {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (board[r][c] != solution[r][c]) return false;
      }
    }
    return true;
  }

  bool isNumberComplete(int n) {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (board[r][c] == 0 && solution[r][c] == n) return false;
      }
    }
    return true;
  }

  void showMessage(String msg, {bool isError = false}) {
    message = msg;
    isErrorMessage = isError;
    _messageUntil = DateTime.now().add(const Duration(milliseconds: 1700));
    notifyListeners();
  }

  bool get isMessageVisible {
    return _messageUntil != null && DateTime.now().isBefore(_messageUntil!);
  }

  void pauseGame() {
    isPaused = true;
    saveProgress();
    audioService.pauseMusic();
    notifyListeners();
  }

  void resumeGame() {
    isPaused = false;
    audioService.startMusic();
    notifyListeners();
  }

  void exitToHome() {
    saveProgress();
    isPlaying = false;
    isPaused = false;
    isFinished = false;
    audioService.pauseMusic();
    hasSavedProgress = true;
    notifyListeners();
  }

  void restartCurrentGame() {
    if (isDailyGame) {
      startNewGame(difficulty, isDaily: true, dailyDay: dailyGameDay);
    } else {
      startNewGame(difficulty);
    }
  }

  void saveProgress() {
    if (!isPlaying || isFinished) return;
    storageService.saveProgress(SavedGame(
      difficulty: difficulty,
      board: board,
      solution: solution,
      original: original,
      notes: notes,
      selectedR: selectedR,
      selectedC: selectedC,
      mistakes: mistakes,
      score: score,
      elapsedSeconds: elapsedSeconds,
      hints: hints,
      notesMode: notesMode,
      dailyGame: isDailyGame,
      dailyGameDay: dailyGameDay,
    ));
    hasSavedProgress = true;
  }

  void clearSavedProgress() {
    storageService.clearProgress();
    hasSavedProgress = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
