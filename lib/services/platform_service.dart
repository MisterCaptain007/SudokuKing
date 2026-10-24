import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Defines placeholder configurations and abstract implementations for platform-specific APIs
/// (Screen Keep-Awake, Local Push Notifications, Store Review, and Support Intents).
///
/// These placeholders can easily be replaced by real native plugins (e.g. `wakelock_plus`,
/// `flutter_local_notifications`, `in_app_review`) when ready for production deployment.
class PlatformService {
  static const String appPackageId = 'com.mistercaptain.sudokuking';
  static const String supportEmail = 'sudokuking.support@gmail.com';

  /// --- 1. Screen Keep-Awake (FLAG_KEEP_SCREEN_ON) ---
  /// Set to true by default in the original native app to prevent screen dimming during gameplay.
  static Future<void> setScreenAwake(bool keepAwake) async {
    debugPrint('[PlatformService] setScreenAwake: $keepAwake (Placeholder - Ready for wakelock_plus)');
    // Placeholder implementation: Ready for `await WakelockPlus.toggle(on: keepAwake);`
  }

  /// --- 2. Local Push Notifications ---
  /// Placeholder configuration for daily challenge reminders.
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    debugPrint(
      '[PlatformService] scheduleDailyReminder at $hour:$minute: "$title" - "$body" '
      '(Placeholder - Ready for flutter_local_notifications)',
    );
    // Placeholder configuration:
    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //   0,
    //   title,
    //   body,
    //   _nextInstanceOfTime(hour, minute),
    //   notificationDetails,
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //   uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    //   matchDateTimeComponents: DateTimeComponents.time,
    // );
  }

  /// --- 3. App Store / Google Play Listing Intent ---
  static Future<bool> openStoreListing() async {
    debugPrint('[PlatformService] openStoreListing for package: $appPackageId');
    // Placeholder configuration: can invoke url_launcher or in_app_review:
    // final uri = Uri.parse('https://play.google.com/store/apps/details?id=$appPackageId');
    // return await launchUrl(uri, mode: LaunchMode.externalApplication);
    return true;
  }

  /// --- 4. Support Email Intent ---
  static Future<bool> contactSupport() async {
    debugPrint('[PlatformService] contactSupport: mailto:$supportEmail');
    // Placeholder configuration:
    // final emailUri = Uri(
    //   scheme: 'mailto',
    //   path: supportEmail,
    //   query: 'subject=Sudoku King Support Request',
    // );
    // return await launchUrl(emailUri);
    return true;
  }

  /// --- 5. Device Hardware Haptics ---
  static Future<void> triggerHaptic({bool heavy = false}) async {
    if (heavy) {
      await HapticFeedback.heavyImpact();
    } else {
      await HapticFeedback.selectionClick();
    }
  }
}
