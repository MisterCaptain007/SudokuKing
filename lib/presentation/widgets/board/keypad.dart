import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/settings_controller.dart';

/// Keypad for entering numbers 1-9 and backspace.
class GameKeypad extends StatelessWidget {
  final GameController gameController;
  final SettingsController settingsController;
  final bool isLandscape;

  const GameKeypad({
    super.key,
    required this.gameController,
    required this.settingsController,
    this.isLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = settingsController.darkTheme;
    final showRemaining = settingsController.showRemainingNumbers;

    if (isLandscape) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.5,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final n = index + 1;
          final isFull = showRemaining && gameController.isNumberComplete(n);
          return _buildKey(
            label: '$n',
            isCompleted: isFull,
            isDark: isDark,
            onTap: () => gameController.enterNumber(n),
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(5, (index) {
              final n = index + 1;
              final isFull = showRemaining && gameController.isNumberComplete(n);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                  child: _buildKey(
                    label: '$n',
                    isCompleted: isFull,
                    isDark: isDark,
                    onTap: () => gameController.enterNumber(n),
                  ),
                ),
              );
            }),
          ),
          Row(
            children: [
              for (var i = 6; i <= 9; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                    child: _buildKey(
                      label: '$i',
                      isCompleted: showRemaining && gameController.isNumberComplete(i),
                      isDark: isDark,
                      onTap: () => gameController.enterNumber(i),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                  child: _buildKey(
                    icon: Icons.backspace_outlined,
                    isCompleted: false,
                    isDark: isDark,
                    onTap: gameController.eraseCurrentCell,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey({
    String? label,
    IconData? icon,
    required bool isCompleted,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bg = AppColors.surface(isDark);
    final textColor = isCompleted
        ? AppColors.mutedText(isDark).withValues(alpha: 0.4)
        : AppColors.primaryText(isDark);

    return InkWell(
      onTap: isCompleted ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF354260) : const Color(0xFFEBE4D2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x351D2538) : const Color(0x101D2538),
              offset: const Offset(0, 2),
              blurRadius: 3,
            ),
          ],
        ),
        child: Center(
          child: icon != null
              ? Icon(
                  icon,
                  color: AppColors.mutedText(isDark),
                  size: 20,
                )
              : Text(
                  label!,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
