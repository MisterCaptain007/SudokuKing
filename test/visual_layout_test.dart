import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_king/main.dart';
import 'package:sudoku_king/presentation/controllers/game_controller.dart';
import 'package:sudoku_king/presentation/controllers/settings_controller.dart';
import 'package:sudoku_king/presentation/controllers/stats_controller.dart';
import 'package:sudoku_king/services/audio_service.dart';
import 'package:sudoku_king/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> saveScreenshot(WidgetTester tester, String filename) async {
    await tester.runAsync(() async {
      final boundaryFinder = find.byType(RepaintBoundary).first;
      final element = boundaryFinder.evaluate().first;
      final renderObject = element.renderObject as RenderRepaintBoundary;
      final image = await renderObject.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final outDir = Directory('screenshots');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }
      File('screenshots/$filename').writeAsBytesSync(buffer);
    });
  }

  testWidgets('Visual sanity check & screenshot generation for iPhone viewport', (tester) async {
    // Configure standard iPhone 15/16 logical size: 393 x 852
    tester.view.physicalSize = const Size(393 * 2, 852 * 2);
    tester.view.devicePixelRatio = 2.0;

    final storage = await StorageService.init();
    final settings = SettingsController(storage);
    final stats = StatsController(storage);
    final audio = AudioService(enableAudio: false);
    final game = GameController(
      storageService: storage,
      settingsController: settings,
      statsController: stats,
      audioService: audio,
    );

    // 1. Home Screen (Light)
    await tester.pumpWidget(
      RepaintBoundary(
        child: SudokuKingApp(
          settingsController: settings,
          statsController: stats,
          gameController: game,
          audioService: audio,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('SUDOKU'), findsOneWidget);
    expect(find.text('KING'), findsOneWidget);
    await saveScreenshot(tester, '01_home_screen_light.png');

    // 2. Home Screen (Dark Mode)
    settings.toggleDarkTheme();
    await tester.pumpAndSettle();
    await saveScreenshot(tester, '02_home_screen_dark.png');
    settings.toggleDarkTheme(); // return to light
    await tester.pumpAndSettle();

    // 3. Daily Challenge Screen
    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();
    expect(find.text('Daily Challenge'), findsOneWidget);
    expect(find.text('Current Streak'), findsOneWidget);
    await saveScreenshot(tester, '03_daily_challenge.png');

    // 4. Statistics Screen
    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('Difficulty Breakdown'), findsOneWidget);
    await saveScreenshot(tester, '04_statistics_screen.png');

    // 5. Settings Screen
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.text('Gameplay'), findsOneWidget);
    expect(find.text('Sound & Appearance'), findsOneWidget);
    await saveScreenshot(tester, '05_settings_screen.png');

    // 6. Active Game Screen
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('EASY'));
    await tester.pumpAndSettle();
    expect(find.text('EASY'), findsOneWidget);
    expect(find.text('Mistakes'), findsOneWidget);
    // Select cell (0, 0)
    game.selectCell(0, 0);
    await tester.pumpAndSettle();
    await saveScreenshot(tester, '06_active_game_screen.png');

    // 7. Paused Overlay
    game.pauseGame();
    await tester.pumpAndSettle();
    expect(find.text('Game Paused'), findsOneWidget);
    expect(find.text('▶   Resume Game'), findsOneWidget);
    await saveScreenshot(tester, '07_game_paused_overlay.png');

    // Reset view
    addTearDown(tester.view.reset);
  });
}
