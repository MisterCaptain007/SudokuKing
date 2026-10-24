import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/settings_controller.dart';

/// Action bar during gameplay: Undo, Erase, Notes Mode, and Hint.
class GameActionBar extends StatelessWidget {
  final GameController gameController;
  final SettingsController settingsController;

  const GameActionBar({
    super.key,
    required this.gameController,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = settingsController.darkTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.undo_rounded,
            label: 'Undo',
            isActive: false,
            isDark: isDark,
            onTap: gameController.undo,
          ),
          _buildActionButton(
            icon: Icons.auto_fix_high_rounded,
            label: 'Erase',
            isActive: false,
            isDark: isDark,
            onTap: gameController.eraseCurrentCell,
          ),
          _buildActionButton(
            icon: Icons.edit_note_rounded,
            label: gameController.notesMode ? 'Notes ON' : 'Notes',
            isActive: gameController.notesMode,
            isDark: isDark,
            onTap: gameController.toggleNotesMode,
          ),
          _buildActionButton(
            icon: Icons.lightbulb_rounded,
            label: 'Hint  ${gameController.hints}',
            isActive: false,
            isDark: isDark,
            onTap: gameController.requestHint,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bg = isActive
        ? (isDark ? const Color(0xFF4F4528) : const Color(0xFFFAE8AB))
        : AppColors.surface(isDark);

    final iconColor = isActive
        ? AppColors.gold
        : (isDark ? AppColors.mutedText(isDark) : AppColors.blue);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 66,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF333E59) : const Color(0xFFEDE5D2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x351D2538) : const Color(0x101D2538),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? (isDark ? AppColors.gold : AppColors.deepBlue)
                    : AppColors.mutedText(isDark),
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
