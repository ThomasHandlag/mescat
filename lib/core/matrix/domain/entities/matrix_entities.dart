import 'package:equatable/equatable.dart';

/// Represents a Matrix user in the system
class MatrixUser extends Equatable {
  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastActiveTime;
  final String? presenceMessage;
  final UserPresence presence;

  const MatrixUser({
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

  MatrixUser copyWith({
    String? userId,
    String? displayName,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastActiveTime,
    String? presenceMessage,
    UserPresence? presence,
  }) {
    return MatrixUser(
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
enum UserPresence {
  online,
  offline,
  idle,
  doNotDisturb,
  invisible,
}

/// Represents a Matrix room (channel/server)
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
    );
  }
}

/// Room types for Discord-like functionality
enum RoomType {
  textChannel,
  voiceChannel,
  space, // Discord server equivalent
  directMessage,
  category,
}

/// Represents a Matrix message
class MatrixMessage extends Equatable {
  final String eventId;
  final String roomId;
  final String senderId;
  final String? senderDisplayName;
  final String? senderAvatarUrl;
  final MessageType type;
  final String content;
  final DateTime timestamp;
  final bool isEdited;
  final DateTime? editedTimestamp;
  final List<MessageReaction> reactions;
  final String? replyToEventId;
  final bool isEncrypted;
  final MessageStatus status;
  final Map<String, dynamic>? metadata;

  const MatrixMessage({
    required this.eventId,
    required this.roomId,
    required this.senderId,
    this.senderDisplayName,
    this.senderAvatarUrl,
    required this.type,
    required this.content,
    required this.timestamp,
    this.isEdited = false,
    this.editedTimestamp,
    this.reactions = const [],
    this.replyToEventId,
    this.isEncrypted = false,
    this.status = MessageStatus.sent,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        eventId,
        roomId,
        senderId,
        senderDisplayName,
        senderAvatarUrl,
        type,
        content,
        timestamp,
        isEdited,
        editedTimestamp,
        reactions,
        replyToEventId,
        isEncrypted,
        status,
        metadata,
      ];

  MatrixMessage copyWith({
    String? eventId,
    String? roomId,
    String? senderId,
    String? senderDisplayName,
    String? senderAvatarUrl,
    MessageType? type,
    String? content,
    DateTime? timestamp,
    bool? isEdited,
    DateTime? editedTimestamp,
    List<MessageReaction>? reactions,
    String? replyToEventId,
    bool? isEncrypted,
    MessageStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return MatrixMessage(
      eventId: eventId ?? this.eventId,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderDisplayName: senderDisplayName ?? this.senderDisplayName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      type: type ?? this.type,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isEdited: isEdited ?? this.isEdited,
      editedTimestamp: editedTimestamp ?? this.editedTimestamp,
      reactions: reactions ?? this.reactions,
      replyToEventId: replyToEventId ?? this.replyToEventId,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Message types
enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  location,
  emote,
  notice,
  sticker,
  none,
  badEncrypted,
}

extension MessageTypeExtension on MessageType {
  String get name {
    switch (this) {
      case MessageType.text:
        return 'm.text';
      case MessageType.image:
        return 'm.image';
      case MessageType.video:
        return 'm.video';
      case MessageType.audio:
        return 'm.audio';
      case MessageType.file:
        return 'm.file';
      case MessageType.location:
        return 'm.location';
      case MessageType.emote:
        return 'm.emote';
      case MessageType.notice:
        return 'm.notice';
      case MessageType.sticker:
        return 'm.sticker';
      case MessageType.none:
        return 'm.none';
      case MessageType.badEncrypted:
        return 'm.bad.encrypted';
    }
  }
}

extension MessageTypeFromString on String {
  MessageType toMessageType() {
    switch (this) {
      case 'm.text':
        return MessageType.text;
      case 'm.image':
        return MessageType.image;
      case 'm.video':
        return MessageType.video;
      case 'm.audio':
        return MessageType.audio;
      case 'm.file':
        return MessageType.file;
      case 'm.location':
        return MessageType.location;
      case 'm.emote':
        return MessageType.emote;
      case 'm.notice':
        return MessageType.notice;
      case 'm.sticker':
        return MessageType.sticker;
      case 'm.none':
        return MessageType.none;
      case 'm.bad.encrypted':
        return MessageType.badEncrypted;
      default:
        return MessageType.none;
    }
  }
}

/// Message status
enum MessageStatus {
  sending,
  sent,
  delivered,
  failed,
  encrypted,
}

/// Message reaction
class MessageReaction extends Equatable {
  final String emoji;
  final List<String> userIds;
  final int count;

  const MessageReaction({
    required this.emoji,
    required this.userIds,
    required this.count,
  });

  @override
  List<Object?> get props => [emoji, userIds, count];
}

/// Represents a Matrix Space (Discord server equivalent)
class MatrixSpace extends Equatable {
  final String spaceId;
  final String name;
  final String? description;
  final String? avatarUrl;
  final bool isPublic;
  final List<String> childRoomIds;
  final List<String> adminIds;
  final List<String> moderatorIds;
  final Map<String, dynamic> permissions;
  final DateTime createdAt;
  final int memberCount;

  const MatrixSpace({
    required this.spaceId,
    required this.name,
    this.description,
    this.avatarUrl,
    this.isPublic = false,
    this.childRoomIds = const [],
    this.adminIds = const [],
    this.moderatorIds = const [],
    this.permissions = const {},
    required this.createdAt,
    this.memberCount = 0,
  });

  @override
  List<Object?> get props => [
        spaceId,
        name,
        description,
        avatarUrl,
        isPublic,
        childRoomIds,
        adminIds,
        moderatorIds,
        permissions,
        createdAt,
        memberCount,
      ];

  MatrixSpace copyWith({
    String? spaceId,
    String? name,
    String? description,
    String? avatarUrl,
    bool? isPublic,
    List<String>? childRoomIds,
    List<String>? adminIds,
    List<String>? moderatorIds,
    Map<String, dynamic>? permissions,
    DateTime? createdAt,
    int? memberCount,
  }) {
    return MatrixSpace(
      spaceId: spaceId ?? this.spaceId,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPublic: isPublic ?? this.isPublic,
      childRoomIds: childRoomIds ?? this.childRoomIds,
      adminIds: adminIds ?? this.adminIds,
      moderatorIds: moderatorIds ?? this.moderatorIds,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      memberCount: memberCount ?? this.memberCount,
    );
  }
}