import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:web3dart/web3dart.dart';

final class WalletStore {
  const WalletStore();

  static const String _keyName = 'user_key';
  static const String _passName = 'pass_key';

  String _encryptKey(String privKey, String password, String salt) {
    // Derive a 32-byte key from password and salt
    final keyBytes = _deriveKey(password, salt);
    final key = Key(keyBytes);

    // Generate a random IV (Initialization Vector)
    final iv = IV.fromSecureRandom(16);

    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(privKey, iv: iv);

    // Return IV + encrypted data (both base64 encoded)
    return '${iv.base64}:${encrypted.base64}';
  }

  String _decryptKey(String encryptedText, String password, String salt) {
    // Split IV and encrypted data
    final parts = encryptedText.split(':');
    final iv = IV.fromBase64(parts[0]);
    final encrypted = Encrypted.fromBase64(parts[1]);

    // Derive the same key
    final keyBytes = _deriveKey(password, salt);
    final key = Key(keyBytes);

    final encrypter = Encrypter(AES(key));
    return encrypter.decrypt(encrypted, iv: iv);
  }

  /// Derive a 32-byte key from password and salt
  Uint8List _deriveKey(String password, String salt) {
    final combined = encode(password + salt);
    final hash = sha256.convert(combined);
    return Uint8List.fromList(hash.bytes);
  }

  Future<void> storeKey(String privKey, String password) async {
    final value = _encryptKey(privKey, password, _keyName);
    final box = await Hive.openBox(_keyName);
    await box.put(_keyName, value);
    final passBox = await Hive.openBox(_passName);
    passBox.put(_passName, password);
  }

  Future<EthPrivateKey> retrieveKey(String password) async {
    final box = await Hive.openBox(_keyName);
    final value = await box.get(_keyName);
    final key = _decryptKey(value, password, _keyName);
    return EthPrivateKey.fromHex(key);
  }

  Future<String?> getPassword() async {
    final box = await Hive.openBox(_passName);
    return box.get(_passName);
  }

  Future<void> wipe() async {
    await Hive.deleteBoxFromDisk(_keyName);
    await Hive.deleteBoxFromDisk(_passName);
  }
}
