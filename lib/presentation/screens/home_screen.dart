import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/common/crown_widget.dart';
import '../widgets/common/difficulty_card.dart';
import '../widgets/common/mountains_painter.dart';

/// Home screen with crown logo, difficulty selection, and continue game button.
class HomeScreen extends StatelessWidget {
  final GameController gameController;
  final SettingsController settingsController;

  const HomeScreen({
    super.key,
    required this.gameController,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = settingsController.darkTheme;
    const diffNames = ['Easy', 'Medium', 'Hard', 'Expert'];

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: Stack(
        children: [
          // Mountain silhouette illustration
          Positioned.fill(
            child: CustomPaint(
              painter: MountainsPainter(isDark: isDark),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header with Theme Toggle Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: settingsController.toggleDarkTheme,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface(isDark),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? const Color(0x351D2538) : const Color(0x101D2538),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            color: isDark ? AppColors.gold : AppColors.blue,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        CrownWidget(size: 52, isDark: isDark),
                        const SizedBox(height: 8),
                        Text(
                          'SUDOKU',
                          style: TextStyle(
                            color: isDark ? AppColors.primaryText(isDark) : AppColors.deepBlue,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                        Text(
                          'KING',
                          style: TextStyle(
                            color: isDark ? AppColors.gold : AppColors.goldDark,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Train your brain. Rule the grid.',
                          style: TextStyle(
                            color: AppColors.mutedText(isDark),
                            fontSize: 14,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Continue Saved Game Button (if available)
                        if (gameController.hasSavedProgress) ...[
                          GestureDetector(
                            onTap: () {
                              gameController.restoreSavedGame();
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x28000000),
                                    offset: Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.play_arrow_rounded, color: AppColors.deepBlue, size: 22),
                                      SizedBox(width: 6),
                                      Text(
                                        'Continue Game',
                                        style: TextStyle(
                                          color: AppColors.deepBlue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${diffNames[gameController.difficulty]}  •  ${gameController.elapsedSeconds ~/ 60}:${(gameController.elapsedSeconds % 60).toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      color: AppColors.deepBlue,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        Text(
                          'Choose your challenge',
                          style: TextStyle(
                            color: AppColors.primaryText(isDark),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 2x2 Difficulty Cards
                        Row(
                          children: [
                            Expanded(
                              child: DifficultyCard(
                                title: 'EASY',
                                subtitle: 'A gentle warm-up',
                                accentColor: AppColors.easyAccent,
                                isDark: isDark,
                                onTap: () => gameController.startNewGame(0),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DifficultyCard(
                                title: 'MEDIUM',
                                subtitle: 'Find your rhythm',
                                accentColor: AppColors.mediumAccent,
                                isDark: isDark,
                                onTap: () => gameController.startNewGame(1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DifficultyCard(
                                title: 'HARD',
                                subtitle: 'For Sudoku masters',
                                accentColor: AppColors.hardAccent,
                                isDark: isDark,
                                onTap: () => gameController.startNewGame(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DifficultyCard(
                                title: 'EXPERT',
                                subtitle: 'For Sudoku experts',
                                accentColor: AppColors.expertAccent,
                                isDark: isDark,
                                onTap: () => gameController.startNewGame(3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
