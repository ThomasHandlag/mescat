part of 'room_bloc.dart';

// Room Events
abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

class LoadRooms extends RoomEvent {
  final String? spaceId;
  final Function(MatrixRoom room)? onComplete;

  const LoadRooms({this.spaceId, this.onComplete});

  @override
  List<Object?> get props => [spaceId];
}

// class LoadMessages extends RoomEvent {
//   final String roomId;
//   final int limit;

//   const LoadMessages({required this.roomId, this.limit = 50});

//   @override
//   List<Object?> get props => [roomId, limit];
// }

// class SendMessage extends RoomEvent {
//   final String roomId;
//   final String content;
//   final String type;

//   const SendMessage({
//     required this.roomId,
//     required this.content,
//     this.type = MessageTypes.Text,
//   });

//   @override
//   List<Object?> get props => [roomId, content, type];
// }

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

class SelectedRoom extends RoomEvent {
  final MatrixRoom room;
  final RoomType? roomType;

  const SelectedRoom(this.room, {this.roomType});

  @override
  List<Object?> get props => [room, roomType];
}

class UpdateRoom extends RoomEvent {
  final MatrixRoom room;

  const UpdateRoom(this.room);

  @override
  List<Object?> get props => [room];
}
