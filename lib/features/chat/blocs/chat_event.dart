part of 'chat_bloc.dart';

// Chat Events
sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatEvent {
  final String roomId;
  final int limit;

  const LoadMessages({required this.roomId, this.limit = 50});

  @override
  List<Object?> get props => [roomId, limit];
}

class SendMessage extends ChatEvent {
  final String roomId;
  final String content;
  final String type;

  const SendMessage({
    required this.roomId,
    required this.content,
    this.type = MessageTypes.Text,
  });

  @override
  List<Object?> get props => [roomId, content, type];
}

class AddReaction extends ChatEvent {
  final String roomId;
  final String eventId;
  final String emoji;

  const AddReaction({
    required this.roomId,
    required this.eventId,
    required this.emoji,
  });

  @override
  List<Object?> get props => [roomId, eventId, emoji];
}

class RemoveReaction extends ChatEvent {
  final String roomId;
  final String eventId;
  final String emoji;
  final String reactEventId;

  const RemoveReaction({
    required this.roomId,
    required this.eventId,
    required this.emoji,
    required this.reactEventId,
  });

  @override
  List<Object?> get props => [roomId, eventId, emoji, reactEventId];
}

class DeleteMessage extends ChatEvent {
  final String roomId;
  final String eventId;

  const DeleteMessage({required this.roomId, required this.eventId});

  @override
  List<Object?> get props => [roomId, eventId];
}

class EditMessage extends ChatEvent {
  final String roomId;
  final String eventId;
  final String newContent;

  const EditMessage({
    required this.roomId,
    required this.eventId,
    required this.newContent,
  });

  @override
  List<Object?> get props => [roomId, eventId, newContent];
}

class ReplyMessage extends ChatEvent {
  final String roomId;
  final String content;
  final String replyToEventId;
  final String type;

  const ReplyMessage({
    required this.roomId,
    required this.content,
    required this.replyToEventId,
    this.type = MessageTypes.Text,
  });

  @override
  List<Object?> get props => [roomId, content, replyToEventId, type];
}

class SetInputAction extends ChatEvent {
  final InputAction action;
  final String? targetEventId;
  final String? initialContent;

  const SetInputAction({
    required this.action,
    this.targetEventId,
    this.initialContent,
  });

  @override
  List<Object?> get props => [action];
}

class LoadMoreMessages extends ChatEvent {
  final int limit;
  const LoadMoreMessages({this.limit = 50});

  @override
  List<Object?> get props => [limit];
}

class ReceiveMessage extends ChatEvent {
  final MCMessageEvent message;

  const ReceiveMessage(this.message);

  @override
  List<Object?> get props => [message];
}

final class MessageReacted extends ChatEvent {
  final MCReactionEvent event;

  const MessageReacted({required this.event});

  @override
  List<Object?> get props => [event];
}

