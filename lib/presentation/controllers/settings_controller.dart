import 'package:flutter/material.dart';
import '../../data/models/settings_data.dart';
import '../../services/storage_service.dart';

/// Controller managing app settings and light/dark theme state.
class SettingsController extends ChangeNotifier {
  final StorageService _storageService;
  late SettingsData _settings;

  SettingsController(this._storageService) {
    _settings = _storageService.loadSettings();
  }

  SettingsData get settings => _settings;
  bool get darkTheme => _settings.darkTheme;
  bool get highlightMatches => _settings.highlightMatches;
  bool get highlightIncorrect => _settings.highlightIncorrect;
  bool get showRemainingNumbers => _settings.showRemainingNumbers;
  bool get confirmRestart => _settings.confirmRestart;
  bool get soundEnabled => _settings.soundEnabled;
  bool get vibrationEnabled => _settings.vibrationEnabled;
  bool get musicEnabled => _settings.musicEnabled;
  String get numberStyle => _settings.numberStyle;

  void toggleDarkTheme() {
    _settings.darkTheme = !_settings.darkTheme;
    _persist();
  }

  void setDarkTheme(bool value) {
    if (_settings.darkTheme == value) return;
    _settings.darkTheme = value;
    _persist();
  }

  void toggleHighlightMatches() {
    _settings.highlightMatches = !_settings.highlightMatches;
    _persist();
  }

  void toggleHighlightIncorrect() {
    _settings.highlightIncorrect = !_settings.highlightIncorrect;
    _persist();
  }

  void toggleShowRemainingNumbers() {
    _settings.showRemainingNumbers = !_settings.showRemainingNumbers;
    _persist();
  }

  void toggleConfirmRestart() {
    _settings.confirmRestart = !_settings.confirmRestart;
    _persist();
  }

  void toggleSound() {
    _settings.soundEnabled = !_settings.soundEnabled;
    _persist();
  }

  void toggleVibration() {
    _settings.vibrationEnabled = !_settings.vibrationEnabled;
    _persist();
  }

  void toggleMusic() {
    _settings.musicEnabled = !_settings.musicEnabled;
    _persist();
  }

  void _persist() {
    _storageService.saveSettings(_settings);
    notifyListeners();
  }
}
