import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/game_stats.dart';
import '../data/models/saved_game.dart';
import '../data/models/settings_data.dart';

/// Local storage service replicating Android SharedPreferences.
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Settings ---
  SettingsData loadSettings() {
    return SettingsData(
      highlightMatches: _prefs.getBool('highlight_matches') ?? true,
      highlightIncorrect: _prefs.getBool('highlight_incorrect') ?? true,
      showRemainingNumbers: _prefs.getBool('show_remaining_numbers') ?? false,
      confirmRestart: _prefs.getBool('confirm_restart') ?? true,
      soundEnabled: _prefs.getBool('sound_enabled') ?? true,
      vibrationEnabled: _prefs.getBool('vibration_enabled') ?? true,
      musicEnabled: _prefs.getBool('music_enabled') ?? true,
      darkTheme: _prefs.getBool('dark_theme') ?? false,
      numberStyle: _prefs.getString('number_style') ?? 'Modern',
    );
  }

  Future<void> saveSettings(SettingsData settings) async {
    await _prefs.setBool('highlight_matches', settings.highlightMatches);
    await _prefs.setBool('highlight_incorrect', settings.highlightIncorrect);
    await _prefs.setBool('show_remaining_numbers', settings.showRemainingNumbers);
    await _prefs.setBool('confirm_restart', settings.confirmRestart);
    await _prefs.setBool('sound_enabled', settings.soundEnabled);
    await _prefs.setBool('vibration_enabled', settings.vibrationEnabled);
    await _prefs.setBool('music_enabled', settings.musicEnabled);
    await _prefs.setBool('dark_theme', settings.darkTheme);
    await _prefs.setString('number_style', settings.numberStyle);
  }

  // --- Statistics ---
  GameStats loadStatistics() {
    final played = List<int>.generate(4, (i) => _prefs.getInt('played_$i') ?? 0);
    final completed = List<int>.generate(4, (i) => _prefs.getInt('completed_$i') ?? 0);
    final totalSeconds = List<int>.generate(4, (i) => _prefs.getInt('total_seconds_$i') ?? 0);
    final bestSeconds = List<int>.generate(4, (i) => _prefs.getInt('best_seconds_$i') ?? 0);
    final streak = _prefs.getInt('current_streak') ?? 0;
    final lastDay = _prefs.getInt('last_completion_day') ?? -1;

    final completedList = _prefs.getStringList('completed_daily_days') ?? [];
    final completedSet = <int>{};
    for (final s in completedList) {
      final parsed = int.tryParse(s);
      if (parsed != null) completedSet.add(parsed);
    }

    return GameStats(
      gamesPlayed: played,
      gamesCompleted: completed,
      totalCompletionSeconds: totalSeconds,
      bestCompletionSeconds: bestSeconds,
      currentStreak: streak,
      lastCompletionDay: lastDay,
      completedDailyDays: completedSet,
    );
  }

  Future<void> saveStatistics(GameStats stats) async {
    for (var i = 0; i < 4; i++) {
      await _prefs.setInt('played_$i', stats.gamesPlayed[i]);
      await _prefs.setInt('completed_$i', stats.gamesCompleted[i]);
      await _prefs.setInt('total_seconds_$i', stats.totalCompletionSeconds[i]);
      await _prefs.setInt('best_seconds_$i', stats.bestCompletionSeconds[i]);
    }
    await _prefs.setInt('current_streak', stats.currentStreak);
    await _prefs.setInt('last_completion_day', stats.lastCompletionDay);
    await _prefs.setStringList(
      'completed_daily_days',
      stats.completedDailyDays.map((d) => d.toString()).toList(),
    );
  }

  // --- Game Progress ---
  SavedGame? loadProgress() {
    if (!(_prefs.getBool('progress_active') ?? false)) return null;

    final difficulty = _prefs.getInt('progress_difficulty') ?? -1;
    final board = _decodeGrid(_prefs.getString('progress_board'), 9);
    final solution = _decodeGrid(_prefs.getString('progress_solution'), 9);
    final original = _decodeGrid(_prefs.getString('progress_original'), 9);
    final notes = _decodeGrid(_prefs.getString('progress_notes'), 1022);

    if (difficulty < 0 ||
        difficulty > 3 ||
        board == null ||
        solution == null ||
        original == null ||
        notes == null) {
      clearProgress();
      return null;
    }

    // Verify grid sanity
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (solution[r][c] < 1 ||
            (original[r][c] != 0 && original[r][c] != solution[r][c]) ||
            (board[r][c] != 0 && board[r][c] != solution[r][c])) {
          clearProgress();
          return null;
        }
      }
    }

    var selR = _prefs.getInt('progress_selectedR') ?? -1;
    var selC = _prefs.getInt('progress_selectedC') ?? -1;
    if (selR < 0 || selR > 8 || selC < 0 || selC > 8) {
      selR = -1;
      selC = -1;
    }

    var dailyGame = _prefs.getBool('progress_daily_game') ?? false;
    var dailyGameDay = _prefs.getInt('progress_daily_game_day') ?? -1;
    if (dailyGame && (dailyGameDay < 0 || difficulty != (dailyGameDay % 4))) {
      dailyGame = false;
      dailyGameDay = -1;
    }

    return SavedGame(
      difficulty: difficulty,
      board: board,
      solution: solution,
      original: original,
      notes: notes,
      selectedR: selR,
      selectedC: selC,
      mistakes: (_prefs.getInt('progress_mistakes') ?? 0).clamp(0, 3),
      score: (_prefs.getInt('progress_score') ?? 0).clamp(0, 999999),
      elapsedSeconds: (_prefs.getInt('progress_elapsedSeconds') ?? 0).clamp(0, 999999),
      hints: (_prefs.getInt('progress_hints') ?? 3).clamp(0, 3),
      notesMode: _prefs.getBool('progress_notesMode') ?? false,
      dailyGame: dailyGame,
      dailyGameDay: dailyGameDay,
    );
  }

  Future<void> saveProgress(SavedGame progress) async {
    await _prefs.setBool('progress_active', true);
    await _prefs.setInt('progress_difficulty', progress.difficulty);
    await _prefs.setString('progress_board', _encodeGrid(progress.board));
    await _prefs.setString('progress_solution', _encodeGrid(progress.solution));
    await _prefs.setString('progress_original', _encodeGrid(progress.original));
    await _prefs.setString('progress_notes', _encodeGrid(progress.notes));
    await _prefs.setInt('progress_selectedR', progress.selectedR);
    await _prefs.setInt('progress_selectedC', progress.selectedC);
    await _prefs.setInt('progress_mistakes', progress.mistakes);
    await _prefs.setInt('progress_score', progress.score);
    await _prefs.setInt('progress_elapsedSeconds', progress.elapsedSeconds);
    await _prefs.setInt('progress_hints', progress.hints);
    await _prefs.setBool('progress_notesMode', progress.notesMode);
    await _prefs.setBool('progress_daily_game', progress.dailyGame);
    await _prefs.setInt('progress_daily_game_day', progress.dailyGameDay);
  }

  Future<void> clearProgress() async {
    await _prefs.remove('progress_active');
    await _prefs.remove('progress_difficulty');
    await _prefs.remove('progress_board');
    await _prefs.remove('progress_solution');
    await _prefs.remove('progress_original');
    await _prefs.remove('progress_notes');
    await _prefs.remove('progress_selectedR');
    await _prefs.remove('progress_selectedC');
    await _prefs.remove('progress_mistakes');
    await _prefs.remove('progress_score');
    await _prefs.remove('progress_elapsedSeconds');
    await _prefs.remove('progress_hints');
    await _prefs.remove('progress_notesMode');
    await _prefs.remove('progress_daily_game');
    await _prefs.remove('progress_daily_game_day');
  }

  static String _encodeGrid(List<List<int>> grid) {
    final buffer = StringBuffer();
    for (final row in grid) {
      for (final value in row) {
        buffer.write('$value,');
      }
    }
    return buffer.toString();
  }

  static List<List<int>>? _decodeGrid(String? encoded, int maxValue) {
    if (encoded == null) return null;
    final parts = encoded.split(',');
    if (parts.length < 81) return null;

    final grid = List.generate(9, (_) => List.filled(9, 0));
    try {
      for (var i = 0; i < 81; i++) {
        final val = int.parse(parts[i]);
        if (val < 0 || val > maxValue) return null;
        grid[i ~/ 9][i % 9] = val;
      }
    } catch (_) {
      return null;
    }
    return grid;
  }
}
