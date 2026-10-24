/// Represents user statistics across overall and per-difficulty levels.
class GameStats {
  static const List<String> difficultyNames = ['Easy', 'Medium', 'Hard', 'Expert'];

  final List<int> gamesPlayed;
  final List<int> gamesCompleted;
  final List<int> totalCompletionSeconds;
  final List<int> bestCompletionSeconds;
  int currentStreak;
  int lastCompletionDay;
  final Set<int> completedDailyDays;

  GameStats({
    List<int>? gamesPlayed,
    List<int>? gamesCompleted,
    List<int>? totalCompletionSeconds,
    List<int>? bestCompletionSeconds,
    this.currentStreak = 0,
    this.lastCompletionDay = -1,
    Set<int>? completedDailyDays,
  })  : gamesPlayed = gamesPlayed ?? List.filled(4, 0),
        gamesCompleted = gamesCompleted ?? List.filled(4, 0),
        totalCompletionSeconds = totalCompletionSeconds ?? List.filled(4, 0),
        bestCompletionSeconds = bestCompletionSeconds ?? List.filled(4, 0),
        completedDailyDays = completedDailyDays ?? <int>{};

  int getPlayed(int tabIndex) {
    if (tabIndex > 0) return gamesPlayed[tabIndex - 1];
    return gamesPlayed.fold(0, (sum, val) => sum + val);
  }

  int getCompleted(int tabIndex) {
    if (tabIndex > 0) return gamesCompleted[tabIndex - 1];
    return gamesCompleted.fold(0, (sum, val) => sum + val);
  }

  int getWinRate(int tabIndex) {
    final played = getPlayed(tabIndex);
    if (played == 0) return 0;
    return ((getCompleted(tabIndex) / played) * 100).round();
  }

  int getAverageTime(int tabIndex) {
    final completed = getCompleted(tabIndex);
    if (completed == 0) return 0;
    final totalSecs = tabIndex > 0
        ? totalCompletionSeconds[tabIndex - 1]
        : totalCompletionSeconds.fold(0, (sum, val) => sum + val);
    return totalSecs ~/ completed;
  }

  int getBestTime(int tabIndex) {
    if (tabIndex > 0) return bestCompletionSeconds[tabIndex - 1];
    var best = 0;
    for (final val in bestCompletionSeconds) {
      if (val > 0 && (best == 0 || val < best)) {
        best = val;
      }
    }
    return best;
  }

  int get displayedCurrentStreak {
    final today = currentCalendarDay();
    return (lastCompletionDay >= 0 && today - lastCompletionDay <= 1)
        ? currentStreak
        : 0;
  }

  int get currentDailyStreak {
    var day = currentCalendarDay();
    if (!completedDailyDays.contains(day)) day--;
    var streak = 0;
    while (completedDailyDays.contains(day - streak)) {
      streak++;
    }
    return streak;
  }

  int get bestDailyStreak {
    final sorted = completedDailyDays.toList()..sort();
    var best = 0;
    var current = 0;
    var previous = -999999999;
    for (final day in sorted) {
      current = (previous != -999999999 && day == previous + 1) ? current + 1 : 1;
      if (current > best) best = current;
      previous = day;
    }
    return best;
  }

  static int currentCalendarDay() {
    final now = DateTime.now().toUtc();
    final todayUtc = DateTime.utc(now.year, now.month, now.day);
    return todayUtc.millisecondsSinceEpoch ~/ 86400000;
  }

  static DateTime calendarForDay(int day) {
    return DateTime.fromMillisecondsSinceEpoch(day * 86400000, isUtc: true);
  }

  static int dayNumber(DateTime date) {
    final utc = DateTime.utc(date.year, date.month, date.day);
    return utc.millisecondsSinceEpoch ~/ 86400000;
  }
}
