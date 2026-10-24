# Sudoku King (Cross-Platform Flutter: Android & iOS)

A pure, modern Flutter application refactored from the native Android Studio Java codebase (`com.mistercaptain.sudokuking`).

## Highlights & Features
- **Pure Flutter Architecture**: Built using pure Flutter (`ValueNotifier` / `ChangeNotifier`) with zero external state management dependencies.
- **Original Signature Theme**: Warm ivory, navy, and gold palette with instant Light & Dark theme toggle.
- **100% Solvable Unique Puzzles**: Algorithmic backtracking solver with guaranteed single unique solutions across Easy, Medium, Hard, and Expert tiers.
- **Daily Challenges**: Seed-stable daily puzzles, 2-year calendar navigator, and current/best streak trackers.
- **Lifetime Statistics**: Win rate, best time, average time, difficulty breakdown charts, and current completion streaks.
- **Full Game Loop**: Undo history (up to 80 steps), candidate pencil notes with auto-clearing, 3 mistakes counter, hints, pause/resume, and victory trophies.
- **Audio & Haptics**: Looping background music (`puzzle_music.mp3`), click feedback, and device vibration.
- **Platform Placeholders**: Clean abstraction layer in `PlatformService` ready for `wakelock_plus`, `flutter_local_notifications`, and in-app review.

## Running the Application

### Android
```bash
flutter run -d android
```

### iOS (on macOS)
```bash
flutter run -d ios
```

### Run Tests & Verification
```bash
flutter test
flutter analyze
```

## Project Structure
- `lib/core/engine/`: Pure Dart `SudokuEngine` solver and generator.
- `lib/core/theme/`: Palette and dark/light mode specifications.
- `lib/data/models/`: Game snapshots, stats models, settings, and saved game models.
- `lib/services/`: Storage (`shared_preferences`), Audio (`audioplayers`), and `PlatformService` placeholders.
- `lib/presentation/controllers/`: `GameController`, `SettingsController`, `StatsController`.
- `lib/presentation/widgets/`: Composited 9x9 board, cell widgets, keypad, action bar, crown, trophy, and dialog overlays.
- `lib/presentation/screens/`: Home, Game, Daily Challenges, Statistics, Settings, and Privacy Policy.
- `assets/audio/`: Original `puzzle_music.mp3` and `background_music.wav`.
- `assets/icons/`: Original `ic_sudoku_king.xml`.
