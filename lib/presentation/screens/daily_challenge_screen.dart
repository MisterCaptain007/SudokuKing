import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/game_stats.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/stats_controller.dart';
import '../widgets/common/trophy_widget.dart';

/// Daily challenge screen with interactive monthly calendar and streak tracker.
class DailyChallengeScreen extends StatefulWidget {
  final GameController gameController;
  final SettingsController settingsController;
  final StatsController statsController;

  const DailyChallengeScreen({
    super.key,
    required this.gameController,
    required this.settingsController,
    required this.statsController,
  });

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  int _monthOffset = 0; // 0 = current month, -1 = last month, etc.
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = GameStats.currentCalendarDay();
  }

  DateTime _monthCalendar() {
    final now = DateTime.now();
    var y = now.year;
    var m = now.month + _monthOffset;
    while (m < 1) {
      m += 12;
      y--;
    }
    return DateTime.utc(y, m, 1);
  }

  String _formatMonthYear(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  String _formatDateShort(int day) {
    final dt = GameStats.calendarForDay(day);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.settingsController.darkTheme;
    final stats = widget.statsController.stats;
    final today = GameStats.currentCalendarDay();
    final month = _monthCalendar();

    final daysInMonth = DateTime.utc(month.year, month.month + 1, 0).day;
    final firstWeekday = month.weekday % 7; // Sunday = 0, Monday = 1, etc.

    const diffNames = ['Easy', 'Medium', 'Hard', 'Expert'];
    final dailyDifficulty = (_selectedDay % 4).abs();

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Daily Challenge',
                    style: TextStyle(
                      color: AppColors.primaryText(isDark),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Blue Header Panel with month navigation and streaks
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2F5B) : AppColors.deepBlue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Month Navigator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
                          onPressed: _monthOffset > -24
                              ? () {
                                  setState(() {
                                    _monthOffset--;
                                  });
                                }
                              : null,
                        ),
                        Text(
                          _formatMonthYear(month),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.chevron_right_rounded,
                            color: _monthOffset < 0 ? Colors.white : Colors.transparent,
                            size: 28,
                          ),
                          onPressed: _monthOffset < 0
                              ? () {
                                  setState(() {
                                    _monthOffset++;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),
                    TrophyWidget(size: 60, isDark: true),
                    const SizedBox(height: 14),

                    // Streaks
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Streak',
                                  style: TextStyle(color: Colors.white70, fontSize: 10),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${stats.currentDailyStreak} Days',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Best Streak',
                                  style: TextStyle(color: Colors.white70, fontSize: 10),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${stats.bestDailyStreak} Days',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Weekdays Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _WeekdayLabel('Sun'),
                  _WeekdayLabel('Mon'),
                  _WeekdayLabel('Tue'),
                  _WeekdayLabel('Wed'),
                  _WeekdayLabel('Thu'),
                  _WeekdayLabel('Fri'),
                  _WeekdayLabel('Sat'),
                ],
              ),
              const SizedBox(height: 8),

              // Calendar Grid Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface(isDark),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? const Color(0x351D2538) : const Color(0x101D2538),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: 42,
                  itemBuilder: (context, index) {
                    final dayOfMonth = index - firstWeekday + 1;
                    if (dayOfMonth < 1 || dayOfMonth > daysInMonth) {
                      return const SizedBox.shrink();
                    }

                    final dayNumber = GameStats.dayNumber(
                      DateTime.utc(month.year, month.month, dayOfMonth),
                    );

                    final isCompleted = stats.completedDailyDays.contains(dayNumber);
                    final isToday = dayNumber == today;
                    final isSelected = dayNumber == _selectedDay;
                    final isFuture = dayNumber > today;

                    return GestureDetector(
                      onTap: isFuture
                          ? null
                          : () {
                              setState(() {
                                _selectedDay = dayNumber;
                              });
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? (isDark ? const Color(0xFF396F5B) : const Color(0xFFF7DA70))
                              : (isToday ? (isDark ? AppColors.blue : const Color(0xFF416FE2)) : Colors.transparent),
                          shape: BoxShape.circle,
                          border: isSelected && !isCompleted && !isToday
                              ? Border.all(
                                  color: isDark ? const Color(0xFF4B546C) : AppColors.gold,
                                  width: 2.0,
                                )
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: isDark ? Colors.white : AppColors.deepBlue,
                                )
                              : Text(
                                  '$dayOfMonth',
                                  style: TextStyle(
                                    color: isFuture
                                        ? AppColors.mutedText(isDark).withValues(alpha: 0.4)
                                        : (isToday ? Colors.white : AppColors.primaryText(isDark)),
                                    fontSize: 12,
                                    fontWeight: (isToday || isSelected) ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // Action Play Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.deepBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _selectedDay <= today
                      ? () {
                          widget.gameController.startNewGame(
                            dailyDifficulty,
                            isDaily: true,
                            dailyDay: _selectedDay,
                          );
                        }
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, color: AppColors.deepBlue),
                      const SizedBox(width: 6),
                      Text(
                        _selectedDay == today
                            ? "Play Today's Puzzle"
                            : 'Play ${_formatDateShort(_selectedDay)} Puzzle',
                        style: const TextStyle(
                          color: AppColors.deepBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Text(
                'A new ${diffNames[dailyDifficulty]} puzzle every day. Keep your streak alive!',
                style: TextStyle(
                  color: AppColors.mutedText(isDark),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;

  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
