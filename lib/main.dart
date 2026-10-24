import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_colors.dart';
import 'presentation/controllers/game_controller.dart';
import 'presentation/controllers/settings_controller.dart';
import 'presentation/controllers/stats_controller.dart';
import 'presentation/screens/main_shell.dart';
import 'services/audio_service.dart';
import 'services/platform_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure status and navigation bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize storage
  final storageService = await StorageService.init();

  // Initialize controllers
  final settingsController = SettingsController(storageService);
  final statsController = StatsController(storageService);
  final audioService = AudioService();

  audioService.updateSettings(
    musicEnabled: settingsController.musicEnabled,
    soundEnabled: settingsController.soundEnabled,
  );

  final gameController = GameController(
    storageService: storageService,
    settingsController: settingsController,
    statsController: statsController,
    audioService: audioService,
  );

  // Set screen awake keep-on placeholder
  await PlatformService.setScreenAwake(true);

  runApp(SudokuKingApp(
    settingsController: settingsController,
    statsController: statsController,
    gameController: gameController,
    audioService: audioService,
  ));
}

/// Root widget managing reactive themes and application lifecycle.
class SudokuKingApp extends StatefulWidget {
  final SettingsController settingsController;
  final StatsController statsController;
  final GameController gameController;
  final AudioService audioService;

  const SudokuKingApp({
    super.key,
    required this.settingsController,
    required this.statsController,
    required this.gameController,
    required this.audioService,
  });

  @override
  State<SudokuKingApp> createState() => _SudokuKingAppState();
}

class _SudokuKingAppState extends State<SudokuKingApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.settingsController.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    widget.audioService.updateSettings(
      musicEnabled: widget.settingsController.musicEnabled,
      soundEnabled: widget.settingsController.soundEnabled,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      widget.audioService.pauseMusic();
      widget.gameController.saveProgress();
    } else if (state == AppLifecycleState.resumed) {
      if (widget.gameController.isPlaying && !widget.gameController.isPaused) {
        widget.audioService.startMusic();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.settingsController.removeListener(_onSettingsChanged);
    widget.audioService.dispose();
    widget.gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.settingsController,
        widget.statsController,
        widget.gameController,
      ]),
      builder: (context, _) {
        final isDark = widget.settingsController.darkTheme;

        return MaterialApp(
          title: 'Sudoku King',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.background(false),
            colorScheme: ColorScheme.light(
              primary: AppColors.blue,
              secondary: AppColors.gold,
              surface: AppColors.surface(false),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.background(true),
            colorScheme: ColorScheme.dark(
              primary: AppColors.gold,
              secondary: AppColors.blue,
              surface: AppColors.surface(true),
            ),
          ),
          home: MainShell(
            gameController: widget.gameController,
            settingsController: widget.settingsController,
            statsController: widget.statsController,
          ),
        );
      },
    );
  }
}
