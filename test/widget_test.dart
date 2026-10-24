import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_king/main.dart';
import 'package:sudoku_king/presentation/controllers/game_controller.dart';
import 'package:sudoku_king/presentation/controllers/settings_controller.dart';
import 'package:sudoku_king/presentation/controllers/stats_controller.dart';
import 'package:sudoku_king/services/audio_service.dart';
import 'package:sudoku_king/services/storage_service.dart';

void main() {
  testWidgets('Sudoku King smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();
    final settingsController = SettingsController(storageService);
    final statsController = StatsController(storageService);
    final audioService = AudioService();
    final gameController = GameController(
      storageService: storageService,
      settingsController: settingsController,
      statsController: statsController,
      audioService: audioService,
    );

    await tester.pumpWidget(SudokuKingApp(
      settingsController: settingsController,
      statsController: statsController,
      gameController: gameController,
      audioService: audioService,
    ));

    expect(find.text('SUDOKU'), findsOneWidget);
    expect(find.text('KING'), findsOneWidget);
    expect(find.text('Choose your challenge'), findsOneWidget);
    expect(find.text('EASY'), findsOneWidget);
    expect(find.text('MEDIUM'), findsOneWidget);
    expect(find.text('HARD'), findsOneWidget);
    expect(find.text('EXPERT'), findsOneWidget);
  });
}
