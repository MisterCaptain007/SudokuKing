import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/settings_controller.dart';
import '../common/crown_widget.dart';
import '../common/trophy_widget.dart';

/// Modal overlay for Paused, Out of Lives, and Victory Completion states.
class GameOverlay extends StatelessWidget {
  final GameController gameController;
  final SettingsController settingsController;

  const GameOverlay({
    super.key,
    required this.gameController,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    if (!gameController.isPaused && !gameController.isFinished) {
      return const SizedBox.shrink();
    }

    final isDark = settingsController.darkTheme;

    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface(isDark),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 8),
                  blurRadius: 16,
                ),
              ],
            ),
            child: _buildDialogContent(context, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context, bool isDark) {
    if (gameController.isFinished) {
      return _buildVictoryContent(context, isDark);
    }
    if (gameController.isOutOfLives) {
      return _buildOutOfLivesContent(context, isDark);
    }
    return _buildPausedContent(context, isDark);
  }

  Widget _buildPausedContent(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CrownWidget(size: 36, isDark: isDark),
        const SizedBox(height: 12),
        Text(
          'Game Paused',
          style: TextStyle(
            color: AppColors.primaryText(isDark),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        _buildButton(
          label: '▶   Resume Game',
          color: AppColors.gold,
          textColor: AppColors.deepBlue,
          onTap: gameController.resumeGame,
        ),
        const SizedBox(height: 12),
        _buildButton(
          label: '⟳   Restart Game',
          color: AppColors.surface(isDark),
          textColor: AppColors.primaryText(isDark),
          border: true,
          isDark: isDark,
          onTap: () {
            if (settingsController.confirmRestart) {
              _showRestartConfirm(context, isDark);
            } else {
              gameController.restartCurrentGame();
            }
          },
        ),
        const SizedBox(height: 12),
        _buildButton(
          label: '⌂   Exit to Home',
          color: AppColors.surface(isDark),
          textColor: AppColors.primaryText(isDark),
          border: true,
          isDark: isDark,
          onTap: gameController.exitToHome,
        ),
      ],
    );
  }

  Widget _buildOutOfLivesContent(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.heart_broken_rounded, color: AppColors.heart, size: 48),
        const SizedBox(height: 12),
        Text(
          'Out of lives',
          style: TextStyle(
            color: AppColors.primaryText(isDark),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'You have used all 3 chances.',
          style: TextStyle(
            color: AppColors.mutedText(isDark),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),
        _buildButton(
          label: 'EXIT TO HOME',
          color: AppColors.surface(isDark),
          textColor: AppColors.primaryText(isDark),
          border: true,
          isDark: isDark,
          onTap: gameController.exitToHome,
        ),
        const SizedBox(height: 12),
        _buildButton(
          label: 'NEW GAME',
          color: AppColors.gold,
          textColor: AppColors.deepBlue,
          onTap: gameController.restartCurrentGame,
        ),
      ],
    );
  }

  Widget _buildVictoryContent(BuildContext context, bool isDark) {
    final mins = gameController.elapsedSeconds ~/ 60;
    final secs = gameController.elapsedSeconds % 60;
    final timeStr = '$mins:${secs.toString().padLeft(2, '0')}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Puzzle Completed!',
          style: TextStyle(
            color: AppColors.primaryText(isDark),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TrophyWidget(size: 90, isDark: isDark),
        const SizedBox(height: 12),
        Text(
          'Great Job!',
          style: TextStyle(
            color: AppColors.primaryText(isDark),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatChip('Time', timeStr, isDark),
            _buildStatChip('Mistakes', '${gameController.mistakes}', isDark),
            _buildStatChip('Score', '${gameController.score}', isDark),
          ],
        ),
        const SizedBox(height: 24),
        _buildButton(
          label: 'PLAY AGAIN',
          color: AppColors.gold,
          textColor: AppColors.deepBlue,
          onTap: gameController.restartCurrentGame,
        ),
        const SizedBox(height: 12),
        _buildButton(
          label: 'HOME',
          color: AppColors.surface(isDark),
          textColor: AppColors.primaryText(isDark),
          border: true,
          isDark: isDark,
          onTap: gameController.exitToHome,
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, bool isDark) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.mutedText(isDark),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryText(isDark),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required Color textColor,
    bool border = false,
    bool isDark = false,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: border
                ? BorderSide(
                    color: isDark ? const Color(0xFF44506C) : AppColors.line,
                    width: 1,
                  )
                : BorderSide.none,
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _showRestartConfirm(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface(isDark),
        title: Text(
          'Restart game?',
          style: TextStyle(color: AppColors.primaryText(isDark)),
        ),
        content: Text(
          'Your current puzzle progress will be lost.',
          style: TextStyle(color: AppColors.mutedText(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.mutedText(isDark)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              gameController.restartCurrentGame();
            },
            child: const Text('Restart', style: TextStyle(color: AppColors.goldDark)),
          ),
        ],
      ),
    );
  }
}
