import 'package:hive_flutter/hive_flutter.dart';
import 'package:mescat/features/marketplace/pages/library_page.dart';

final class ApplyConfig {
  static const String name = 'apply';

  static void setChatInput(String path) async {
    final applyBox = await Hive.openBox(name);
    applyBox.put(ApplyType.chatinput.toString(), path);
  }

  static void setChatList(String path) async {
    final applyBox = await Hive.openBox(name);
    applyBox.put(ApplyType.chatlist.toString(), path);
  }

  static void setRoomList(String path) async {
    final applyBox = await Hive.openBox(name);
    applyBox.put(ApplyType.roomlist.toString(), path);
  }

  static void setUserBox(String path) async {
    final applyBox = await Hive.openBox(name);
    applyBox.put(ApplyType.userbox.toString(), path);
  }

  static Future<String?> getRoomList() async {
    final applyBox = await Hive.openBox(name);
    return applyBox.get(ApplyType.roomlist.toString()) as String?;
  }

  static Future<String?> getChatList() async {
    final applyBox = await Hive.openBox(name);
    return applyBox.get(ApplyType.chatlist.toString()) as String?;
  }

  static Future<String?> getChatInput() async {
    final applyBox = await Hive.openBox(name);
    return applyBox.get(ApplyType.chatinput.toString()) as String?;
  }

  static Future<String?> getUserBox() async {
    final applyBox = await Hive.openBox(name);
    return applyBox.get(ApplyType.userbox.toString()) as String?;
  }
}
