/// Holds user-configurable gameplay and visual preferences.
class SettingsData {
  bool highlightMatches;
  bool highlightIncorrect;
  bool showRemainingNumbers;
  bool confirmRestart;
  bool soundEnabled;
  bool vibrationEnabled;
  bool musicEnabled;
  bool darkTheme;
  String numberStyle;

  SettingsData({
    this.highlightMatches = true,
    this.highlightIncorrect = true,
    this.showRemainingNumbers = false,
    this.confirmRestart = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.musicEnabled = true,
    this.darkTheme = false,
    this.numberStyle = 'Modern',
  });
}
