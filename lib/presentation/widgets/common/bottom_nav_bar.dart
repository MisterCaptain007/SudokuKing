import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Bottom navigation bar matching the native Sudoku King design with gold underline indicator.
class SudokuBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onTabSelected;

  const SudokuBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.isDark,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      {'label': 'Home', 'icon': Icons.home_rounded},
      {'label': 'Daily', 'icon': Icons.calendar_month_rounded},
      {'label': 'Stats', 'icon': Icons.bar_chart_rounded},
      {'label': 'Settings', 'icon': Icons.settings_rounded},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x5A1D2538) : const Color(0x1C1D2538),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;
          final color = isSelected
              ? (isDark ? AppColors.gold : AppColors.deepBlue)
              : AppColors.mutedText(isDark);

          return Expanded(
            child: InkWell(
              onTap: () => onTabSelected(index),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    items[index]['icon'] as IconData,
                    color: color,
                    size: 22,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    items[index]['label'] as String,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 3),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    width: isSelected ? 18 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
