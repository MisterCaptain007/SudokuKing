import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/stats_controller.dart';
import '../widgets/common/bottom_nav_bar.dart';
import 'daily_challenge_screen.dart';
import 'game_screen.dart';
import 'home_screen.dart';
import 'privacy_policy_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

/// Main navigation shell managing the 4 tabs and displaying GameScreen when a game is active.
class MainShell extends StatefulWidget {
  final GameController gameController;
  final SettingsController settingsController;
  final StatsController statsController;

  const MainShell({
    super.key,
    required this.gameController,
    required this.settingsController,
    required this.statsController,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentTab = 0; // 0 = Home, 1 = Daily, 2 = Stats, 3 = Settings
  bool _showingPrivacyPolicy = false;

  @override
  Widget build(BuildContext context) {
    // If active game is in progress, display GameScreen directly
    if (widget.gameController.isPlaying) {
      return GameScreen(
        gameController: widget.gameController,
        settingsController: widget.settingsController,
      );
    }

    final isDark = widget.settingsController.darkTheme;

    Widget body;
    if (_showingPrivacyPolicy) {
      body = PrivacyPolicyScreen(
        settingsController: widget.settingsController,
        onBack: () {
          setState(() {
            _showingPrivacyPolicy = false;
          });
        },
      );
    } else {
      switch (_currentTab) {
        case 1:
          body = DailyChallengeScreen(
            gameController: widget.gameController,
            settingsController: widget.settingsController,
            statsController: widget.statsController,
          );
          break;
        case 2:
          body = StatisticsScreen(
            statsController: widget.statsController,
            settingsController: widget.settingsController,
          );
          break;
        case 3:
          body = SettingsScreen(
            settingsController: widget.settingsController,
            gameController: widget.gameController,
            onOpenPrivacyPolicy: () {
              setState(() {
                _showingPrivacyPolicy = true;
              });
            },
          );
          break;
        default:
          body = HomeScreen(
            gameController: widget.gameController,
            settingsController: widget.settingsController,
          );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: body,
      bottomNavigationBar: _showingPrivacyPolicy
          ? null
          : SudokuBottomNavBar(
              currentIndex: _currentTab,
              isDark: isDark,
              onTabSelected: (index) {
                setState(() {
                  _currentTab = index;
                  _showingPrivacyPolicy = false;
                });
              },
            ),
    );
  }
}
