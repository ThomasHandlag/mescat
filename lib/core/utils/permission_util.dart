import 'package:permission_handler/permission_handler.dart';

void requirePermissions() async {
    final cameraStat = await Permission.camera.status;
    final micStat = await Permission.microphone.status;
    final storageStat = await Permission.storage.status;

    if (cameraStat.isRestricted) {
      await Permission.camera.request();
    }

    if (micStat.isRestricted) {
      await Permission.microphone.request();
    }

    if (storageStat.isRestricted) {
      await Permission.storage.request();
    }
  }