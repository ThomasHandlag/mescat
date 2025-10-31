part of 'mescat_entities.dart';

class MatrixRoom extends Equatable {
  final String roomId;
  final String? name;
  final String? topic;
  final String? avatarUrl;
  final RoomType type;
  final bool isEncrypted;
  final bool isPublic;
  final int memberCount;
  final DateTime? lastActivity;
  final String? lastMessage;
  final int unreadCount;
  final bool isMuted;
  final List<String> tags;
  final String? parentSpaceId;
  final bool canHaveCall;
  final Map<String, dynamic>? permission;
  final Map<String, String>? bannedIds;
  final Room room;

  const MatrixRoom({
    required this.roomId,
    this.name,
    this.topic,
    this.avatarUrl,
    this.type = RoomType.textChannel,
    this.isEncrypted = false,
    this.isPublic = false,
    this.memberCount = 0,
    this.lastActivity,
    this.lastMessage,
    this.unreadCount = 0,
    this.isMuted = false,
    this.tags = const [],
    this.parentSpaceId,
    this.canHaveCall = false,
    this.permission,
    this.bannedIds,
    required this.room
  });

  @override
  List<Object?> get props => [
    roomId,
    name,
    topic,
    avatarUrl,
    type,
    isEncrypted,
    isPublic,
    memberCount,
    lastActivity,
    lastMessage,
    unreadCount,
    isMuted,
    tags,
    parentSpaceId,
    canHaveCall,
    permission,
    bannedIds,
    room,
  ];

  MatrixRoom copyWith({
    String? roomId,
    String? name,
    String? topic,
    String? avatarUrl,
    RoomType? type,
    bool? isEncrypted,
    bool? isPublic,
    int? memberCount,
    DateTime? lastActivity,
    String? lastMessage,
    int? unreadCount,
    bool? isMuted,
    List<String>? tags,
    String? parentSpaceId,
    bool? canHaveCall,
    Map<String, dynamic>? permission,
    Map<String, String>? bannedIds,
    Room? room,
  }) {
    return MatrixRoom(
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      topic: topic ?? this.topic,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      type: type ?? this.type,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      isPublic: isPublic ?? this.isPublic,
      memberCount: memberCount ?? this.memberCount,
      lastActivity: lastActivity ?? this.lastActivity,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isMuted: isMuted ?? this.isMuted,
      tags: tags ?? this.tags,
      parentSpaceId: parentSpaceId ?? this.parentSpaceId,
      canHaveCall: canHaveCall ?? this.canHaveCall,
      permission: permission ?? this.permission,
      bannedIds: bannedIds ?? this.bannedIds,
      room: room ?? this.room,
    );
  }
}

enum RoomType { textChannel, voiceChannel, space, directMessage, category }
