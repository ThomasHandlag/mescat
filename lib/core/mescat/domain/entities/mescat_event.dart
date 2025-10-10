part of 'mescat_entities.dart';

/// Represents a Matrix event in the system
class MCEvent extends Equatable {
  final String eventId;
  final String roomId;
  final String senderId;
  final DateTime timestamp;
  final String eventTypes;

  const MCEvent({
    required this.eventId,
    required this.roomId,
    required this.senderId,
    required this.timestamp,
    required this.eventTypes,
  });

  @override
  List<Object?> get props => [eventId, roomId, senderId, timestamp, eventTypes];
}

class MCMessageEvent extends MCEvent {
  final String? senderDisplayName;
  final String? senderAvatarUrl;
  final String msgtype;
  final bool isEdited;
  final DateTime? editedTimestamp;
  final List<MCReactionEvent> reactions;
  final RepliedEventContent? repliedEvent;
  final bool isEncrypted;
  final MessageStatus status;
  final Map<String, dynamic>? metadata;
  final MatrixFile? file;
  final bool isCurrentUser;
  final String body;

  const MCMessageEvent({
    required super.eventId,
    required super.roomId,
    required super.senderId,
    required this.isCurrentUser,
    this.senderDisplayName,
    this.senderAvatarUrl,
    required this.msgtype,
    required super.eventTypes,
    required this.body,
    required super.timestamp,
    this.isEdited = false,
    this.editedTimestamp,
    this.reactions = const [],
    this.repliedEvent,
    this.isEncrypted = false,
    this.status = MessageStatus.sent,
    this.metadata,
    this.file,
  }) : assert(
         msgtype != MessageTypes.Image || file != null,
         'File must be provided for image messages',
       );

  @override
  List<Object?> get props => [
    ...super.props,
    senderDisplayName,
    senderAvatarUrl,
    msgtype,
    body,
    timestamp,
    isEdited,
    editedTimestamp,
    reactions,
    repliedEvent,
    isEncrypted,
    status,
    metadata,
    file,
    isCurrentUser,
  ];

  MCMessageEvent copyWith({
    String? eventId,
    String? roomId,
    String? senderId,
    String? senderDisplayName,
    String? senderAvatarUrl,
    String? msgtype,
    String? eventTypes,
    String? body,
    DateTime? timestamp,
    bool? isEdited,
    DateTime? editedTimestamp,
    List<MCReactionEvent>? reactions,
    RepliedEventContent? repliedEvent,
    bool? isEncrypted,
    MessageStatus? status,
    Map<String, dynamic>? metadata,
    MatrixFile? file,
    bool? isCurrentUser,
    String? replyToContent,
  }) {
    return MCMessageEvent(
      eventId: eventId ?? this.eventId,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderDisplayName: senderDisplayName ?? this.senderDisplayName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      msgtype: msgtype ?? this.msgtype,
      eventTypes: eventTypes ?? this.eventTypes,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isEdited: isEdited ?? this.isEdited,
      editedTimestamp: editedTimestamp ?? this.editedTimestamp,
      reactions: reactions ?? this.reactions,
      repliedEvent: repliedEvent ?? this.repliedEvent,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      file: file ?? this.file,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}

class MCImageEvent extends MCMessageEvent {
  final int height;
  final int width;
  final String mimeType;

  const MCImageEvent({
    required super.eventId,
    required super.roomId,
    required super.senderId,
    super.senderDisplayName,
    super.senderAvatarUrl,
    super.msgtype = MessageTypes.Image,
    super.eventTypes = EventTypes.Message,
    super.body = "",
    required super.timestamp,
    required super.file,
    super.isEdited,
    super.editedTimestamp,
    super.reactions,
    super.repliedEvent,
    super.isEncrypted,
    super.status,
    super.metadata,
    required this.height,
    required this.width,
    required this.mimeType,
    required super.isCurrentUser,
  });

  @override
  List<Object?> get props => [...super.props, height, mimeType];

  @override
  MCImageEvent copyWith({
    String? eventId,
    String? roomId,
    String? senderId,
    String? senderDisplayName,
    String? senderAvatarUrl,
    String? msgtype,
    String? eventTypes,
    String? body,
    DateTime? timestamp,
    bool? isEdited,
    DateTime? editedTimestamp,
    List<MCReactionEvent>? reactions,
    RepliedEventContent? repliedEvent,
    bool? isEncrypted,
    MessageStatus? status,
    Map<String, dynamic>? metadata,
    String? url,
    int? width,
    int? height,
    int? size,
    String? mimeType,
    MatrixFile? file,
    bool? isCurrentUser,
    String? replyToContent,
  }) {
    return MCImageEvent(
      eventId: eventId ?? this.eventId,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderDisplayName: senderDisplayName ?? this.senderDisplayName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      msgtype: MessageTypes.Image,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isEdited: isEdited ?? this.isEdited,
      editedTimestamp: editedTimestamp ?? this.editedTimestamp,
      reactions: reactions ?? this.reactions,
      repliedEvent: repliedEvent ?? this.repliedEvent,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      height: height ?? this.height,
      width: width ?? this.width,
      mimeType: mimeType ?? this.mimeType,
      file: file ?? this.file,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}

/// Message status
enum MessageStatus { sending, sent, delivered, failed, encrypted }

/// Message reaction
class MCReactionEvent extends MCEvent {
  final String key;
  final String relatedEventId;
  final String relType = "m.annotation";
  final List<String?> senderDisplayNames;
  final List<MapEntry<String, String>> reactEventIds;
  final bool isCurrentUser;

  const MCReactionEvent({
    required this.key,
    required this.relatedEventId,
    required this.senderDisplayNames,
    required this.reactEventIds,
    super.eventId = "",
    required super.roomId,
    required super.senderId,
    required super.timestamp,
    required super.eventTypes,
    required this.isCurrentUser,
  });

  MCReactionEvent copyWith({
    String? key,
    String? relatedEventId,
    List<String?>? senderDisplayNames,
    String? eventId,
    String? roomId,
    String? senderId,
    DateTime? timestamp,
    String? eventTypes,
    List<MapEntry<String, String>>? reactEventIds,
    bool? isCurrentUser,
  }) {
    return MCReactionEvent(
      key: key ?? this.key,
      relatedEventId: relatedEventId ?? this.relatedEventId,
      senderDisplayNames: senderDisplayNames ?? this.senderDisplayNames,
      eventId: eventId ?? this.eventId,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      timestamp: timestamp ?? this.timestamp,
      eventTypes: eventTypes ?? this.eventTypes,
      reactEventIds: reactEventIds ?? this.reactEventIds,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  @override
  List<Object?> get props => [
    key,
    relatedEventId,
    relType,
    senderDisplayNames,
    isCurrentUser,
    ...super.props,
  ];
}
