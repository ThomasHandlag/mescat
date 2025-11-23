import 'package:flutter_background/flutter_background.dart';
import 'package:permission_handler/permission_handler.dart';

void requirePermissions() async {
  final cameraStat = await Permission.camera.status;
  final micStat = await Permission.microphone.status;
  final storageStat = await Permission.storage.status;
  final photoStat = await Permission.photos.status;
  final notificationStat = await Permission.notification.status;
  final audioStat = await Permission.audio.status;
  final videoStat = await Permission.videos.status;
  final optimizeStat = await Permission.ignoreBatteryOptimizations.status;

  if (cameraStat.isRestricted) {
    await Permission.camera.request();
  }

  if (micStat.isRestricted) {
    await Permission.microphone.request();
  }

  if (storageStat.isRestricted) {
    await Permission.storage.request();
  }

  if (photoStat.isRestricted) {
    await Permission.photos.request();
  }
  if (notificationStat.isRestricted) {
    await Permission.notification.request();
  }
  if (audioStat.isRestricted) {
    await Permission.audio.request();
  }
  if (videoStat.isRestricted) {
    await Permission.videos.request();
  }
  if (optimizeStat.isRestricted) {
    await Permission.ignoreBatteryOptimizations.request();
  }
}

Future<bool> startForegroundService() async {
  final androidConfig = const FlutterBackgroundAndroidConfig(
    notificationTitle: 'Shared Media Service',
    notificationText: 'Mescat is running in background to share media streams',
    notificationImportance: AndroidNotificationImportance.normal,
    notificationIcon: AndroidResource(
      name: 'background_icon',
      defType: 'drawable',
    ),
    shouldRequestBatteryOptimizationsOff: false,
  );
  await FlutterBackground.initialize(androidConfig: androidConfig);
  return FlutterBackground.enableBackgroundExecution();
}

Future<void> stopForegroundService() async {
  if (FlutterBackground.isBackgroundExecutionEnabled) {
    await FlutterBackground.disableBackgroundExecution();
  }
}
