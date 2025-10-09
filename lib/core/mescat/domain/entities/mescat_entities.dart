import 'package:equatable/equatable.dart';
import 'package:matrix/matrix.dart';

part 'mescat_event.dart';
part 'mescat_failure.dart';
part 'mescat_space.dart';
part 'mescat_room.dart';

/// Represents a Matrix user in the system
class MCUser extends Equatable {
  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastActiveTime;
  final String? presenceMessage;
  final UserPresence presence;

  const MCUser({
    required this.userId,
    this.displayName,
    this.avatarUrl,
    this.isOnline = false,
    this.lastActiveTime,
    this.presenceMessage,
    this.presence = UserPresence.offline,
  });

  @override
  List<Object?> get props => [
    userId,
    displayName,
    avatarUrl,
    isOnline,
    lastActiveTime,
    presenceMessage,
    presence,
  ];

  MCUser copyWith({
    String? userId,
    String? displayName,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastActiveTime,
    String? presenceMessage,
    UserPresence? presence,
  }) {
    return MCUser(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
      presenceMessage: presenceMessage ?? this.presenceMessage,
      presence: presence ?? this.presence,
    );
  }
}

/// User presence states
enum UserPresence { online, offline, idle, doNotDisturb, invisible }