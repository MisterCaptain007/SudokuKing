import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../controllers/settings_controller.dart';

/// Privacy Policy screen detailing local offline storage guarantees.
class PrivacyPolicyScreen extends StatelessWidget {
  final SettingsController settingsController;
  final VoidCallback onBack;

  const PrivacyPolicyScreen({
    super.key,
    required this.settingsController,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = settingsController.darkTheme;

    final sections = [
      {
        'title': '1. Information We Collect',
        'body': 'Sudoku King does not collect any personal information from users. Your game progress, settings, and statistics are stored only on your device.',
      },
      {
        'title': "2. Children's Privacy",
        'body': 'Sudoku King is designed for users of all ages, including children. Game progress and settings are stored locally on your device.',
      },
      {
        'title': '3. Data Sharing',
        'body': 'Sudoku King does not collect or share personal information.',
      },
      {
        'title': '4. Contact Us',
        'body': 'If you have any questions about this Privacy Policy, contact us at sudokuking.support@gmail.com.',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: onBack,
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
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: isDark ? AppColors.gold : AppColors.blue,
                        size: 26,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: AppColors.primaryText(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface(isDark),
                    borderRadius: BorderRadius.circular(20),
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
                      for (final sec in sections) ...[
                        Text(
                          sec['title']!,
                          style: TextStyle(
                            color: AppColors.primaryText(isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sec['body']!,
                          style: TextStyle(
                            color: AppColors.mutedText(isDark),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
