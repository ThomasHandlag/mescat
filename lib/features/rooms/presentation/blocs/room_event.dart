part of 'room_bloc.dart';

// Room Events
abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

class LoadRooms extends RoomEvent {
  final String? spaceId;

  const LoadRooms({this.spaceId});

  @override
  List<Object?> get props => [spaceId];
}

class LoadMessages extends RoomEvent {
  final String roomId;
  final int limit;

  const LoadMessages({required this.roomId, this.limit = 50});

  @override
  List<Object?> get props => [roomId, limit];
}

class SendMessage extends RoomEvent {
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

class CreateRoom extends RoomEvent {
  final String name;
  final String? topic;
  final RoomType type;
  final bool isPublic;
  final String? parentSpaceId;

  const CreateRoom({
    required this.name,
    this.topic,
    this.type = RoomType.textChannel,
    this.isPublic = false,
    this.parentSpaceId,
  });

  @override
  List<Object?> get props => [name, topic, type, isPublic, parentSpaceId];
}

class JoinRoom extends RoomEvent {
  final String roomId;

  const JoinRoom(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class LeaveRoom extends RoomEvent {
  final String roomId;

  const LeaveRoom(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class SelectRoom extends RoomEvent {
  final String? roomId;
  final RoomType? roomType;

  const SelectRoom(this.roomId, {this.roomType});

  @override
  List<Object?> get props => [roomId, roomType];
}

class AddReaction extends RoomEvent {
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

class RemoveReaction extends RoomEvent {
  final String roomId;
  final String eventId;
  final String emoji;

  const RemoveReaction({
    required this.roomId,
    required this.eventId,
    required this.emoji,
  });

  @override
  List<Object?> get props => [roomId, eventId, emoji];
}

class DeleteMessage extends RoomEvent {
  final String roomId;
  final String eventId;

  const DeleteMessage({required this.roomId, required this.eventId});

  @override
  List<Object?> get props => [roomId, eventId];
}

class EditMessage extends RoomEvent {
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

class ReplyMessage extends RoomEvent {
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

class SetInputAction extends RoomEvent {
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

class LoadMoreMessages extends RoomEvent {
  final int limit;
  const LoadMoreMessages({this.limit = 50});

  @override
  List<Object?> get props => [limit];
}

class ReceiveMessage extends RoomEvent {
  final MCMessageEvent message;

  const ReceiveMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateRoom extends RoomEvent {
  final MatrixRoom room;

  const UpdateRoom(this.room);

  @override
  List<Object?> get props => [room];
}

final class MessageReacted extends RoomEvent {
  final MCReactionEvent event;

  const MessageReacted({required this.event});

  @override
  List<Object?> get props => [event];
}

final class JoinCall extends RoomEvent {
  final String roomId;

  const JoinCall(this.roomId);

  @override
  List<Object?> get props => [roomId];
}
