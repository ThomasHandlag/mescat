import 'package:flutter/services.dart';

final class ServerListsFile {
  static final String assetPath = 'assets/files/public_server.json';

  static Future<String> loadServerListAsset() async {
    return await rootBundle.loadString(assetPath);
  }
}
