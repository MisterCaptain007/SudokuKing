import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/platform_service.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';

/// Settings screen for gameplay, appearance, data resets, and support.
class SettingsScreen extends StatelessWidget {
  final SettingsController settingsController;
  final GameController gameController;
  final VoidCallback onOpenPrivacyPolicy;

  const SettingsScreen({
    super.key,
    required this.settingsController,
    required this.gameController,
    required this.onOpenPrivacyPolicy,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = settingsController.darkTheme;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: AppColors.primaryText(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Gameplay Section
                  _buildSectionTitle('Gameplay', isDark),
                  _buildCard(
                    isDark,
                    children: [
                      _buildSwitchTile(
                        label: 'Highlight matching numbers',
                        value: settingsController.highlightMatches,
                        isDark: isDark,
                        onChanged: (v) => settingsController.toggleHighlightMatches(),
                      ),
                      _buildDivider(isDark),
                      _buildSwitchTile(
                        label: 'Highlight incorrect entries',
                        value: settingsController.highlightIncorrect,
                        isDark: isDark,
                        onChanged: (v) => settingsController.toggleHighlightIncorrect(),
                      ),
                      _buildDivider(isDark),
                      _buildSwitchTile(
                        label: 'Show remaining numbers',
                        value: settingsController.showRemainingNumbers,
                        isDark: isDark,
                        onChanged: (v) => settingsController.toggleShowRemainingNumbers(),
                      ),
                      _buildDivider(isDark),
                      _buildSwitchTile(
                        label: 'Confirm before restart',
                        value: settingsController.confirmRestart,
                        isDark: isDark,
                        onChanged: (v) => settingsController.toggleConfirmRestart(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Sound & Appearance Section
                  _buildSectionTitle('Sound & Appearance', isDark),
                  _buildCard(
                    isDark,
                    children: [
                      _buildSwitchTile(
                        label: 'Sound',
                        value: settingsController.soundEnabled,
                        isDark: isDark,
                        onChanged: (v) => settingsController.toggleSound(),
                      ),
                      _buildDivider(isDark),
                      _buildSwitchTile(
                        label: 'Vibration',
                        value: settingsController.vibrationEnabled,
                        isDark: isDark,
                        onChanged: (v) => settingsController.toggleVibration(),
                      ),
                      _buildDivider(isDark),
                      _buildSwitchTile(
                        label: 'Background music',
                        value: settingsController.musicEnabled,
                        isDark: isDark,
                        onChanged: (v) => settingsController.toggleMusic(),
                      ),
                      _buildDivider(isDark),

                      // Theme Pill Selector
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Theme',
                              style: TextStyle(
                                color: AppColors.primaryText(isDark),
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              height: 32,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF354058) : const Color(0xFFEFEADE),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  _buildThemePillOption('Light', !isDark, isDark, () {
                                    settingsController.setDarkTheme(false);
                                  }),
                                  _buildThemePillOption('Dark', isDark, isDark, () {
                                    settingsController.setDarkTheme(true);
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildDivider(isDark),

                      _buildActionTile(
                        label: 'Number style',
                        trailing: 'Modern',
                        isDark: isDark,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Modern number style is active')),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Progress & Data Section
                  _buildSectionTitle('Progress & Data', isDark),
                  _buildCard(
                    isDark,
                    children: [
                      _buildActionTile(
                        label: 'Clear saved game',
                        trailing: '›',
                        isDark: isDark,
                        isEnabled: gameController.hasSavedProgress,
                        onTap: () {
                          if (gameController.hasSavedProgress) {
                            _showClearSavedDialog(context, isDark);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No saved game to clear')),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // About & Support Section
                  _buildSectionTitle('About & Support', isDark),
                  _buildCard(
                    isDark,
                    children: [
                      _buildActionTile(
                        label: 'Rate Us',
                        trailing: '›',
                        isDark: isDark,
                        onTap: PlatformService.openStoreListing,
                      ),
                      _buildDivider(isDark),
                      _buildActionTile(
                        label: 'Contact Support',
                        trailing: '›',
                        isDark: isDark,
                        onTap: PlatformService.contactSupport,
                      ),
                      _buildDivider(isDark),
                      _buildActionTile(
                        label: 'Privacy Policy',
                        trailing: '›',
                        isDark: isDark,
                        onTap: onOpenPrivacyPolicy,
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primaryText(isDark),
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCard(bool isDark, {required List<Widget> children}) {
    return Container(
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
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.primaryText(isDark),
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: const Color(0xFF4779E9),
            inactiveTrackColor: isDark ? const Color(0xFF545E72) : const Color(0xFFD1D3D3),
            thumbColor: const WidgetStatePropertyAll(Colors.white),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildThemePillOption(String label, bool isSelected, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? const Color(0xFF4779E9) : AppColors.surface(false)) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDark ? Colors.white : AppColors.primaryText(isDark))
                : AppColors.mutedText(isDark),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String label,
    required String trailing,
    required bool isDark,
    bool isEnabled = true,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? AppColors.primaryText(isDark) : AppColors.mutedText(isDark),
                fontSize: 14,
              ),
            ),
            Text(
              trailing,
              style: TextStyle(
                color: AppColors.mutedText(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.8,
      indent: 16,
      endIndent: 16,
      color: isDark ? const Color(0xFF34405B) : const Color(0xFFEEE7D7),
    );
  }

  void _showClearSavedDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface(isDark),
        title: Text(
          'Clear saved game?',
          style: TextStyle(color: AppColors.primaryText(isDark)),
        ),
        content: Text(
          'Your saved puzzle progress will be deleted.',
          style: TextStyle(color: AppColors.mutedText(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.mutedText(isDark))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              gameController.clearSavedProgress();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved game cleared')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
