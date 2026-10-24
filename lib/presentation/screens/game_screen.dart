import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/board/action_bar.dart';
import '../widgets/board/keypad.dart';
import '../widgets/board/sudoku_board.dart';
import '../widgets/dialogs/game_overlays.dart';

/// Active gameplay screen with responsive portrait and landscape layouts.
class GameScreen extends StatelessWidget {
  final GameController gameController;
  final SettingsController settingsController;

  const GameScreen({
    super.key,
    required this.gameController,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = settingsController.darkTheme;
    const diffNames = ['EASY', 'MEDIUM', 'HARD', 'EXPERT'];
    final diffLabel = (gameController.difficulty >= 0 && gameController.difficulty < 4)
        ? diffNames[gameController.difficulty]
        : 'SUDOKU';

    final mins = gameController.elapsedSeconds ~/ 60;
    final secs = gameController.elapsedSeconds % 60;
    final timeStr = '$mins:${secs.toString().padLeft(2, '0')}';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!gameController.isPaused && !gameController.isFinished) {
          gameController.pauseGame();
        } else {
          gameController.exitToHome();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(isDark),
        body: SafeArea(
          child: Stack(
            children: [
              OrientationBuilder(
                builder: (context, orientation) {
                  final isLandscape = orientation == Orientation.landscape;

                  if (isLandscape) {
                    return _buildLandscapeLayout(context, isDark, diffLabel, timeStr);
                  }
                  return _buildPortraitLayout(context, isDark, diffLabel, timeStr);
                },
              ),

              // Toast Message popup
              if (gameController.isMessageVisible)
                Positioned(
                  top: 130,
                  left: 36,
                  right: 36,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: gameController.isErrorMessage && settingsController.highlightIncorrect
                            ? AppColors.error
                            : const Color(0xE01C2B4E),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        gameController.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

              // Fullscreen Pause / Complete Overlay
              GameOverlay(
                gameController: gameController,
                settingsController: settingsController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark, String diffLabel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(
            icon: Icons.chevron_left_rounded,
            size: 36,
            isDark: isDark,
            onTap: () {
              gameController.saveProgress();
              gameController.pauseGame();
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3D3A2F) : const Color(0xFFFAEFCA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              diffLabel,
              style: TextStyle(
                color: isDark ? AppColors.primaryText(isDark) : AppColors.deepBlue,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          _buildCircleButton(
            icon: Icons.pause_rounded,
            size: 20,
            isDark: isDark,
            onTap: gameController.pauseGame,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark, String timeStr) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 8),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Time', timeStr, isDark),
          _buildMistakesItem(isDark),
          _buildStatItem('Score', '${gameController.score}', isDark),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    bool isDark,
    String diffLabel,
    String timeStr,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;

        // Reserve space for top bar (48), stats row (50), action bar (54), keypad (94), and padding (24)
        const reservedHeight = 48.0 + 50.0 + 54.0 + 94.0 + 24.0;
        final maxBoardHeight = availableHeight - reservedHeight;
        final maxBoardWidth = availableWidth - 20.0;
        final boardSize = min(maxBoardWidth, maxBoardHeight).clamp(180.0, 420.0);

        return Column(
          children: [
            _buildTopBar(context, isDark, diffLabel),
            _buildStatsRow(isDark, timeStr),
            const Spacer(),
            Center(
              child: SudokuBoard(
                gameController: gameController,
                settingsController: settingsController,
                size: boardSize,
              ),
            ),
            const Spacer(),
            GameActionBar(
              gameController: gameController,
              settingsController: settingsController,
            ),
            const SizedBox(height: 4),
            GameKeypad(
              gameController: gameController,
              settingsController: settingsController,
              isLandscape: false,
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    bool isDark,
    String diffLabel,
    String timeStr,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = min(constraints.maxWidth * 0.46, constraints.maxHeight - 110.0).clamp(180.0, 420.0);

        return Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _buildTopBar(context, isDark, diffLabel),
                  _buildStatsRow(isDark, timeStr),
                  Expanded(
                    child: Center(
                      child: SudokuBoard(
                        gameController: gameController,
                        settingsController: settingsController,
                        size: boardSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GameActionBar(
                    gameController: gameController,
                    settingsController: settingsController,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GameKeypad(
                      gameController: gameController,
                      settingsController: settingsController,
                      isLandscape: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required double size,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
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
        child: Center(
          child: Icon(
            icon,
            size: size,
            color: isDark ? AppColors.gold : AppColors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.mutedText(isDark),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: AppColors.primaryText(isDark),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMistakesItem(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Mistakes',
          style: TextStyle(
            color: AppColors.mutedText(isDark),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_rounded, color: AppColors.heart, size: 16),
            const SizedBox(width: 4),
            Text(
              '${gameController.mistakes}/3',
              style: TextStyle(
                color: AppColors.primaryText(isDark),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
