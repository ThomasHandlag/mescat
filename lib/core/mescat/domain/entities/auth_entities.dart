import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isAuthenticated;
  final String? userId;
  final String? accessToken;
  final String? deviceId;
  final String? homeserver;
  final bool isE2EEEnabled;
  final DateTime? lastSyncTime;
  final PresenceStatus presenceStatus;
  
  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.accessToken,
    this.deviceId,
    this.homeserver,
    this.isE2EEEnabled = false,
    this.lastSyncTime,
    this.presenceStatus = PresenceStatus.offline,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? accessToken,
    String? deviceId,
    String? homeserver,
    bool? isE2EEEnabled,
    DateTime? lastSyncTime,
    PresenceStatus? presenceStatus,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      deviceId: deviceId ?? this.deviceId,
      homeserver: homeserver ?? this.homeserver,
      isE2EEEnabled: isE2EEEnabled ?? this.isE2EEEnabled,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      presenceStatus: presenceStatus ?? this.presenceStatus,
    );
  }

  @override
  List<Object?> get props => [
        isAuthenticated,
        userId,
        accessToken,
        deviceId,
        homeserver,
        isE2EEEnabled,
        lastSyncTime,
        presenceStatus,
      ];
}

class UserCredentials extends Equatable {
  final String username;
  final String password;
  final String? homeserver;
  final String? email;
  
  const UserCredentials({
    required this.username,
    required this.password,
    this.homeserver,
    this.email,
  });

  @override
  List<Object?> get props => [username, password, homeserver, email];
}

class DeviceInfo extends Equatable {
  final String deviceId;
  final String deviceName;
  final String? lastSeenIp;
  final DateTime? lastSeenTs;
  final bool isVerified;
  final bool isCrossSigningTrusted;
  
  const DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    this.lastSeenIp,
    this.lastSeenTs,
    this.isVerified = false,
    this.isCrossSigningTrusted = false,
  });

  @override
  List<Object?> get props => [
        deviceId,
        deviceName,
        lastSeenIp,
        lastSeenTs,
        isVerified,
        isCrossSigningTrusted,
      ];
}

enum PresenceStatus {
  online,
  offline,
  unavailable,
  unknown,
}

class PresenceUpdate extends Equatable {
  final String userId;
  final PresenceStatus status;
  final String? statusMessage;
  final DateTime? lastActiveAgo;

  const PresenceUpdate({
    required this.userId,
    required this.status,
    this.statusMessage,
    this.lastActiveAgo,
  });

  @override
  List<Object?> get props => [userId, status, statusMessage, lastActiveAgo];
}

class E2EEKeyInfo extends Equatable {
  final String keyId;
  final String publicKey;
  final Map<String, dynamic> signatures;
  final DateTime createdAt;
  final bool isVerified;

  const E2EEKeyInfo({
    required this.keyId,
    required this.publicKey,
    required this.signatures,
    required this.createdAt,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [keyId, publicKey, signatures, createdAt, isVerified];
}

class CrossSigningKeys extends Equatable {
  final E2EEKeyInfo? masterKey;
  final E2EEKeyInfo? selfSigningKey;
  final E2EEKeyInfo? userSigningKey;

  const CrossSigningKeys({
    this.masterKey,
    this.selfSigningKey,
    this.userSigningKey,
  });

  @override
  List<Object?> get props => [masterKey, selfSigningKey, userSigningKey];
}