import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:matrix/matrix.dart';

  class McEncryptionProvider extends EncryptionKeyProvider {
  // Store encryption keys per participant and index
  final Map<String, Map<int, Uint8List>> _encryptionKeys = {};
  
  // Generate a unique key for participant identification
  String _getParticipantKey(CallParticipant participant) {
    return '${participant.userId}_${participant.deviceId ?? 'unknown'}';
  }

  @override
  Future<Uint8List> onExportKey(CallParticipant participant, int index) async {
    final participantKey = _getParticipantKey(participant);
    
    // Check if key exists for this participant and index
    if (_encryptionKeys.containsKey(participantKey) &&
        _encryptionKeys[participantKey]!.containsKey(index)) {
      return _encryptionKeys[participantKey]![index]!;
    }
    
    // Generate a new key if it doesn't exist
    final key = _generateEncryptionKey(participant, index);
    
    // Store the key
    _encryptionKeys.putIfAbsent(participantKey, () => {});
    _encryptionKeys[participantKey]![index] = key;
    
    return key;
  }

  @override
  Future<Uint8List> onRatchetKey(CallParticipant participant, int index) async {
    final participantKey = _getParticipantKey(participant);
    
    // Get the current key or generate a new one
    final currentKey = _encryptionKeys[participantKey]?[index] ?? 
                       await onExportKey(participant, index);
    
    // Derive a new key using HKDF-like approach with SHA256
    final newKeyData = sha256.convert([
      ...currentKey,
      ...utf8.encode('ratchet'),
      index,
    ]).bytes;
    
    final newKey = Uint8List.fromList(newKeyData);
    
    // Store the ratcheted key
    _encryptionKeys[participantKey]![index] = newKey;
    
    return newKey;
  }

  @override
  Future<void> onSetEncryptionKey(
    CallParticipant participant,
    Uint8List key,
    int index,
  ) async {
    final participantKey = _getParticipantKey(participant);
    
    // Initialize the map if it doesn't exist
    _encryptionKeys.putIfAbsent(participantKey, () => {});
    
    // Store the provided key
    _encryptionKeys[participantKey]![index] = key;
  }

  // Helper method to generate a new encryption key
  Uint8List _generateEncryptionKey(CallParticipant participant, int index) {
    final participantKey = _getParticipantKey(participant);
    
    // Generate a deterministic but unique key based on participant info and index
    final keyData = sha256.convert([
      ...utf8.encode(participantKey),
      ...utf8.encode('encryption_key'),
      index,
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Add timestamp for uniqueness
    ]).bytes;
    
    return Uint8List.fromList(keyData);
  }

  // Method to clear keys for a specific participant
  void clearParticipantKeys(CallParticipant participant) {
    final participantKey = _getParticipantKey(participant);
    _encryptionKeys.remove(participantKey);
  }

  // Method to clear all keys
  void clearAllKeys() {
    _encryptionKeys.clear();
  }
}