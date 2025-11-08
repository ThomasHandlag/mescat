part of 'room_bloc.dart';

// Room States
abstract class RoomState extends Equatable {
  const RoomState();

  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {}

class RoomLoading extends RoomState {}

class RoomLoaded extends RoomState {
  final List<MatrixRoom> rooms;
  final String? selectedRoomId;
  final MatrixRoom? selectedRoom;
  final bool flag;
  const RoomLoaded({
    required this.rooms,
    this.selectedRoomId,
    this.selectedRoom,
    this.flag = false,
  });

  @override
  List<Object?> get props => [
    rooms,
    selectedRoomId,
    selectedRoom,
    flag,
  ];

  RoomLoaded copyWith({
    List<MatrixRoom>? rooms,
    String? selectedRoomId,
    MatrixRoom? selectedRoom,
    bool? flag,
  }) {
    return RoomLoaded(
      rooms: rooms ?? this.rooms,
      selectedRoomId: selectedRoomId ?? this.selectedRoomId,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      flag: flag ?? this.flag,
    );
  }
}

class RoomError extends RoomState {
  final String message;

  const RoomError(this.message);

  @override
  List<Object?> get props => [message];
}

// enum InputAction { none, reply, edit }

// class InputActionData extends Equatable {
//   final InputAction action;
//   final String? targetEventId;
//   final String? initialContent;

//   const InputActionData({
//     required this.action,
//     this.targetEventId,
//     this.initialContent,
//   });

//   @override
//   List<Object?> get props => [action, targetEventId, initialContent];
// }
