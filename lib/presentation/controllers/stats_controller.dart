import 'package:flutter/material.dart';
import '../../data/models/game_stats.dart';
import '../../services/storage_service.dart';

/// Controller for tracking lifetime game completions, streaks, and difficulty breakdowns.
class StatsController extends ChangeNotifier {
  final StorageService _storageService;
  late GameStats _stats;
  int selectedTab = 0; // 0 = Overall, 1 = Easy, 2 = Medium, 3 = Hard, 4 = Expert

  StatsController(this._storageService) {
    _stats = _storageService.loadStatistics();
  }

  GameStats get stats => _stats;

  void setTab(int index) {
    if (selectedTab == index) return;
    selectedTab = index;
    notifyListeners();
  }

  void recordGameStarted(int difficulty) {
    if (difficulty >= 0 && difficulty < 4) {
      _stats.gamesPlayed[difficulty]++;
      _persist();
    }
  }

  void recordGameCompleted({
    required int difficulty,
    required int elapsedSeconds,
    required bool isDaily,
    required int dailyGameDay,
  }) {
    if (difficulty >= 0 && difficulty < 4) {
      _stats.gamesCompleted[difficulty]++;
      _stats.totalCompletionSeconds[difficulty] += elapsedSeconds;
      if (_stats.bestCompletionSeconds[difficulty] == 0 ||
          elapsedSeconds < _stats.bestCompletionSeconds[difficulty]) {
        _stats.bestCompletionSeconds[difficulty] = elapsedSeconds;
      }
    }

    final today = GameStats.currentCalendarDay();
    if (today > _stats.lastCompletionDay) {
      _stats.currentStreak = (_stats.lastCompletionDay == today - 1)
          ? _stats.currentStreak + 1
          : 1;
      _stats.lastCompletionDay = today;
    }

    if (isDaily && dailyGameDay >= 0) {
      _stats.completedDailyDays.add(dailyGameDay);
    }

    _persist();
  }

  void _persist() {
    _storageService.saveStatistics(_stats);
    notifyListeners();
  }
}
