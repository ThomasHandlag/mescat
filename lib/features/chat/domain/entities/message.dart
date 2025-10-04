import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String content;
  final String authorId;
  final String authorUsername;
  final String? authorAvatarUrl;
  final String channelId;
  final DateTime timestamp;
  final List<String> attachments;
  final bool isEdited;
  final DateTime? editedAt;

  const Message({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorUsername,
    this.authorAvatarUrl,
    required this.channelId,
    required this.timestamp,
    this.attachments = const [],
    this.isEdited = false,
    this.editedAt,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        authorId,
        authorUsername,
        authorAvatarUrl,
        channelId,
        timestamp,
        attachments,
        isEdited,
        editedAt,
      ];

  Message copyWith({
    String? id,
    String? content,
    String? authorId,
    String? authorUsername,
    String? authorAvatarUrl,
    String? channelId,
    DateTime? timestamp,
    List<String>? attachments,
    bool? isEdited,
    DateTime? editedAt,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorUsername: authorUsername ?? this.authorUsername,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      channelId: channelId ?? this.channelId,
      timestamp: timestamp ?? this.timestamp,
      attachments: attachments ?? this.attachments,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}