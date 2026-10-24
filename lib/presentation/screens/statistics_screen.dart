import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../controllers/settings_controller.dart';
import '../controllers/stats_controller.dart';

/// Statistics screen displaying overall and per-difficulty metrics and win-rate charts.
class StatisticsScreen extends StatelessWidget {
  final StatsController statsController;
  final SettingsController settingsController;

  const StatisticsScreen({
    super.key,
    required this.statsController,
    required this.settingsController,
  });

  String _formatTime(int seconds) {
    if (seconds <= 0) return '--:--';
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = settingsController.darkTheme;
    final stats = statsController.stats;
    final tab = statsController.selectedTab;

    const tabs = ['Overall', 'Easy', 'Medium', 'Hard', 'Expert'];
    final played = stats.getPlayed(tab);
    final completed = stats.getCompleted(tab);
    final winRate = stats.getWinRate(tab);
    final bestTime = stats.getBestTime(tab);
    final avgTime = stats.getAverageTime(tab);
    final streak = stats.displayedCurrentStreak;

    final metrics = [
      {'label': 'Games Played', 'val': '$played', 'icon': Icons.grid_view_rounded, 'color': const Color(0xFF5084EF)},
      {'label': 'Games Completed', 'val': '$completed', 'icon': Icons.check_circle_rounded, 'color': const Color(0xFF43AE84)},
      {'label': 'Win Rate', 'val': '$winRate%', 'icon': Icons.pie_chart_rounded, 'color': const Color(0xFF43AE84)},
      {'label': 'Best Time', 'val': _formatTime(bestTime), 'icon': Icons.emoji_events_rounded, 'color': AppColors.goldDark},
      {'label': 'Average Time', 'val': _formatTime(avgTime), 'icon': Icons.timer_rounded, 'color': AppColors.blue},
      {'label': 'Current Streak', 'val': '$streak Days', 'icon': Icons.local_fire_department_rounded, 'color': AppColors.streakOrange},
    ];

    const diffColors = [
      Color(0xFF4CA981),
      AppColors.gold,
      Color(0xFFDE6058),
      AppColors.blue,
    ];

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Statistics',
                    style: TextStyle(
                      color: AppColors.primaryText(isDark),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Segmented Tab Bar
              Container(
                height: 36,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2B364E) : const Color(0xFFF4EDDD),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    final isSelected = tab == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => statsController.setTab(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.blue : AppColors.deepBlue)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              tabs[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.mutedText(isDark),
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 16),

              // 6 Metric Cards (2 Columns)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: metrics.length,
                itemBuilder: (context, index) {
                  final item = metrics[index];
                  final color = item['color'] as Color;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface(isDark),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? const Color(0x351D2538) : const Color(0x101D2538),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(item['icon'] as IconData, color: color, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item['label'] as String,
                                style: TextStyle(
                                  color: AppColors.mutedText(isDark),
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['val'] as String,
                                style: TextStyle(
                                  color: AppColors.primaryText(isDark),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              // Difficulty Breakdown Card
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Difficulty Breakdown',
                      style: TextStyle(
                        color: AppColors.primaryText(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (var i = 0; i < 4; i++) ...[
                      _buildDifficultyBar(
                        label: tabs[i + 1],
                        count: stats.gamesPlayed[i],
                        wins: stats.gamesCompleted[i],
                        color: diffColors[i],
                        isDark: isDark,
                      ),
                      if (i < 3) const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBar({
    required String label,
    required int count,
    required int wins,
    required Color color,
    required bool isDark,
  }) {
    final percent = count == 0 ? 0 : ((wins / count) * 100).round();

    return Row(
      children: [
        SizedBox(
          width: 54,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.primaryText(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: count == 0 ? 0.0 : (wins / count).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: isDark ? const Color(0xFF37425B) : const Color(0xFFEDECE7),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 42,
          child: Text(
            '$wins/$count',
            style: TextStyle(
              color: AppColors.primaryText(isDark),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '$percent%',
            style: TextStyle(
              color: AppColors.mutedText(isDark),
              fontSize: 11,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
